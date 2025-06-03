import gleam/json

// ===== PROPS TYPES (with encoders) =====

pub type HomePageProp {
  Title(title: String)
  Message(message: String)
  Features(features: List(String))
}

pub fn encode_home_page_prop(prop: HomePageProp) -> json.Json {
  case prop {
    Title(title) -> json.string(title)
    Message(message) -> json.string(message)
    Features(features) -> json.array(features, json.string)
  }
}