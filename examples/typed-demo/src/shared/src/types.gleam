import gleam/dict
import gleam/dynamic/decode
import gleam/json
import gleam/option

// User profile page props
pub type UserProfilePageProps {
  UserProfilePageProps(
    name: String,
    email: String,
    id: Int,
    interests: option.Option(List(String)),
    bio: String,
  )
}

// Encoder for UserProfilePageProps
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

// Blog post page props
pub type BlogPostPageProps {
  BlogPostPageProps(
    title: String,
    content: String,
    author: String,
    published_at: String,
    tags: List(String),
    view_count: option.Option(Int),
  )
}

// Encoder for BlogPostPageProps
pub fn encode_blog_post_props(props: BlogPostPageProps) -> json.Json {
  json.object([
    #("title", json.string(props.title)),
    #("content", json.string(props.content)),
    #("author", json.string(props.author)),
    #("published_at", json.string(props.published_at)),
    #("tags", json.array(props.tags, json.string)),
    #("view_count", json.nullable(props.view_count, json.int)),
  ])
}

// Dashboard page props
pub type DashboardPageProps {
  DashboardPageProps(
    user_count: Int,
    post_count: Int,
    recent_signups: option.Option(List(String)),
    system_status: String,
  )
}

// Encoder for DashboardPageProps
pub fn encode_dashboard_props(props: DashboardPageProps) -> json.Json {
  json.object([
    #("user_count", json.int(props.user_count)),
    #("post_count", json.int(props.post_count)),
    #(
      "recent_signups",
      json.nullable(props.recent_signups, json.array(_, json.string)),
    ),
    #("system_status", json.string(props.system_status)),
  ])
}

// Home page props
pub type HomePageProps {
  HomePageProps(title: String, message: String, features: List(String))
}

pub fn home_page_props_decoder() -> decode.Decoder(HomePageProps) {
  use title <- decode.field("title", decode.string)
  use message <- decode.field("message", decode.string)
  use features <- decode.field("features", decode.list(decode.string))
  decode.success(HomePageProps(title:, message:, features:))
}

// Decoder for UserProfilePageProps
pub fn user_profile_page_props_decoder() -> decode.Decoder(UserProfilePageProps) {
  use name <- decode.field("name", decode.string)
  use email <- decode.field("email", decode.string)
  use id <- decode.field("id", decode.int)
  use interests <- decode.optional_field(
    "interests",
    option.None,
    decode.optional(decode.list(decode.string)),
  )
  use bio <- decode.field("bio", decode.string)
  decode.success(UserProfilePageProps(name:, email:, id:, interests:, bio:))
}

// Decoder for BlogPostPageProps
pub fn blog_post_page_props_decoder() -> decode.Decoder(BlogPostPageProps) {
  use title <- decode.field("title", decode.string)
  use content <- decode.field("content", decode.string)
  use author <- decode.field("author", decode.string)
  use published_at <- decode.field("published_at", decode.string)
  use tags <- decode.field("tags", decode.list(decode.string))
  use view_count <- decode.optional_field(
    "view_count",
    option.None,
    decode.optional(decode.int),
  )
  decode.success(BlogPostPageProps(
    title:,
    content:,
    author:,
    published_at:,
    tags:,
    view_count:,
  ))
}

pub fn decode_blog_post_page_props(data: decode.Dynamic) {
  let assert Ok(props) = decode.run(data, blog_post_page_props_decoder())
  props
}

pub fn decode_home_page_props(data: decode.Dynamic) {
  let assert Ok(props) = decode.run(data, home_page_props_decoder())
  props
}

pub fn decode_user_profile_page_props(data: decode.Dynamic) {
  let assert Ok(props) = decode.run(data, user_profile_page_props_decoder())
  props
}

pub fn decode_dashboard_page_props(data: decode.Dynamic) {
  let assert Ok(props) = decode.run(data, dashboard_page_props_decoder())
  props
}

// Decoder for DashboardPageProps
pub fn dashboard_page_props_decoder() -> decode.Decoder(DashboardPageProps) {
  use user_count <- decode.field("user_count", decode.int)
  use post_count <- decode.field("post_count", decode.int)
  use recent_signups <- decode.optional_field(
    "recent_signups",
    option.None,
    decode.optional(decode.list(decode.string)),
  )
  use system_status <- decode.field("system_status", decode.string)
  decode.success(DashboardPageProps(
    user_count:,
    post_count:,
    recent_signups:,
    system_status:,
  ))
}

