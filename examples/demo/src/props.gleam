import gleam/json

/// Authentication data structure
pub type Auth {
  Auth(authenticated: Bool, user: String)
}

/// Props for the Home page
pub type HomeProps {
  HomeProps(
    auth: Auth,
    csrf_token: String,
    message: String,
    timestamp: String,
    user_count: Int,
  )
}

/// Props for the About page
pub type AboutProps {
  AboutProps(
    auth: Auth,
    csrf_token: String,
    page_title: String,
    description: String,
  )
}

/// Props for the Versioned page
pub type VersionedProps {
  VersionedProps(
    auth: Auth,
    csrf_token: String,
    version: String,
    build_info: String,
  )
}

/// Props for user-related pages
pub type UserProps {
  UserProps(
    auth: Auth,
    csrf_token: String,
    users: List(json.Json),
    pagination: json.Json,
    user: json.Json,
    success: String,
    errors: json.Json,
  )
}

/// Props for upload pages
pub type UploadProps {
  UploadProps(
    auth: Auth,
    csrf_token: String,
    max_files: Int,
    max_size_mb: Int,
    success: String,
    uploaded_files: json.Json,
  )
}

/// Props for demo features page showcasing inclusion strategies
pub type DemoFeaturesProps {
  DemoFeaturesProps(
    auth: Auth,
    csrf_token: String,
    title: String,
    description: String,
    expensive_data: json.Json,
    performance_info: json.Json,
  )
}

/// Encoder for Auth
pub fn encode_auth(auth: Auth) -> json.Json {
  json.object([
    #("authenticated", json.bool(auth.authenticated)),
    #("user", json.string(auth.user)),
  ])
}

/// Helper function to create an authenticated Auth value
pub fn authenticated_user(user: String) -> Auth {
  Auth(authenticated: True, user: user)
}

/// Helper function to create an unauthenticated Auth value
pub fn unauthenticated_user() -> Auth {
  Auth(authenticated: False, user: "")
}

/// Encoder for HomeProps
pub fn encode_home_props(props: HomeProps) -> json.Json {
  json.object([
    #("auth", encode_auth(props.auth)),
    #("csrf_token", json.string(props.csrf_token)),
    #("message", json.string(props.message)),
    #("timestamp", json.string(props.timestamp)),
    #("user_count", json.int(props.user_count)),
  ])
}

/// Encoder for AboutProps
pub fn encode_about_props(props: AboutProps) -> json.Json {
  json.object([
    #("auth", encode_auth(props.auth)),
    #("csrf_token", json.string(props.csrf_token)),
    #("page_title", json.string(props.page_title)),
    #("description", json.string(props.description)),
  ])
}

/// Encoder for VersionedProps
pub fn encode_versioned_props(props: VersionedProps) -> json.Json {
  json.object([
    #("auth", encode_auth(props.auth)),
    #("csrf_token", json.string(props.csrf_token)),
    #("version", json.string(props.version)),
    #("build_info", json.string(props.build_info)),
  ])
}

/// Encoder for UserProps
pub fn encode_user_props(props: UserProps) -> json.Json {
  json.object([
    #("auth", encode_auth(props.auth)),
    #("csrf_token", json.string(props.csrf_token)),
    #("users", json.array(props.users, fn(x) { x })),
    #("pagination", props.pagination),
    #("user", props.user),
    #("success", json.string(props.success)),
    #("errors", props.errors),
  ])
}

/// Encoder for UploadProps
pub fn encode_upload_props(props: UploadProps) -> json.Json {
  json.object([
    #("auth", encode_auth(props.auth)),
    #("csrf_token", json.string(props.csrf_token)),
    #("max_files", json.int(props.max_files)),
    #("max_size_mb", json.int(props.max_size_mb)),
    #("success", json.string(props.success)),
    #("uploaded_files", props.uploaded_files),
  ])
}

/// Encoder for DemoFeaturesProps
pub fn encode_demo_features_props(props: DemoFeaturesProps) -> json.Json {
  json.object([
    #("auth", encode_auth(props.auth)),
    #("csrf_token", json.string(props.csrf_token)),
    #("title", json.string(props.title)),
    #("description", json.string(props.description)),
    #("expensive_data", props.expensive_data),
    #("performance_info", props.performance_info),
  ])
}

