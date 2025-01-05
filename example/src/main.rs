use gtk::{glib::ExitCode, prelude::*};
use rtsp_player_rs::init_gst;
mod glarea;

fn main() -> ExitCode {
    let app = gtk::Application::builder()
        .application_id("org.example.HelloWorld")
        .build();
    app.connect_activate(|app| {
        init_gst().unwrap();

        // We create the main window.

        let window = gtk::ApplicationWindow::builder()
            .application(app)
            .default_width(800)
            .default_height(600)
            .title("Hello, World!")
            .build();

        window.set_child(Some(&widget));
        // Show the window.
        window.present();
    });

    app.run()
}

