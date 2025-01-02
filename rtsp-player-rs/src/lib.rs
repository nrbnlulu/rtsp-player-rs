use gst::{glib, prelude::ElementExt};
use anyhow::anyhow;

pub fn init_gst() -> anyhow::Result<()> {
    // Set up main loop
    let main_loop = glib::MainLoop::new(None, false);

    // Initialize GStreamer
    gst::init()?;


    Ok(())
}


fn rtsp_to_gl_bin(uri: String) -> anyhow::Result<()>{

    // Create the elements
    let rtspsrc = gst::ElementFactory::make("rtspsrc").property("location", uri).property("latency", 100)
    .build()?;
    let queue = gst::ElementFactory::make("queue").build()?;
    let rtph264depay = gst::ElementFactory::make("rtph264depay").build()?;
    let h264parse = gst::ElementFactory::make("h264parse").build()?;
    let avdec_h264 = gst::ElementFactory::make("avdec_h264").build()?;
    let videoconvert = gst::ElementFactory::make("videoconvert").build()?;
    let glupload = gst::ElementFactory::make("glupload").build()?;
    let glcolorconvert = gst::ElementFactory::make("glcolorconvert").build()?;
    let glimagesink = gst::ElementFactory::make("glimagesink").build()?;
    let pipeline = gst::Pipeline::new();
    let bus = pipeline.bus().ok_or(anyhow!("Pipeline bus error"))?;
    

    Ok(())
}





#[cfg(test)]
mod tests {
    use super::*;


}