// Encoder for HomePageProps
pub fn encode_home_page_props(props: HomePageProps) -> json.Json {
  json.object([
    #("title", json.string(props.title)),
    #("message", json.string(props.message)),
    #("features", json.array(props.features, json.string)),
  ])
}

// ===== FORM PAGE PROPS =====

// Create user form page props
pub type CreateUserFormProps {
  CreateUserFormProps(
    title: String,
    message: String,
    errors: option.Option(json.Json),
  )
}

// Encoder for CreateUserFormProps
pub fn encode_create_user_form_props(props: CreateUserFormProps) -> json.Json {
  json.object([
    #("title", json.string(props.title)),
    #("message", json.string(props.message)),
    #("errors", json.nullable(props.errors, fn(e) { e })),
  ])
}

// Edit profile form page props
pub type EditProfileFormProps {
  EditProfileFormProps(
    user: UserProfilePageProps,
    errors: dict.Dict(String, String),
  )
}

// Encoder for EditProfileFormProps
pub fn encode_edit_profile_form_props(props: EditProfileFormProps) -> json.Json {
  json.object([
    #("user", encode_user_profile_props(props.user)),
    #("errors", json.dict(props.errors, fn(s) { s }, json.string)),
  ])
}

// Login form page props
pub type LoginFormProps {
  LoginFormProps(
    title: String,
    message: String,
    demo_info: List(String),
    errors: option.Option(json.Json),
  )
}

// Encoder for LoginFormProps
pub fn encode_login_form_props(props: LoginFormProps) -> json.Json {
  json.object([
    #("title", json.string(props.title)),
    #("message", json.string(props.message)),
    #("demo_info", json.array(props.demo_info, json.string)),
    #("errors", json.nullable(props.errors, fn(e) { e })),
  ])
}

// Contact form page props
pub type ContactFormProps {
  ContactFormProps(
    title: String,
    message: String,
    errors: dict.Dict(String, String),
  )
}

// Encoder for ContactFormProps
pub fn encode_contact_form_props(props: ContactFormProps) -> json.Json {
  json.object([
    #("title", json.string(props.title)),
    #("message", json.string(props.message)),
    #("errors", json.dict(props.errors, fn(e) { e }, json.string)),
  ])
}

// ===== REQUEST TYPES FOR FORM SUBMISSIONS =====

// Create user request
pub type CreateUserRequest {
  CreateUserRequest(name: String, email: String, bio: option.Option(String))
}

// Update profile request
pub type UpdateProfileRequest {
  UpdateProfileRequest(name: String, bio: String, interests: List(String))
}

// Login request
pub type LoginRequest {
  LoginRequest(
    email: String,
    password: String,
    remember_me: option.Option(Bool),
  )
}

// Contact form request
pub type ContactFormRequest {
  ContactFormRequest(
    name: String,
    email: String,
    subject: String,
    message: String,
    urgent: option.Option(Bool),
  )
}

// ===== REQUEST DECODERS =====

// Decoder for CreateUserRequest
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

pub fn decode_create_user_request(data: decode.Dynamic) {
  let assert Ok(request) = decode.run(data, create_user_request_decoder())
  request
}

// Decoder for UpdateProfileRequest
pub fn update_profile_request_decoder() -> decode.Decoder(UpdateProfileRequest) {
  use name <- decode.field("name", decode.string)
  use bio <- decode.field("bio", decode.string)
  use interests <- decode.field("interests", decode.list(decode.string))
  decode.success(UpdateProfileRequest(name:, bio:, interests:))
}

pub fn decode_update_profile_request(data: decode.Dynamic) {
  let assert Ok(request) = decode.run(data, update_profile_request_decoder())
  request
}

// Decoder for LoginRequest
pub fn login_request_decoder() -> decode.Decoder(LoginRequest) {
  use email <- decode.field("email", decode.string)
  use password <- decode.field("password", decode.string)
  use remember_me <- decode.optional_field(
    "remember_me",
    option.None,
    decode.optional(decode.bool),
  )
  decode.success(LoginRequest(email:, password:, remember_me:))
}

