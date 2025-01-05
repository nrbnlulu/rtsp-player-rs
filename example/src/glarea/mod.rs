
use glib::Object;
use gtk::glib;
mod imp;
pub mod render;


glib::wrapper! {
    pub struct RtspGlArea(ObjectSubclass<imp::RtspGlArea>)
    @extends gtk::GLArea, gtk::Widget,
    @implements gtk::Accessible, gtk::Buildable, gtk::ConstraintTarget;
}

impl RtspGlArea {
    pub fn new() -> Self {
        Object::builder().build()
    }

}
