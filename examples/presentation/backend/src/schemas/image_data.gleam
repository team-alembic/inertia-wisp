import inertia_wisp/schema

/// Image data for ImageRow
pub type ImageData {
  ImageData(url: String, alt: String, width: Int)
}

/// Schema for ImageData type
pub fn image_data_schema() -> schema.RecordSchema(_) {
  schema.record_schema("ImageData", ImageData(url: "", alt: "", width: 0))
  |> schema.string_field("url")
  |> schema.string_field("alt")
  |> schema.int_field("width")
  |> schema.schema()
}
