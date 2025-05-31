import gleam/json

/// Props for the Home page
pub type HomeProps {
  HomeProps(
    auth: json.Json,
    csrf_token: String,
    message: String,
    timestamp: String,
    user_count: Int,
  )
}

/// Props for the About page
pub type AboutProps {
  AboutProps(
    auth: json.Json,
    csrf_token: String,
    title: String,
    description: String,
  )
}

/// Props for the Versioned page
pub type VersionedProps {
  VersionedProps(
    auth: json.Json,
    csrf_token: String,
    version: String,
    build_info: String,
  )
}

/// Props for user-related pages
pub type UserProps {
  UserProps(
    auth: json.Json,
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
    auth: json.Json,
    csrf_token: String,
    max_files: Int,
    max_size_mb: Int,
    success: String,
    uploaded_files: json.Json,
  )
}

/// Encoder for HomeProps
pub fn encode_home_props(props: HomeProps) -> json.Json {
  json.object([
    #("auth", props.auth),
    #("csrf_token", json.string(props.csrf_token)),
    #("message", json.string(props.message)),
    #("timestamp", json.string(props.timestamp)),
    #("user_count", json.int(props.user_count)),
  ])
}

/// Encoder for AboutProps
pub fn encode_about_props(props: AboutProps) -> json.Json {
  json.object([
    #("auth", props.auth),
    #("csrf_token", json.string(props.csrf_token)),
    #("title", json.string(props.title)),
    #("description", json.string(props.description)),
  ])
}

/// Encoder for VersionedProps
pub fn encode_versioned_props(props: VersionedProps) -> json.Json {
  json.object([
    #("auth", props.auth),
    #("csrf_token", json.string(props.csrf_token)),
    #("version", json.string(props.version)),
    #("build_info", json.string(props.build_info)),
  ])
}

/// Encoder for UserProps
pub fn encode_user_props(props: UserProps) -> json.Json {
  json.object([
    #("auth", props.auth),
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
    #("auth", props.auth),
    #("csrf_token", json.string(props.csrf_token)),
    #("max_files", json.int(props.max_files)),
    #("max_size_mb", json.int(props.max_size_mb)),
    #("success", json.string(props.success)),
    #("uploaded_files", props.uploaded_files),
  ])
}