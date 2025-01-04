use std::thread;

use gtk::gdk::ffi::{gdk_gl_context_get_current, gdk_gl_context_realize};
use gtk::prelude::{GLAreaExt, GLContextExt, ObjectExt, WidgetExt};
use gtk::{gdk::GLContext, prelude::ObjectType};
use gtk::glib;
use gtk::subclass::prelude::*;
use rtsp_player_rs::{flutter_texture::FlutterTexture, rtsp_to_gl_pipeline};

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
        let flutter_ctx = FlutterTexture::new(
            gl_context_ptr as usize,
            640,
            480,
        );
        thread::spawn(move ||{
            rtsp_to_gl_pipeline(
                "rtsp://admin:camteam524@31.154.52.236:10500/main".to_string(),
                flutter_ctx,
            ).unwrap();
        });
        
        glib::Propagation::Stop
    }
}
