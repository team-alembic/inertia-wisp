import gleam/dynamic/decode
import gleam/int
import gleam/json
import inertia_wisp/inertia
import wisp

pub fn require_json(
  ctx: inertia.InertiaContext,
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

// Common authentication and CSRF props used across all handlers
pub fn assign_common_props(context) {
  context
  |> inertia.assign_always_props([
    #(
      "auth",
      json.object([
        #("authenticated", json.bool(True)),
        #("user", json.string("demo_user")),
      ]),
    ),
    #("csrf_token", json.string("abc123xyz")),
  ])
}
