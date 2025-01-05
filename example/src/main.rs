use glarea::RtspGlArea;
use gtk;
use gtk::prelude::*;
use gtk::{glib, Application, ApplicationWindow};
use rtsp_player_rs::init_gst;
mod glarea;

fn main() -> glib::ExitCode {
    let app = Application::builder()
        .application_id("org.example.HelloWorld")
        .build();
    app.connect_activate(|app| {
    init_gst().unwrap();

        // We create the main window.
        
        let window = ApplicationWindow::builder()
            .application(app)
            .default_width(800)
            .default_height(600)
            .title("Hello, World!")
            .build();

        let widget = RtspGlArea::new();

        window.set_child(Some(&widget));
        // Show the window.
        window.present();
    });

    app.run()
}
