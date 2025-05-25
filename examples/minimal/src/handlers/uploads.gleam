import gleam/dict
import gleam/int
import gleam/json
import handlers/utils
import inertia_gleam
import wisp

pub fn upload_form_page(req: wisp.Request) -> wisp.Response {
  inertia_gleam.context(req)
  |> utils.assign_common_props()
  |> inertia_gleam.assign_prop("max_files", json.int(3))
  |> inertia_gleam.assign_prop("max_size_mb", json.int(5))
  |> inertia_gleam.render("UploadForm")
}

pub fn handle_file_upload(req: wisp.Request) -> wisp.Response {
  let upload_config = inertia_gleam.upload_config(
    max_file_size: 5_000_000,  // 5MB
    allowed_types: ["image/jpeg", "image/png", "image/gif", "application/pdf"],
    max_files: 3
  )

  case inertia_gleam.get_uploaded_files(req, upload_config) {
    Ok(files) -> handle_successful_upload(req, files)
    Error(errors) -> handle_upload_errors(req, errors)
  }
}

fn handle_successful_upload(
  req: wisp.Request,
  files: dict.Dict(String, inertia_gleam.UploadedFile),
) -> wisp.Response {
  // In a real application, you would:
  // 1. Save files to disk or cloud storage
  // 2. Store file metadata in database
  // 3. Generate URLs for accessing the files

  let file_count = dict.size(files)
  let success_message = case file_count {
    1 -> "1 file uploaded successfully!"
    n -> int.to_string(n) <> " files uploaded successfully!"
  }

  inertia_gleam.context(req)
  |> utils.assign_common_props()
  |> inertia_gleam.assign_prop("success", json.string(success_message))
  |> inertia_gleam.assign_prop("uploaded_files", inertia_gleam.files_to_json(files))
  |> inertia_gleam.render("UploadSuccess")
}

fn handle_upload_errors(
  req: wisp.Request,
  errors: dict.Dict(String, String),
) -> wisp.Response {
  inertia_gleam.context(req)
  |> utils.assign_common_props()
  |> inertia_gleam.assign_errors(errors)
  |> inertia_gleam.assign_prop("max_files", json.int(3))
  |> inertia_gleam.assign_prop("max_size_mb", json.int(5))
  |> inertia_gleam.render("UploadForm")
}

pub fn progress_endpoint(_req: wisp.Request) -> wisp.Response {
  // This would be used for upload progress tracking
  // In a real implementation, you might track upload progress in a cache/database
  // and return the current progress as JSON
  
  let progress_data = json.object([
    #("uploaded", json.int(0)),
    #("total", json.int(0)),
    #("percent", json.int(0)),
    #("status", json.string("waiting"))
  ])

  wisp.json_response(json.to_string_tree(progress_data), 200)
}

