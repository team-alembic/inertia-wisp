import gleam/int
import inertia_wisp/inertia
import props
import wisp

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
  |> inertia.always_prop(props.user_auth(props.authenticated_user("demo_user")))
  |> inertia.always_prop(props.user_csrf_token("abc123xyz"))
}

/// Assign common auth and CSRF props for UploadProps
pub fn assign_upload_common_props(context: inertia.InertiaContext(props.UploadProps)) {
  context
  |> inertia.always_prop(props.upload_auth(props.authenticated_user("demo_user")))
  |> inertia.always_prop(props.upload_csrf_token("abc123xyz"))
}
