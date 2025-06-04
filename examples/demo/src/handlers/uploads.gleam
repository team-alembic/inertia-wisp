import gleam/dict
import gleam/json
import gleam/list
import gleam/string
import handlers/utils
import inertia_wisp/inertia
import shared_types/uploads
import simplifile
import wisp

pub fn upload_form_page(ctx: inertia.InertiaContext(Nil)) -> wisp.Response {
  ctx
  |> inertia.with_encoder(uploads.encode_upload_page_prop)
  |> inertia.always_prop("auth", uploads.Auth(utils.get_demo_auth()))
  |> inertia.always_prop(
    "csrf_token",
    uploads.CsrfToken(utils.get_csrf_token()),
  )
  |> inertia.prop("max_files", uploads.MaxFiles(3))
  |> inertia.prop("max_size_mb", uploads.MaxSizeMb(5))
  |> inertia.render("UploadForm")
}

pub fn handle_upload(ctx: inertia.InertiaContext(Nil)) -> wisp.Response {
  use form_data <- wisp.require_form(ctx.request)

  let uploaded_files_data =
    form_data.files
    |> list.map(process_uploaded_file)
    |> dict.from_list()

  ctx
  |> inertia.with_encoder(uploads.encode_upload_page_prop)
  |> inertia.always_prop("auth", uploads.Auth(utils.get_demo_auth()))
  |> inertia.always_prop(
    "csrf_token",
    uploads.CsrfToken(utils.get_csrf_token()),
  )
  |> inertia.prop("success", uploads.Success("Files uploaded successfully!"))
  |> inertia.prop("uploaded_files", uploads.UploadedFiles(uploaded_files_data))
  |> inertia.render("UploadSuccess")
}

fn process_uploaded_file(
  file: #(String, wisp.UploadedFile),
) -> #(String, uploads.UploadedFile) {
  let uploaded_file = file.1
  let file_size = get_file_size(uploaded_file.path)
  let content_type = get_content_type_from_filename(uploaded_file.file_name)

  #(
    file.0,
    uploads.UploadedFile(
      filename: uploaded_file.file_name,
      size: file_size,
      content_type: content_type,
    ),
  )
}

fn get_content_type_from_filename(filename: String) -> String {
  case
    list.find(file_extensions, fn(ext_pair) {
      let #(exts, _) = ext_pair
      list.any(exts, fn(ext) { filename |> string.ends_with(ext) })
    })
  {
    Ok(#(_, content_type)) -> content_type
    Error(_) -> "application/octet-stream"
  }
}

const file_extensions = [
  #([".jpg", ".jpeg"], "image/jpeg"),
  #([".png"], "image/png"),
  #([".pdf"], "application/pdf"),
  #([".txt"], "text/plain"),
  #([".mp4"], "video/mp4"),
]

fn get_file_size(file_path: String) -> Int {
  case simplifile.file_info(file_path) {
    Ok(info) -> info.size
    Error(_) -> 0
  }
}

pub fn progress_endpoint(_ctx: inertia.InertiaContext(Nil)) -> wisp.Response {
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
