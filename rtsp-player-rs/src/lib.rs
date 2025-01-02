use gst::glib;


pub fn init_gst() -> anyhow::Result<()> {
    // Set up main loop
    let main_loop = glib::MainLoop::new(None, false);

    // Initialize GStreamer
    gst::init()?;


    Ok(())
}


fn rtsp_to_gl_bin() -> anyhow::Result<()>{
    


    Ok(())
}





#[cfg(test)]
mod tests {
    use super::*;


}
