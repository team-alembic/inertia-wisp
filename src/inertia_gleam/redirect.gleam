import inertia_gleam/middleware
import wisp.{type Request, type Response}

/// Create a redirect response that works with both regular browsers and Inertia XHR requests.
/// 
/// For regular browser requests, this returns a standard 303 redirect.
/// For Inertia XHR requests, this returns a 409 Conflict with X-Inertia-Location header,
/// which tells the Inertia client to perform a client-side redirect.
pub fn redirect(req: Request, to url: String) -> Response {
  case middleware.is_inertia_request(req) {
    True -> inertia_redirect(url)
    False -> browser_redirect(url)
  }
}

/// Create an external redirect that forces a full page reload.
/// 
/// This is useful when you need to redirect to an external URL or force
/// a full page reload regardless of whether it's an Inertia request.
pub fn external_redirect(to url: String) -> Response {
  wisp.response(409)
  |> wisp.set_header("x-inertia-location", url)
}

/// Create a redirect for Inertia XHR requests.
/// Returns 409 Conflict with X-Inertia-Location header.
fn inertia_redirect(url: String) -> Response {
  wisp.response(409)
  |> wisp.set_header("x-inertia-location", url)
  |> wisp.set_header("x-inertia", "true")
}

/// Create a standard browser redirect.
/// Returns 303 See Other with Location header.
fn browser_redirect(url: String) -> Response {
  wisp.response(303)
  |> wisp.set_header("location", url)
}

/// Create a redirect after a successful form submission.
/// This is a convenience function that adds appropriate headers for form submissions.
pub fn redirect_after_form(req: Request, to url: String) -> Response {
  redirect(req, url)
  |> wisp.set_header("vary", "X-Inertia")
}

/// Create a redirect with a success flash message.
/// Note: Flash message handling will be implemented in a separate module.
pub fn redirect_with_success(req: Request, url: String, _message: String) -> Response {
  // TODO: Implement flash message storage
  redirect(req, url)
}

/// Create a redirect with an error flash message.
/// Note: Flash message handling will be implemented in a separate module.
pub fn redirect_with_error(req: Request, url: String, _message: String) -> Response {
  // TODO: Implement flash message storage
  redirect(req, url)
}