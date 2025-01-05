
use gst::prelude::*;
use gtk::gdk;
use rtsp_player_rs::utils::make_gs_element;
use std::cell::RefCell;

fn play_rtsp() -> anyhow::Result<()> {
    let sink =
        make_gs_element("gtk4paintablesink").map(|gtksink| -> anyhow::Result<gst::Element> {
            // Need to set state to Ready to get a GL context
            gtksink.set_state(gst::State::Ready)?;
            let paintable = gtksink.property::<Option<gdk::Paintable>>("paintable");




            // TODO: future plans to provide a bin-like element that works with less setup
            let (src, sink) = if paintable
                .property::<Option<gdk::GLContext>>("gl-context")
                .is_some()
            {
                let src = gst::ElementFactory::make("gltestsrc").build().unwrap();

                let sink = gst::ElementFactory::make("glsinkbin")
                    .property("sink", &gtksink)
                    .build()
                    .unwrap();
                (src, sink)
            } else {
                let src = gst::ElementFactory::make("videotestsrc").build().unwrap();

                let sink = gst::Bin::default();
                let convert = gst::ElementFactory::make("videoconvert").build().unwrap();

                sink.add(&convert).unwrap();
                sink.add(&gtksink).unwrap();
                convert.link(&gtksink).unwrap();

                sink.add_pad(
                    &gst::GhostPad::with_target(&convert.static_pad("sink").unwrap()).unwrap(),
                )
                .unwrap();

                (src, sink.upcast())
            };

            Ok(gtksink)
        });
    thread::spawn(move || {
        if let Err(e) = rtsp_to_gl_pipeline(
            "rtsp://admin:camteam524@192.168.3.71:10500/main".to_string(),
            FlutterTexture::new(gl_context_ptr, 640, 480),
        ) {
            eprintln!("Failed to start RTSP pipeline: {:?}", e);
        }
    });

    Ok(())
}
