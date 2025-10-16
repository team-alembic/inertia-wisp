//// Application specification that defines the contract between frontend and backend
////
//// This module provides types for declaring:
//// - Data schemas (types with encoders/decoders)
//// - Pages (React components with their props)
//// - Routes (backend endpoints that render pages)
//// - Parameters (route params and query params)

import gleam/dict.{type Dict}
import gleam/list
import gleam/option.{type Option}
import inertia_wisp/schema.{type RecordSchema}

/// Complete application specification
pub type Spec {
  Spec(
    schemas: List(RecordSchema),
    pages: List(PageDef),
    routes: List(RouteDef),
  )
}

/// Page definition - a frontend React component with typed props
pub type PageDef {
  PageDef(name: String, component_path: String, props: List(PropDef))
}

/// Prop definition - a single prop for a page
pub type PropDef {
  PropDef(name: String, schema_name: String, kind: PropKind)
}

/// The kind of prop determines how Inertia handles it
pub type PropKind {
  /// Always included in response
  DefaultProp
  /// Only included when explicitly requested
  LazyProp
  /// Loaded asynchronously after initial page load
  DeferredProp
  /// Included in every request (not cached)
  AlwaysProp
  /// Only included when explicitly requested
  OptionalProp
  /// Merged with existing prop value
  MergeProp(deep: Bool)
}

/// Route definition - a backend endpoint
pub type RouteDef {
  RouteDef(
    name: String,
    path: String,
    method: HttpMethod,
    params: List(ParamDef),
    query_params: List(ParamDef),
    body: Option(String),
    page: String,
  )
}

/// HTTP methods
pub type HttpMethod {
  GET
  POST
  PUT
  PATCH
  DELETE
}

/// Parameter definition for route params or query params
pub type ParamDef {
  ParamDef(name: String, param_type: ParamType)
}

/// Type of parameter
pub type ParamType {
  StringParam
  IntParam
  FloatParam
  BoolParam
  UUIDParam
}

/// Create a new empty specification
pub fn new() -> Spec {
  Spec(schemas: [], pages: [], routes: [])
}

/// Add schemas to the specification
pub fn with_schemas(spec: Spec, schemas: List(RecordSchema)) -> Spec {
  Spec(..spec, schemas: schemas)
}

/// Add pages to the specification
pub fn with_pages(spec: Spec, pages: List(PageDef)) -> Spec {
  Spec(..spec, pages: pages)
}

/// Add routes to the specification
pub fn with_routes(spec: Spec, routes: List(RouteDef)) -> Spec {
  Spec(..spec, routes: routes)
}

/// Build a schema lookup by name
pub fn schema_map(spec: Spec) -> Dict(String, RecordSchema) {
  spec.schemas
  |> list_to_dict(fn(s) { #(s.name, s) })
}

/// Build a page lookup by name
pub fn page_map(spec: Spec) -> Dict(String, PageDef) {
  spec.pages
  |> list_to_dict(fn(p) { #(p.name, p) })
}

/// Build a route lookup by name
pub fn route_map(spec: Spec) -> Dict(String, RouteDef) {
  spec.routes
  |> list_to_dict(fn(r) { #(r.name, r) })
}

fn list_to_dict(list: List(a), key_fn: fn(a) -> #(String, a)) -> Dict(String, a) {
  list
  |> list.fold(dict.new(), fn(acc, item) {
    let #(key, value) = key_fn(item)
    dict.insert(acc, key, value)
  })
}
