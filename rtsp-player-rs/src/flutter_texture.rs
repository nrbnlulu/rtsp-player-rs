// inspired by https://github.com/momentobooth/momentobooth/blob/main/rust/src/utils/flutter_texture.rs
use crate::models::images::RawImage;
use libloading::{
    Library, Symbol, Error as LibError
};
use log::error;
use std::ffi::{c_int, c_void};
use std::sync::LazyLock;

#[cfg(all(target_os = "linux"))]
pub static TEXTURE_RGBA_RENDERER_PLUGIN: LazyLock<Result<Library, LibError>> =
    LazyLock::new(|| unsafe { libloading::Library::new("libtexture_rgba_renderer_plugin.so") });

#[cfg(all(target_os = "windows"))]
pub static TEXTURE_RGBA_RENDERER_PLUGIN: LazyLock<Result<Library, LibError>> =
    LazyLock::new(|| unsafe { libloading::Library::new("texture_rgba_renderer_plugin.dll") });

#[cfg(all(target_os = "macos"))]
pub static TEXTURE_RGBA_RENDERER_PLUGIN: LazyLock<Result<Library, LibError>> =
    LazyLock::new(|| unsafe { libloading::Library::new("libtexture_rgba_renderer_plugin.dylib") });

pub type FlutterRgbaRendererPluginOnRgba = unsafe extern "C" fn(
    texture_rgba: *mut c_void,
    buffer: *const u8,
    len: c_int,
    width: c_int,
    height: c_int,
    dst_rgba_stride: c_int,
);

#[derive(Clone)]
pub struct FlutterTexture {
    pub ptr: usize, // TextureRgba pointer in flutter native.
    width: u32,
    height: u32,
    on_rgba_func: Option<Symbol<'static, FlutterRgbaRendererPluginOnRgba>>,
}

impl FlutterTexture {
    pub fn new(ptr: usize, width: u32, height: u32) -> Self {
        let on_rgba_func = match &*TEXTURE_RGBA_RENDERER_PLUGIN {
            Ok(lib) => {
                let find_sym_res = unsafe {
                    lib.get::<FlutterRgbaRendererPluginOnRgba>(b"FlutterRgbaRendererPluginOnRgba")
                };
                match find_sym_res {
                    Ok(sym) => Some(sym),
                    Err(error) => {
                        error!(
                            "Failed to find symbol FlutterRgbaRendererPluginOnRgba: {}",
                            &error
                        );
                        None
                    }
                }
            }
            Err(error) => {
                error!("Failed to load texture rgba renderer plugin: {}", &error);
                None
            }
        };
        Self {
            ptr,
            width,
            height,
            on_rgba_func,
        }
    }
}

impl FlutterTexture {
    pub fn set_size(&mut self, width: u32, height: u32) {
        self.width = width;
        self.height = height;
    }

    pub fn on_rgba(&self, raw_image: &RawImage) {
        if self.ptr == usize::default() {
            return;
        }

        if self.width != raw_image.width || self.height != raw_image.height {
            return;
        }

        if let Some(func) = &self.on_rgba_func {
            unsafe {
                func(
                    self.ptr as _,
                    raw_image.data.as_ptr() as _,
                    raw_image.data.len() as _,
                    raw_image.width as _,
                    raw_image.height as _,
                    0,
                )
            };
        }
    }
}