pub fn decode_login_request(data: decode.Dynamic) {
  let assert Ok(request) = decode.run(data, login_request_decoder())
  request
}

// Decoder for ContactFormRequest
pub fn contact_form_request_decoder() -> decode.Decoder(ContactFormRequest) {
  use name <- decode.field("name", decode.string)
  use email <- decode.field("email", decode.string)
  use subject <- decode.field("subject", decode.string)
  use message <- decode.field("message", decode.string)
  use urgent <- decode.optional_field(
    "urgent",
    option.None,
    decode.optional(decode.bool),
  )
  decode.success(ContactFormRequest(name:, email:, subject:, message:, urgent:))
}

pub fn decode_contact_form_request(data: decode.Dynamic) {
  let assert Ok(request) = decode.run(data, contact_form_request_decoder())
  request
}

// ===== REQUEST ENCODERS (to ensure types are exported to JavaScript) =====

// Encoder for CreateUserRequest
pub fn encode_create_user_request(request: CreateUserRequest) -> json.Json {
  json.object([
    #("name", json.string(request.name)),
    #("email", json.string(request.email)),
    #("bio", json.nullable(request.bio, json.string)),
  ])
}

// Encoder for UpdateProfileRequest
pub fn encode_update_profile_request(request: UpdateProfileRequest) -> json.Json {
  json.object([
    #("name", json.string(request.name)),
    #("bio", json.string(request.bio)),
    #("interests", json.array(request.interests, json.string)),
  ])
}

// Encoder for LoginRequest
pub fn encode_login_request(request: LoginRequest) -> json.Json {
  json.object([
    #("email", json.string(request.email)),
    #("password", json.string(request.password)),
    #("remember_me", json.nullable(request.remember_me, json.bool)),
  ])
}

// Encoder for ContactFormRequest
pub fn encode_contact_form_request(request: ContactFormRequest) -> json.Json {
  json.object([
    #("name", json.string(request.name)),
    #("email", json.string(request.email)),
    #("subject", json.string(request.subject)),
    #("message", json.string(request.message)),
    #("urgent", json.nullable(request.urgent, json.bool)),
  ])
}

// ===== DUMMY FUNCTIONS TO FORCE TYPE EXPORT =====

// These functions force Gleam to export the request types to JavaScript
// by using them in public function signatures

pub fn create_user_request_zero() -> CreateUserRequest {
  CreateUserRequest(name: "", email: "", bio: option.None)
}

pub fn update_profile_request_zero() -> UpdateProfileRequest {
  UpdateProfileRequest(name: "", bio: "", interests: [])
}

pub fn login_request_zero() -> LoginRequest {
  LoginRequest(email: "", password: "", remember_me: option.None)
}

pub fn contact_form_request_zero() -> ContactFormRequest {
  ContactFormRequest(
    name: "",
    email: "",
    subject: "",
    message: "",
    urgent: option.None,
  )
}

// ===== RESPONSE TYPES FOR FORM SUBMISSIONS =====

// Success response for form submissions
pub type FormSuccessResponse {
  FormSuccessResponse(
    message: String,
    redirect_url: option.Option(String),
    data: option.Option(json.Json),
  )
}

// Validation error for individual fields
pub type ValidationError {
  ValidationError(field: String, message: String)
}

// Error response for form submissions
pub type FormErrorResponse {
  FormErrorResponse(message: String, errors: List(ValidationError))
}

// ===== RESPONSE ENCODERS =====

// Encoder for FormSuccessResponse
pub fn encode_form_success_response(response: FormSuccessResponse) -> json.Json {
  json.object([
    #("message", json.string(response.message)),
    #("redirect_url", json.nullable(response.redirect_url, json.string)),
    #("data", json.nullable(response.data, fn(data) { data })),
  ])
}

// Encoder for ValidationError
pub fn encode_validation_error(error: ValidationError) -> json.Json {
  json.object([
    #("field", json.string(error.field)),
    #("message", json.string(error.message)),
  ])
}

// Encoder for FormErrorResponse
pub fn encode_form_error_response(response: FormErrorResponse) -> json.Json {
  json.object([
    #("message", json.string(response.message)),
    #("errors", json.array(response.errors, encode_validation_error)),
  ])
}
