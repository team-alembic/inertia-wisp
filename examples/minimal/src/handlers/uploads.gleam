import gleam/json
import handlers/utils
import inertia_gleam
import wisp

pub fn upload_form_page(req: inertia_gleam.InertiaContext) -> wisp.Response {
  req
  |> utils.assign_common_props()
  |> inertia_gleam.assign_prop("max_files", json.int(3))
  |> inertia_gleam.assign_prop("max_size_mb", json.int(5))
  |> inertia_gleam.render("UploadForm")
}

pub fn progress_endpoint(_req: inertia_gleam.InertiaContext) -> wisp.Response {
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
