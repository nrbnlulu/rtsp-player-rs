use gst::{Element, ElementFactory};

pub fn make_gs_element(factory_name: &str) -> anyhow::Result<Element> {
    Ok(ElementFactory::make(factory_name).build()?)
}

pub fn make_named_element(factory_name: &str, name: &str) -> anyhow::Result<Element> {
    Ok(ElementFactory::make(factory_name)
        .property("name", name)
        .build()?)
}
