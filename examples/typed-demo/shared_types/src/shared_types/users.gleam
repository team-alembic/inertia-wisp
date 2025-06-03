import gleam/dynamic/decode
import gleam/json
import gleam/option

// ===== DOMAIN TYPES =====

pub type UserProfile {
  UserProfile(
    name: String,
    email: String,
    id: Int,
    interests: List(String),
    bio: String,
  )
}

pub fn encode_user_profile(profile: UserProfile) -> json.Json {
  json.object([
    #("name", json.string(profile.name)),
    #("email", json.string(profile.email)),
    #("id", json.int(profile.id)),
    #("interests", json.array(profile.interests, json.string)),
    #("bio", json.string(profile.bio)),
  ])
}

// ===== PROPS TYPES (with encoders) =====

pub type UserProfilePageProp {
  UserProfileProp(user_profile: UserProfile)
}

pub fn encode_user_profile_page_prop(prop: UserProfilePageProp) -> json.Json {
  case prop {
    UserProfileProp(user_profile) -> encode_user_profile(user_profile)
  }
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
