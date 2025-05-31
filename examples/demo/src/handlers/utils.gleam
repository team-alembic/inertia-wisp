import gleam/dynamic/decode
import gleam/int
import gleam/json
import inertia_wisp/inertia
import props
import wisp

pub fn require_json(
  ctx: inertia.InertiaContext(inertia.EmptyProps),
  decoder: decode.Decoder(a),
  cont: fn(a) -> wisp.Response,
) -> wisp.Response {
  use json_data <- wisp.require_json(ctx.request)
  let result = decode.run(json_data, decoder)
  case result {
    Ok(value) -> cont(value)
    Error(_) -> wisp.bad_request()
  }
}

pub fn require_int(
  param: String,
  cont: fn(Int) -> wisp.Response,
) -> wisp.Response {
  case int.parse(param) {
    Ok(value) -> cont(value)
    Error(_) -> wisp.not_found()
  }
}

// Helper functions for common authentication and CSRF props for each prop type

/// Assign common auth and CSRF props for UserProps
pub fn assign_user_common_props(context: inertia.InertiaContext(props.UserProps)) {
  context
  |> inertia.assign_always_prop("auth", fn(props) {
    props.UserProps(..props, auth: json.object([
      #("authenticated", json.bool(True)),
      #("user", json.string("demo_user")),
    ]))
  })
  |> inertia.assign_always_prop("csrf_token", fn(props) {
    props.UserProps(..props, csrf_token: "abc123xyz")
  })
}

/// Assign common auth and CSRF props for UploadProps
pub fn assign_upload_common_props(context: inertia.InertiaContext(props.UploadProps)) {
  context
  |> inertia.assign_always_prop("auth", fn(props) {
    props.UploadProps(..props, auth: json.object([
      #("authenticated", json.bool(True)),
      #("user", json.string("demo_user")),
    ]))
  })
  |> inertia.assign_always_prop("csrf_token", fn(props) {
    props.UploadProps(..props, csrf_token: "abc123xyz")
  })
}
