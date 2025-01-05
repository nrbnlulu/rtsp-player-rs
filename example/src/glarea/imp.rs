use std::sync::LazyLock;
use std::thread;
use gst_gl_egl::gst_gl::gst;
use gst_gl_wayland::gst_gl;
use gtk::gdk::ffi::{gdk_gl_context_get_current, gdk_gl_context_realize};
use gtk::prelude::{Cast, GLAreaExt, GLContextExt, ObjectExt, WidgetExt};
use gtk::{gdk, gdk::GLContext, prelude::ObjectType};
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
            let gl_context_ptr = gl_context_ptr as usize;
            thread::spawn(move ||{
                if let Err(e) = rtsp_to_gl_pipeline(
                    "rtsp://admin:camteam524@192.168.3.71:10500/main".to_string(),
                    FlutterTexture::new(
                        gl_context_ptr,
                        640,
                        480,
                    ),
                ) {
                    eprintln!("Failed to start RTSP pipeline: {:?}", e);
                }
            });

            glib::Propagation::Stop
        }
}
pub(crate) static CAT: LazyLock<gst::DebugCategory> = LazyLock::new(|| {
    gst::DebugCategory::new(
        "gtk4paintablesink",
        gst::DebugColorFlags::empty(),
        Some("GTK4 Paintable sink"),
    )
});
impl RtspGlArea {
    fn initialize_waylandegl(
        &self,
        display: &gdk::Display,
    ) -> Option<(gst_gl::GLDisplay, gst_gl::GLContext)> {
        gst::info!(
            CAT,
            imp = self,
            "Initializing GL for Wayland EGL backend and display"
        );

        let platform = gst_gl::GLPlatform::EGL;
        let (gl_api, _, _) = gst_gl::GLContext::current_gl_api(platform);
        let gl_ctx = gst_gl::GLContext::current_gl_context(platform);

        if gl_ctx == 0 {
            gst::error!(CAT, imp = self, "Failed to get handle from GdkGLContext");
            return None;
        }

        // FIXME: bindings
        unsafe {
            use glib::translate::*;

            // let wayland_display = gdk_wayland::WaylandDisplay::wl_display(display.downcast());
            // get the ptr directly since we are going to use it raw
            let display = display
                .downcast_ref::<gdk_wayland::WaylandDisplay>()
                .unwrap();
            let wayland_display =
                gdk_wayland::ffi::gdk_wayland_display_get_wl_display(display.to_glib_none().0);
            if wayland_display.is_null() {
                gst::error!(CAT, imp = self, "Failed to get Wayland display");
                return None;
            }

            let gst_display =
                gst_gl_wayland::ffi::gst_gl_display_wayland_new_with_display(wayland_display);
            let gst_display =
                gst_gl::GLDisplay::from_glib_full(gst_display as *mut gst_gl::ffi::GstGLDisplay);

            let wrapped_context =
                gst_gl::GLContext::new_wrapped(&gst_display, gl_ctx, platform, gl_api);

            let wrapped_context = match wrapped_context {
                None => {
                    gst::error!(CAT, imp = self, "Failed to create wrapped GL context");
                    return None;
                }
                Some(wrapped_context) => wrapped_context,
            };

            Some((gst_display, wrapped_context))
        }
    }
}