import inertia_wisp/schema

/// Image data for ImageRow
pub type ImageData {
  ImageData(url: String, alt: String, width: Int)
}

/// Schema for ImageData type
pub fn image_data_schema() -> schema.RecordSchema {
  schema.record_schema("ImageData", ImageData(url: "", alt: "", width: 0))
  |> schema.string_field("url", fn(img: ImageData) { img.url }, fn(img, url) {
    ImageData(..img, url:)
  })
  |> schema.string_field("alt", fn(img: ImageData) { img.alt }, fn(img, alt) {
    ImageData(..img, alt:)
  })
  |> schema.int_field("width", fn(img: ImageData) { img.width }, fn(img, width) {
    ImageData(..img, width:)
  })
  |> schema.schema()
}
