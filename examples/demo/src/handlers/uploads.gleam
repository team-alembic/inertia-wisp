import gleam/json
import gleam/list
import gleam/string
import handlers/utils
import inertia_wisp/inertia
import props
import simplifile
import wisp

pub fn upload_form_page(ctx: inertia.InertiaContext(inertia.EmptyProps)) -> wisp.Response {
  // Create initial props
  let initial_props = props.UploadProps(
    auth: props.unauthenticated_user(),
    csrf_token: "",
    max_files: 0,
    max_size_mb: 0,
    success: "",
    uploaded_files: json.null(),
  )

  // Transform to typed context
  ctx
  |> inertia.set_props(initial_props, props.encode_upload_props)
  |> utils.assign_upload_common_props()
  |> inertia.prop(props.upload_max_files(3))
  |> inertia.prop(props.upload_max_size_mb(5))
  |> inertia.render("UploadForm")
}

pub fn handle_upload(ctx: inertia.InertiaContext(inertia.EmptyProps)) -> wisp.Response {
  use form_data <- wisp.require_form(ctx.request)

  // Create initial props
  let initial_props = props.UploadProps(
    auth: props.unauthenticated_user(),
    csrf_token: "",
    max_files: 0,
    max_size_mb: 0,
    success: "",
    uploaded_files: json.null(),
  )

  let uploaded_files_data = json.object(
    form_data.files
    |> list.map(fn(file) {
      let uploaded_file = file.1
      let file_size = get_file_size(uploaded_file.path)
      let content_type =
        get_content_type_from_filename(uploaded_file.file_name)

      #(
        file.0,
        json.object([
          #("filename", json.string(uploaded_file.file_name)),
          #("size", json.int(file_size)),
          #("content_type", json.string(content_type)),
        ]),
      )
    }),
  )

  // Transform to typed context
  ctx
  |> inertia.set_props(initial_props, props.encode_upload_props)
  |> utils.assign_upload_common_props()
  |> inertia.prop(props.upload_success("Success!"))
  |> inertia.prop(props.upload_uploaded_files(uploaded_files_data))
  |> inertia.render("UploadSuccess")
}

fn get_file_size(file_path: String) -> Int {
  case simplifile.file_info(file_path) {
    Ok(info) -> info.size
    Error(_) -> 0
  }
}

fn get_content_type_from_filename(filename: String) -> String {
  case string.split(filename, ".") |> list.last() {
    Ok(extension) -> {
      case string.lowercase(extension) {
        "jpg" | "jpeg" -> "image/jpeg"
        "png" -> "image/png"
        "gif" -> "image/gif"
        "webp" -> "image/webp"
        "svg" -> "image/svg+xml"
        "pdf" -> "application/pdf"
        "txt" -> "text/plain"
        "html" -> "text/html"
        "css" -> "text/css"
        "js" -> "application/javascript"
        "json" -> "application/json"
        "xml" -> "application/xml"
        "zip" -> "application/zip"
        "mp4" -> "video/mp4"
        "mp3" -> "audio/mpeg"
        "wav" -> "audio/wav"
        _ -> "application/octet-stream"
      }
    }
    Error(_) -> "application/octet-stream"
  }
}

pub fn progress_endpoint(_ctx: inertia.InertiaContext(inertia.EmptyProps)) -> wisp.Response {
  // This would be used for upload progress tracking
  // In a real implementation, you might track upload progress in a cache/database
  // and return the current progress as JSON

  let progress_data =
    json.object([
      #("uploaded", json.int(0)),
      #("total", json.int(0)),
      #("percent", json.int(0)),
      #("status", json.string("waiting")),
    ])

  wisp.json_response(json.to_string_tree(progress_data), 200)
}
