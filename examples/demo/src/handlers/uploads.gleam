import gleam/json
import gleam/list
import gleam/string
import handlers/utils
import inertia_wisp
import simplifile
import wisp

pub fn upload_form_page(req: inertia_wisp.InertiaContext) -> wisp.Response {
  req
  |> utils.assign_common_props()
  |> inertia_wisp.assign_prop("max_files", json.int(3))
  |> inertia_wisp.assign_prop("max_size_mb", json.int(5))
  |> inertia_wisp.render("UploadForm")
}

pub fn handle_upload(req: inertia_wisp.InertiaContext) -> wisp.Response {
  use form_data <- wisp.require_form(req.request)

  req
  |> utils.assign_common_props()
  |> inertia_wisp.assign_prop("success", json.string("Success!"))
  |> inertia_wisp.assign_prop(
    "uploaded_files",
    json.object(
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
    ),
  )
  |> inertia_wisp.render("UploadSuccess")
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

pub fn progress_endpoint(_req: inertia_wisp.InertiaContext) -> wisp.Response {
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
