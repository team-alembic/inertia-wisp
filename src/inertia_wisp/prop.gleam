
import gleam/dict
import gleam/option

/// Inertia Prop types for Resolvers
pub type Prop(p) {
  /// ALWAYS included on standard visits
  /// OPTIONALLY included on partial reloads
  /// ALWAYS evaluated
  DefaultProp(name: String, value: p)

  /// ALWAYS included on standard visits
  /// OPTIONALLY included on partial reloads
  /// ONLY evaluated when needed
  LazyProp(name: String, resolver: fn() -> Result(p, dict.Dict(String, String)))

  /// NEVER included on standard visits
  /// OPTIONALLY included on partial reloads
  /// ONLY evaluated when needed
  OptionalProp(
    name: String,
    resolver: fn() -> Result(p, dict.Dict(String, String)),
  )

  /// ALWAYS included on standard visits
  /// ALWAYS included on partial reloads
  /// ALWAYS evaluated
  AlwaysProp(name: String, value: p)

  /// A LazyProp fetched in a separate request sent from the client
  /// A group name can be optionally supplied to fetch deferred props in multiple separate requests.
  DeferProp(
    name: String,
    group: option.Option(String),
    resolver: fn() -> Result(p, dict.Dict(String, String)),
  )

  /// Indicates that a Prop should be merged client-side
  /// During the merging process, if the value is an array, the incoming items will be appended to the existing array, not merged by index.
  /// However, you may provide a list of attribute names in `match_on` to determine how existing items should be matched and updated.
  /// The `deep` flag indicates whether deep merging should be used.
  MergeProp(prop: Prop(p), match_on: option.Option(List(String)), deep: Bool)
}
