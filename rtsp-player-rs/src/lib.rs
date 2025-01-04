use std::{ sync::{Arc, Mutex}};

use anyhow::anyhow;
use derive_more::{Display, Error};

use flutter_texture::FlutterTexture;
use gst::{element_error, glib, prelude::ElementExt, Element};
use gst_gl::prelude::*;
pub mod flutter_texture;
pub mod models;

// inspirations:
// - https://github.com/freskog/google-camera-proxy/blob/a922149166526585fe86ec2f5f29c19cb5b6f586/src/main.rs#L325
// - https://stackoverflow.com/questions/44160118/gstreamer-pipeline-to-show-an-rtsp-stream
// `gst-launch-1.0 rtspsrc location=rtsp://localhost:8554/test latency=100 ! queue ! rtph264depay
//  ! h264parse ! avdec_h264 ! videoconvert ! videoscale ! video/x-raw,width=640,height=480 ! autovideosink`
// - 



pub fn init_gst() -> anyhow::Result<()> {
    // Set up main loop
    let main_loop = glib::MainLoop::new(None, false);

    // Initialize GStreamer
    gst::init()?;

    Ok(())
}

#[derive(Debug, Display, Error)]
#[display("Received error from {}: {} (debug: {:?})", src, error, debug)]
struct ErrorMessage {
    src: String,
    error: String,
    debug: Option<String>,
    source: glib::Error,
}

#[derive(Debug, Display, Error)]
#[display("Could not get mount points")]
struct NoMountPoints;



enum Transport {
    TCP,
    UDP,
}
#[derive(Clone, Debug, glib::Boxed)]
#[boxed_type(name = "ErrorValue")]
struct ErrorValue(Arc<Mutex<Option<anyhow::Error>>>);

pub fn rtsp_to_gl_pipeline(uri: String, texture: FlutterTexture) -> anyhow::Result<()> {

    let pipeline = gst::Pipeline::default();

    let rtspsrc = gst::ElementFactory::make("rtspsrc")
        .property("location", uri)
        .property("latency", 2000 as u32)
        .property("do-rtcp", true)
        .property("is-live", true)
        .property("do-rtsp-keep-alive", true)
        .property("debug", true)
        .build()?;

    let videoqueue = Arc::new(Mutex::new(gst::ElementFactory::make("queue").build()?));

    pipeline.add(&rtspsrc)?;

    let pipeline_weak = pipeline.downgrade();
    let videoqueue_clone = videoqueue.clone();

    rtspsrc.connect_pad_removed(move |_, src_pad| {
        let unlink = |videoqueue: &Element| -> anyhow::Result<()> {
            let sink_pad = videoqueue.static_pad("sink").unwrap();
            if sink_pad.is_linked() {
                return src_pad.unlink(&sink_pad).map_err(|e| e.into());
            } else {
                return Ok(());
            }
        };

        unlink(&videoqueue_clone.lock().unwrap()).expect("Error when unlinking");
    });

    let videoqueue_clone = videoqueue.clone();
    rtspsrc.connect_pad_added(move |rsrc, src_pad| {
        println!("RTSP Src added!");

        let pipeline = match pipeline_weak.upgrade() {
            Some(pipeline) => pipeline,
            None => return,
        };

        let insert_sink = |videoqueue: &Element| -> anyhow::Result<()> {
            let media_type = media_type_of(&src_pad)?;
            if !media_type.starts_with("video") {
                println!("ignoring pad with wrong media_type: {}", media_type);
                return Ok(());
            }
         
            let rtph264depay = gst::ElementFactory::make("rtph264depay").build()?;
            let h264parse = gst::ElementFactory::make("h264parse").build()?;
            let avdec_h264 = gst::ElementFactory::make("avdec_h264").build()?;
            let glupload = gst::ElementFactory::make("glupload").build()?;
            let glsinkbin = gst::ElementFactory::make("glsinkbin").build()?;
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


            let elements = &[
                &videoqueue,
                &rtph264depay,
                &h264parse,
                &avdec_h264,
                &glupload,
                &glsinkbin,
            ];

            let bin = gst::Bin::builder().property("name", "pay0").build();

            println!("Adding elements to bin");
            bin.add_many(elements)?;

            println!("Adding elements to pipeline");

            pipeline.add(&bin)?;
            println!("Linking elements");

            gst::Element::link_many(elements)?;

            println!("elements linked");

            for e in elements {
                e.sync_state_with_parent()?
            }

            bin.sync_state_with_parent()?;

            println!("elements synced");

            let sink_pad = videoqueue
                .static_pad("sink")
                .expect("video queue has no sinkpad");

            println!("sink pad found");

            let ghost_pad = gst::GhostPad::with_target(&sink_pad)?;

            println!("created ghost pad");

            bin.add_pad(&ghost_pad)?;

            println!("added ghost pad");

            src_pad.link(&ghost_pad)?;

            println!("Successfully linked rtspsrc to video chain");
            gl_context.activate(true)?;

            Ok(())
        };

        if let Err(err) = insert_sink(&videoqueue_clone.lock().unwrap()) {
            element_error!(
                rsrc,
                gst::LibraryError::Failed,
                ("Failed to insert sink"),
                details: gst::Structure::builder("error-details")
                                    .field("error", &format!("{:?}", err))
                                    .build()
            );
        }
    });

    pipeline.set_state(gst::State::Playing)?;

    let bus = pipeline
        .bus()
        .expect("Pipeline without bus. Shouldn't happen!");

    for msg in bus.iter_timed(gst::ClockTime::NONE) {
        use gst::MessageView;

        match msg.view() {
            MessageView::Eos(..) => break,
            MessageView::Error(err) => {
                pipeline.set_state(gst::State::Null)?;

                match err.details() {
                    Some(details) if details.name() == "error-details" => details
                        .get::<&ErrorValue>("error")
                        .unwrap()
                        .clone()
                        .0
                        .lock()
                        .unwrap()
                        .take()
                        .map(Result::Err)
                        .expect("error-details message without actual error"),
                    _ => Err(ErrorMessage {
                        src: msg
                            .src()
                            .map(|s| String::from(s.path_string()))
                            .unwrap_or_else(|| String::from("None")),
                        error: err.error().to_string(),
                        debug: err.debug().map(|d| d.to_string()),
                        source: err.error(),
                    }
                    .into()),
                }?;
            }
            MessageView::StateChanged(s) => {
                println!(
                    "State changed from {:?}: {:?} -> {:?} ({:?})",
                    s.src().map(|s| s.path_string()),
                    s.old(),
                    s.current(),
                    s.pending()
                );
            }
            _ => (),
        }
    }

    pipeline.set_state(gst::State::Null)?;

    Ok(())
}


enum VideoEncodeType {
    H264,
    H265,
}
fn media_type_of(pad: &gst::Pad) -> anyhow::Result<String> {
    let caps = pad
        .current_caps()
        .expect("There were no caps for the new pad!");
    let structure = caps
        .structure(0)
        .expect("src pad doesn't have any structure");

    for n in 0..structure.n_fields() {
        let field_name = structure.nth_field_name(n).unwrap();
        if field_name.starts_with("media") {
            let media_type = structure.value(field_name).unwrap().get::<&str>().unwrap();
            return Ok(media_type.to_string());
        }
    }
    Err(anyhow!("No media field on pad"))
}

#[cfg(test)]
mod tests {
    use super::*;
}
