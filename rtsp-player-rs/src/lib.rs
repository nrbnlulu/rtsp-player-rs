use anyhow::anyhow;
use flutter_texture::FlutterTexture;
use gst::{glib, prelude::ElementExt};
use gst_gl::prelude::*;
mod flutter_texture;
mod models;

pub fn init_gst() -> anyhow::Result<()> {
    // Set up main loop
    let main_loop = glib::MainLoop::new(None, false);

    // Initialize GStreamer
    gst::init()?;

    Ok(())
}

fn rtsp_to_gl_pipeline(uri: String, texture: FlutterTexture) -> anyhow::Result<()> {
    // see https://stackoverflow.com/questions/44160118/gstreamer-pipeline-to-show-an-rtsp-stream
    // `gst-launch-1.0 rtspsrc location=rtsp://localhost:8554/test latency=100 ! queue ! rtph264depay
    //  ! h264parse ! avdec_h264 ! videoconvert ! videoscale ! video/x-raw,width=640,height=480 ! autovideosink`

    let pipeline = gst::Pipeline::default();

    // Create the elements
    let rtspsrc = gst::ElementFactory::make("rtspsrc")
        .property("location", uri)
        .property("latency", 100)
        .build()?;
    let caps = gst_video::VideoCapsBuilder::new()
        .features([gst_gl::CAPS_FEATURE_MEMORY_GL_MEMORY])
        .format(gst_video::VideoFormat::Rgba)
        .field("texture-target", "2D")
        .build();

    let queue = gst::ElementFactory::make("queue").build()?;
    let rtph264depay = gst::ElementFactory::make("rtph264depay").build()?;
    let h264parse = gst::ElementFactory::make("h264parse").build()?;
    let avdec_h264 = gst::ElementFactory::make("avdec_h264").build()?;
    let videoscale = gst::ElementFactory::make("videoscale").build()?;
    let videoconvert = gst::ElementFactory::make("videoconvert").build()?;
    let glupload = gst::ElementFactory::make("glupload").build()?;
    let glsinkbin = gst::ElementFactory::make("glsinkbin").build()?;
    // Set up appsink
    let appsink = gst_app::AppSink::builder()
        .enable_last_sample(true)
        .max_buffers(1)
        .caps(&caps)
        .build();
    appsink.set_property("emit-signals", &true.to_value());
    appsink.set_property("sync", &false.to_value());
    appsink.set_property("max-buffers", &1u32.to_value());
    appsink.set_property("drop", &true.to_value());

    // add video source
    pipeline.add(&rtspsrc)?;
    // queue the video source (im not sure why this is needed, also maybe would be better to set
    // queue to `leaky` mode for better latency)
    pipeline.add(&queue)?;
    // Extracts H264 video from RTP packets (RFC 3984)
    pipeline.add(&rtph264depay)?;
    // Parses H264 video stream
    pipeline.add(&h264parse)?;
    // libav h264 decoder
    pipeline.add(&avdec_h264)?;
    // Convert video frames between a great variety of video formats.
    pipeline.add(&videoconvert)?;
    // Scale video frames
    pipeline.add(&videoscale)?;
    // Uploads video frames to OpenGL texture
    pipeline.add(&glupload)?;
    // AppSink is a sink that provides a buffer to the application
    pipeline.add(&appsink)?;
    // Add the glsinkbin, we'll use this to tunnel the sink to the appsink.
    pipeline.add(&glsinkbin)?;
    glsinkbin.set_property("sink", &appsink);

    // Link the elements
    gst::Element::link_many(&[
        &rtspsrc,
        &queue,
        &rtph264depay,
        &h264parse,
        &avdec_h264,
        &videoconvert,
        &videoscale,
        &glupload,
        &glsinkbin,
    ])?;

    // Initialize GL display
    let gl_display = gst_gl::GLDisplay::default();

    // Set up the GL context
    let gl_context = unsafe {
        gst_gl::GLContext::new_wrapped(
            &gl_display,
            texture.ptr,
            gst_gl::GLPlatform::EGL,
            gst_gl::GLAPI::GLES2,
        )
    }.ok_or_else(|| anyhow!("Failed to create GL context"))?;
    gl_context.activate(true)?;

    Ok(())
}

#[cfg(test)]
mod tests {
    use super::*;
}
