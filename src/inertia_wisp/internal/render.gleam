//// Render Inertia responses as JSON or HTML.
////
//// This module handles converting Inertia response data into HTTP responses,
//// either as JSON (for XHR requests) or HTML (for initial page loads).

import gleam/json
import inertia_wisp/internal/protocol
import wisp.{type Response}

/// Render as JSON response for Inertia XHR requests
///
/// Adds Inertia-specific headers and returns JSON with the given status code.
pub fn json(response_json: json.Json, status: Int) -> Response {
  json.to_string(response_json)
  |> wisp.json_response(status)
  |> protocol.add_inertia_headers()
}

/// Render as HTML response for initial page loads
///
/// Uses the provided layout function to generate the HTML document.
/// The layout function receives the component name and the Inertia page data as JSON.
pub fn html(
  response_json: json.Json,
  component_name: String,
  status: Int,
  layout: fn(String, json.Json) -> String,
) -> Response {
  let html_content = layout(component_name, response_json)
  wisp.html_response(html_content, status)
}
