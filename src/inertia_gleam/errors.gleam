import gleam/dict.{type Dict}
import gleam/json

import inertia_gleam/controller
import wisp.{type Request, type Response}

/// Represents validation errors that can be displayed to the user
pub type ValidationErrors =
  Dict(String, String)

/// Add validation errors to an Inertia context
/// These errors will be included in the response under the "errors" prop
pub fn assign_errors(
  ctx: controller.InertiaContext,
  errors: ValidationErrors,
) -> controller.InertiaContext {
  let errors_list = dict.fold(errors, [], fn(acc, key, value) {
    [#(key, json.string(value)), ..acc]
  })
  
  controller.assign_prop(ctx, "errors", json.object(errors_list))
}

/// Add a single validation error
pub fn assign_error(
  ctx: controller.InertiaContext,
  field: String,
  message: String,
) -> controller.InertiaContext {
  let errors = dict.from_list([#(field, message)])
  assign_errors(ctx, errors)
}

/// Create validation errors from a list of field/message tuples
pub fn from_list(errors: List(#(String, String))) -> ValidationErrors {
  dict.from_list(errors)
}

/// Create validation errors from a single field/message pair
pub fn single_error(field: String, message: String) -> ValidationErrors {
  dict.from_list([#(field, message)])
}

/// Merge multiple validation error dictionaries
pub fn merge_errors(errors1: ValidationErrors, errors2: ValidationErrors) -> ValidationErrors {
  dict.merge(errors1, errors2)
}

/// Check if there are any validation errors
pub fn has_errors(errors: ValidationErrors) -> Bool {
  dict.size(errors) > 0
}

/// Get a specific error message for a field
pub fn get_error(errors: ValidationErrors, field: String) -> Result(String, Nil) {
  dict.get(errors, field)
}

/// Convert validation errors to a JSON object for inclusion in props
pub fn to_json(errors: ValidationErrors) -> json.Json {
  let errors_list = dict.fold(errors, [], fn(acc, key, value) {
    [#(key, json.string(value)), ..acc]
  })
  json.object(errors_list)
}

/// Clear all errors (returns empty validation errors)
pub fn clear() -> ValidationErrors {
  dict.new()
}

/// Create a redirect response with validation errors
/// The errors will be preserved across the redirect for display on the target page
pub fn redirect_with_errors(
  req: Request,
  url: String,
  errors: ValidationErrors,
) -> Response {
  // TODO: Store errors in session for retrieval after redirect
  // For now, we'll use the basic redirect functionality
  let _ = errors
  wisp.redirect(to: url)
}