// HomeProps helper functions for use with inertia.prop, inertia.always_prop, inertia.optional_prop
pub fn home_auth(auth: Auth) {
  #("auth", fn(props) { HomeProps(..props, auth: auth) })
}

pub fn home_csrf_token(token: String) {
  #("csrf_token", fn(props) { HomeProps(..props, csrf_token: token) })
}

pub fn home_message(message: String) {
  #("message", fn(props) { HomeProps(..props, message: message) })
}

pub fn home_timestamp(timestamp: String) {
  #("timestamp", fn(props) { HomeProps(..props, timestamp: timestamp) })
}

pub fn home_user_count(count: Int) {
  #("user_count", fn(props) { HomeProps(..props, user_count: count) })
}

// AboutProps helper functions
pub fn about_auth(auth: Auth) {
  #("auth", fn(props) { AboutProps(..props, auth: auth) })
}

pub fn about_csrf_token(token: String) {
  #("csrf_token", fn(props) { AboutProps(..props, csrf_token: token) })
}

pub fn about_page_title(title: String) {
  #("page_title", fn(props) { AboutProps(..props, page_title: title) })
}

pub fn about_description(description: String) {
  #("description", fn(props) { AboutProps(..props, description: description) })
}

// VersionedProps helper functions
pub fn versioned_auth(auth: Auth) {
  #("auth", fn(props) { VersionedProps(..props, auth: auth) })
}

pub fn versioned_csrf_token(token: String) {
  #("csrf_token", fn(props) { VersionedProps(..props, csrf_token: token) })
}

pub fn versioned_version(version: String) {
  #("version", fn(props) { VersionedProps(..props, version: version) })
}

pub fn versioned_build_info(info: String) {
  #("build_info", fn(props) { VersionedProps(..props, build_info: info) })
}

// UserProps helper functions
pub fn user_auth(auth: Auth) {
  #("auth", fn(props) { UserProps(..props, auth: auth) })
}

pub fn user_csrf_token(token: String) {
  #("csrf_token", fn(props) { UserProps(..props, csrf_token: token) })
}

pub fn user_users(users: List(json.Json)) {
  #("users", fn(props) { UserProps(..props, users: users) })
}

pub fn user_pagination(pagination: json.Json) {
  #("pagination", fn(props) { UserProps(..props, pagination: pagination) })
}

pub fn user_user(user: json.Json) {
  #("user", fn(props) { UserProps(..props, user: user) })
}

pub fn user_success(success: String) {
  #("success", fn(props) { UserProps(..props, success: success) })
}

pub fn user_errors(errors: json.Json) {
  #("errors", fn(props) { UserProps(..props, errors: errors) })
}

// UploadProps helper functions
pub fn upload_auth(auth: Auth) {
  #("auth", fn(props) { UploadProps(..props, auth: auth) })
}

pub fn upload_csrf_token(token: String) {
  #("csrf_token", fn(props) { UploadProps(..props, csrf_token: token) })
}

pub fn upload_max_files(max: Int) {
  #("max_files", fn(props) { UploadProps(..props, max_files: max) })
}

pub fn upload_max_size_mb(max: Int) {
  #("max_size_mb", fn(props) { UploadProps(..props, max_size_mb: max) })
}

pub fn upload_success(success: String) {
  #("success", fn(props) { UploadProps(..props, success: success) })
}

pub fn upload_uploaded_files(files: json.Json) {
  #("uploaded_files", fn(props) { UploadProps(..props, uploaded_files: files) })
}

// DemoFeaturesProps helper functions
pub fn demo_auth(auth: Auth) {
  #("auth", fn(props) { DemoFeaturesProps(..props, auth: auth) })
}

pub fn demo_csrf_token(token: String) {
  #("csrf_token", fn(props) { DemoFeaturesProps(..props, csrf_token: token) })
}

pub fn demo_title(title: String) {
  #("title", fn(props) { DemoFeaturesProps(..props, title: title) })
}

pub fn demo_description(description: String) {
  #("description", fn(props) {
    DemoFeaturesProps(..props, description: description)
  })
}

pub fn demo_expensive_data(data: fn() -> json.Json) {
  #("expensive_data", fn(props) {
    DemoFeaturesProps(..props, expensive_data: data())
  })
}

pub fn demo_performance_info(info: json.Json) {
  #("performance_info", fn(props) {
    DemoFeaturesProps(..props, performance_info: info)
  })
}
