import gleam/dict.{type Dict}
import gleam/json

import inertia_gleam/controller
import inertia_gleam/types.{type InertiaContext}

/// Represents validation errors that can be displayed to the user
pub type ValidationErrors =
  Dict(String, String)

/// Add validation errors to an Inertia context
/// These errors will be included in the response under the "errors" prop
pub fn assign_errors(
  ctx: InertiaContext,
  errors: ValidationErrors,
) -> InertiaContext {
  let errors_list =
    dict.fold(errors, [], fn(acc, key, value) {
      [#(key, json.string(value)), ..acc]
    })

  controller.assign_prop(ctx, "errors", json.object(errors_list))
}

/// Add a single validation error
pub fn assign_error(
  ctx: InertiaContext,
  field: String,
  message: String,
) -> InertiaContext {
  let errors = dict.from_list([#(field, message)])
  assign_errors(ctx, errors)
}

/// Convert validation errors to a JSON object for inclusion in props
pub fn to_json(errors: ValidationErrors) -> json.Json {
  let errors_list =
    dict.fold(errors, [], fn(acc, key, value) {
      [#(key, json.string(value)), ..acc]
    })
  json.object(errors_list)
}
