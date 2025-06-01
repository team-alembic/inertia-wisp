import gleam/dynamic/decode
import gleam/json
import gleam/option
import inertia_wisp/inertia

// ===== PROPS TYPES (with encoders) =====

pub type UserProfilePageProps {
  UserProfilePageProps(
    name: String,
    email: String,
    id: Int,
    interests: option.Option(List(String)),
    bio: String,
  )
}

pub fn encode_user_profile_props(props: UserProfilePageProps) -> json.Json {
  json.object([
    #("name", json.string(props.name)),
    #("email", json.string(props.email)),
    #("id", json.int(props.id)),
    #(
      "interests",
      json.nullable(props.interests, of: json.array(_, json.string)),
    ),
    #("bio", json.string(props.bio)),
  ])
}

/// Zero value for User Profile Page Props
pub const zero_user_profile_page_props = UserProfilePageProps(
  name: "",
  email: "",
  id: 0,
  interests: option.None,
  bio: "",
)

@target(erlang)
/// Use User Profile Page Props for the current InertiaJS handler
pub fn with_user_profile_page_props(
  ctx: inertia.InertiaContext(inertia.EmptyProps),
) -> inertia.InertiaContext(UserProfilePageProps) {
  ctx
  |> inertia.set_props(zero_user_profile_page_props, encode_user_profile_props)
}

//prop assignment functions. Generates tuples for use with inertia.assign_prop_t
pub fn name(n: String) {
  #("name", fn(p) { UserProfilePageProps(..p, name: n) })
}

pub fn email(e: String) {
  #("email", fn(p) { UserProfilePageProps(..p, email: e) })
}

pub fn id(i: Int) {
  #("id", fn(p) { UserProfilePageProps(..p, id: i) })
}

pub fn interests(i: fn() -> option.Option(List(String))) {
  #("interests", fn(p) { UserProfilePageProps(..p, interests: i()) })
}

pub fn bio(b: String) {
  #("bio", fn(p) { UserProfilePageProps(..p, bio: b) })
}

// ===== REQUEST TYPES (with decoders) =====

pub type CreateUserRequest {
  CreateUserRequest(name: String, email: String, bio: option.Option(String))
}

pub fn create_user_request_decoder() -> decode.Decoder(CreateUserRequest) {
  use name <- decode.field("name", decode.string)
  use email <- decode.field("email", decode.string)
  use bio <- decode.optional_field(
    "bio",
    option.None,
    decode.optional(decode.string),
  )
  decode.success(CreateUserRequest(name:, email:, bio:))
}

pub type UpdateProfileRequest {
  UpdateProfileRequest(name: String, bio: String, interests: List(String))
}

pub fn update_profile_request_decoder() -> decode.Decoder(UpdateProfileRequest) {
  use name <- decode.field("name", decode.string)
  use bio <- decode.field("bio", decode.string)
  use interests <- decode.field("interests", decode.list(decode.string))
  decode.success(UpdateProfileRequest(name:, bio:, interests:))
}