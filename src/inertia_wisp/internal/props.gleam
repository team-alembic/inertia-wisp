//// Evaluates prop behaviors and filters fields for Inertia responses.

import gleam/dict.{type Dict}
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/result
import inertia_wisp/internal/prop_behavior.{
  type PropBehavior, AlwaysBehavior, DefaultBehavior, LazyBehavior,
  OptionalBehavior,
}

/// Props that should be included in the response
///
/// For partial reloads: requested props + always props
/// For full visits: all props except optional and deferred
pub fn to_include(
  behaviors: Dict(String, PropBehavior(props)),
  partial_data: Option(List(String)),
) -> List(String) {
  let predicate = case partial_data {
    Some(requested) -> fn(name, behavior) {
      include_in_partial(requested, name, behavior)
    }
    None -> fn(_name, behavior) { include_in_initial(behavior) }
  }

  behaviors
  |> dict.filter(predicate)
  |> dict.keys()
}

/// Run resolver functions for lazy and deferred props
///
/// Resolvers are executed in sequence, threading props through each evaluation.
/// Returns updated props or a dictionary of errors if any resolver fails.
pub fn resolve(
  initial_props: props,
  behaviors: Dict(String, PropBehavior(props)),
  fields_to_evaluate: List(String),
) -> Result(props, Dict(String, String)) {
  let resolvers = {
    use prop_name <- list.filter_map(fields_to_evaluate)
    behaviors |> get_behavior(prop_name) |> prop_resolver()
  }

  list.try_fold(resolvers, initial_props, fn(props, resolver) {
    resolver(props)
  })
}

/// Filter props dict based on behaviors and partial reload requirements
///
/// Props without behaviors are included by default.
/// For partial reloads: only includes requested props + always props
/// For full visits: excludes optional and deferred props
pub fn filter(
  props_dict: Dict(String, value),
  behaviors: Dict(String, PropBehavior(props)),
  partial_data: Option(List(String)),
) -> Dict(String, value) {
  let predicate = case partial_data {
    // Partial reload
    Some(requested) -> fn(key, _value) {
      let behavior = get_behavior(behaviors, key)
      include_in_partial(requested, key, behavior)
    }
    // Full visit
    None -> fn(key, _value) {
      let behavior = get_behavior(behaviors, key)
      include_in_initial(behavior)
    }
  }

  dict.filter(props_dict, predicate)
}

/// Check if behavior should be included in initial (full) visits
fn include_in_initial(behavior: PropBehavior(_)) -> Bool {
  case behavior {
    OptionalBehavior | prop_behavior.DeferBehavior(_, _) -> False
    _ -> True
  }
}

/// Check if behavior should be included in partial reloads
fn include_in_partial(
  requested: List(String),
  name: String,
  behavior: PropBehavior(_),
) -> Bool {
  behavior == AlwaysBehavior || list.contains(requested, name)
}

/// Extract resolver function from behaviors that have one
fn prop_resolver(
  behavior: PropBehavior(props),
) -> Result(fn(props) -> Result(props, Dict(String, String)), Nil) {
  case behavior {
    LazyBehavior(resolver) | prop_behavior.DeferBehavior(_, resolver) ->
      Ok(resolver)
    _ -> Error(Nil)
  }
}

/// Get the behaviour for a prop, fallback to DefaultBehavior
fn get_behavior(behaviors: Dict(String, PropBehavior(_)), prop: String) {
  behaviors
  |> dict.get(prop)
  |> result.unwrap(DefaultBehavior)
}
