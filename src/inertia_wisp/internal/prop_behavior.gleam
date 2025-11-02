//// Behavior types for Inertia props in the v2 API.
////
//// This module defines how props should be evaluated and included in responses:
//// - DefaultBehavior: Included in standard visits, optionally in partial reloads
//// - LazyBehavior: Evaluated on-demand when needed
//// - OptionalBehavior: Only included when explicitly requested
//// - AlwaysBehavior: Always included, even in partial reloads
//// - DeferBehavior: Loaded in a separate request from the client

import gleam/dict.{type Dict}
import gleam/option.{type Option}

/// Defines how a prop should be evaluated and included in responses
pub type PropBehavior(props) {
  /// Default behavior: Included in standard visits, optionally in partial reloads
  /// No resolver needed - uses value from prop_data
  DefaultBehavior

  /// Lazy evaluation: Evaluated on-demand for standard visits and when requested in partial reloads
  /// Resolver is called with current props and returns updated props
  LazyBehavior(resolver: fn(props) -> Result(props, Dict(String, String)))

  /// Optional: Only included when explicitly requested in partial reloads
  /// Never included in standard visits
  OptionalBehavior

  /// Always included: Present in all responses, including partial reloads
  /// Even when not explicitly requested
  AlwaysBehavior

  /// Deferred: Loaded in a separate request sent from the client
  /// Can be grouped to fetch multiple deferred props in one request
  DeferBehavior(
    group: Option(String),
    resolver: fn(props) -> Result(props, Dict(String, String)),
  )
}

/// Options for client-side prop merging
pub type MergeOptions {
  MergeOptions(
    /// List of attribute names to match existing items for updates
    /// e.g., ["id"] will match items by their id field
    match_on: Option(List(String)),
    /// Whether to use deep merging (nested object merging)
    deep: Bool,
  )
}
