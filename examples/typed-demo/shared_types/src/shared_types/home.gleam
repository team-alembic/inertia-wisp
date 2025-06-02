import gleam/json
import inertia_wisp/inertia

// ===== PROPS TYPES (with encoders) =====

pub type HomePageProps {
  HomePageProps(title: String, message: String, features: List(String))
}

pub fn encode_home_page_props(props: HomePageProps) -> json.Json {
  json.object([
    #("title", json.string(props.title)),
    #("message", json.string(props.message)),
    #("features", json.array(props.features, json.string)),
  ])
}

/// Zero value for Home Page Props
pub const zero_home_page_props = HomePageProps(
  title: "",
  message: "",
  features: [],
)

@target(erlang)
/// Use Home Page Props for the current InertiaJS handler
pub fn with_home_page_props(
  ctx: inertia.InertiaContext(inertia.EmptyProps),
) -> inertia.InertiaContext(HomePageProps) {
  ctx
  |> inertia.set_props(zero_home_page_props, encode_home_page_props)
}

//prop assignment functions. Generates tuples for use with inertia.prop
pub fn title(t: String) {
  #("title", fn(p) { HomePageProps(..p, title: t) })
}

pub fn message(m: String) {
  #("message", fn(p) { HomePageProps(..p, message: m) })
}

pub fn features(f: fn() -> List(String)) {
  #("features", fn(p) { HomePageProps(..p, features: f()) })
}
