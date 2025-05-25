import wisp.{type Request, type Response}

/// Create a redirect response that works with both regular browsers and Inertia XHR requests.
/// 
/// For both regular browser requests and Inertia XHR requests, this returns a standard 303 redirect
/// with Location header, as per the Inertia.js specification.
pub fn redirect(_req: Request, to url: String) -> Response {
  browser_redirect(url)
  |> wisp.set_header("vary", "X-Inertia")
}

/// Create an external redirect that forces a full page reload.
/// 
/// This is useful when you need to redirect to an external URL or force
/// a full page reload regardless of whether it's an Inertia request.
pub fn external_redirect(to url: String) -> Response {
  wisp.response(409)
  |> wisp.set_header("x-inertia-location", url)
}



/// Create a standard browser redirect.
/// Returns 303 See Other with Location header.
fn browser_redirect(url: String) -> Response {
  wisp.response(303)
  |> wisp.set_header("location", url)
}

/// Create a redirect after a successful form submission.
/// This is a convenience function that uses the standard redirect behavior.
pub fn redirect_after_form(req: Request, to url: String) -> Response {
  redirect(req, url)
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