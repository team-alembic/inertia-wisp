//// Inertia.js adapter for the Gleam Wisp web framework.

import gleam/dict
import gleam/json
import gleam/option.{type Option}
import inertia_wisp/prop_behavior
import inertia_wisp/response_builder_v2
import wisp.{type Request, type Response}

// Re-export v2 Response Builder types
pub type InertiaResponseBuilder(props) =
  response_builder_v2.InertiaResponseBuilder(props)

pub type MergeOptions =
  prop_behavior.MergeOptions

// Response Builder API - delegates to v2
pub fn response_builder(
  req: Request,
  component: String,
) -> InertiaResponseBuilder(Nil) {
  response_builder_v2.response_builder(req, component)
}

pub fn props(
  builder: InertiaResponseBuilder(_),
  props: props,
  encode: fn(props) -> dict.Dict(String, json.Json),
) -> InertiaResponseBuilder(props) {
  response_builder_v2.props(builder, props, encode)
}

pub fn lazy(
  builder: InertiaResponseBuilder(props),
  field_name: String,
  resolver: fn(props) -> Result(props, dict.Dict(String, String)),
) -> InertiaResponseBuilder(props) {
  response_builder_v2.lazy(builder, field_name, resolver)
}

pub fn optional(
  builder: InertiaResponseBuilder(props),
  field_name: String,
) -> InertiaResponseBuilder(props) {
  response_builder_v2.optional(builder, field_name)
}

pub fn always(
  builder: InertiaResponseBuilder(props),
  field_name: String,
) -> InertiaResponseBuilder(props) {
  response_builder_v2.always(builder, field_name)
}

pub fn defer(
  builder: InertiaResponseBuilder(props),
  field_name: String,
  resolver: fn(props) -> Result(props, dict.Dict(String, String)),
) -> InertiaResponseBuilder(props) {
  response_builder_v2.defer(builder, field_name, resolver)
}

pub fn defer_in_group(
  builder: InertiaResponseBuilder(props),
  field_name: String,
  group: String,
  resolver: fn(props) -> Result(props, dict.Dict(String, String)),
) -> InertiaResponseBuilder(props) {
  response_builder_v2.defer_in_group(builder, field_name, group, resolver)
}

pub fn merge(
  builder: InertiaResponseBuilder(props),
  field_name: String,
  match_on: Option(List(String)),
  deep: Bool,
) -> InertiaResponseBuilder(props) {
  response_builder_v2.merge(builder, field_name, match_on, deep)
}

pub fn errors(
  builder: InertiaResponseBuilder(props),
  errors: dict.Dict(String, String),
) -> InertiaResponseBuilder(props) {
  response_builder_v2.errors(builder, errors)
}

pub fn redirect(builder: InertiaResponseBuilder(props), url: String) -> Response {
  response_builder_v2.redirect(builder, url)
}

pub fn on_error(
  builder: InertiaResponseBuilder(props),
  error_component: String,
) -> InertiaResponseBuilder(props) {
  response_builder_v2.on_error(builder, error_component)
}

pub fn clear_history(
  builder: InertiaResponseBuilder(props),
) -> InertiaResponseBuilder(props) {
  response_builder_v2.clear_history(builder)
}

pub fn encrypt_history(
  builder: InertiaResponseBuilder(props),
) -> InertiaResponseBuilder(props) {
  response_builder_v2.encrypt_history(builder)
}

pub fn version(
  builder: InertiaResponseBuilder(props),
  version: String,
) -> InertiaResponseBuilder(props) {
  response_builder_v2.version(builder, version)
}

pub fn response(builder: InertiaResponseBuilder(props), status: Int) -> Response {
  response_builder_v2.response(builder, status)
}
