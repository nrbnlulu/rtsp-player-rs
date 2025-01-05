use gst::prelude::{ElementExt, ObjectExt};
use gtk::gdk::ffi::{gdk_gl_context_get_current, gdk_gl_context_realize};
use gtk::glib;
use gtk::prelude::{Cast, GLAreaExt, GLContextExt, ObjectExt, WidgetExt};
use gtk::subclass::prelude::*;
use gtk::{gdk, gdk::GLContext, prelude::ObjectType};
use rtsp_player_rs::utils::make_gs_element;
use rtsp_player_rs::{flutter_texture::FlutterTexture, rtsp_to_gl_pipeline};
use std::sync::LazyLock;
use std::thread;

#[derive(Default)]
pub struct RtspGlArea;

#[glib::object_subclass]
impl ObjectSubclass for RtspGlArea {
    const NAME: &'static str = "RtspGlArea";
    type Type = crate::RtspGlArea;
    type ParentType = gtk::GLArea;
}

impl ObjectImpl for RtspGlArea {}

impl WidgetImpl for RtspGlArea {
    fn realize(&self) {
        self.parent_realize();

        let widget = self.obj();
        if widget.error().is_some() {
            println!("Error: {:?}", widget.error().unwrap());
            return;
        }
    }

    fn unrealize(&self) {
        self.parent_unrealize();
    }
}

impl GLAreaImpl for RtspGlArea {
    fn render(&self, _context: &GLContext) -> glib::Propagation {
        _context.make_current();
        // render
        let gl_context_ptr = unsafe { gdk_gl_context_get_current() };
        let gl_context_ptr = gl_context_ptr as usize;
        let sink = make_gs_element("gtk4paintablesink").map(|gtksink|
            -> anyhow::Result<gst::Element>
            {
            // Need to set state to Ready to get a GL context
            gtksink.set_state(gst::State::Ready)?;
            let printable = make_gs_element("paintable")?;
            gtksink.set_property("paintable", &printable);
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

        glib::Propagation::Stop
    }
}
