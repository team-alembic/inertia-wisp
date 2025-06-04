import gleam/dict.{type Dict}
import gleam/function
import gleam/json
import shared_types/auth

// ===== DOMAIN TYPES =====

pub type UploadedFile {
  UploadedFile(filename: String, size: Int, content_type: String)
}

pub fn encode_uploaded_file(file: UploadedFile) -> json.Json {
  json.object([
    #("filename", json.string(file.filename)),
    #("size", json.int(file.size)),
    #("content_type", json.string(file.content_type)),
  ])
}

// ===== PROPS TYPES (with encoders) =====

pub type UploadPageProp {
  Auth(auth: auth.Auth)
  CsrfToken(csrf_token: String)
  MaxFiles(max_files: Int)
  MaxSizeMb(max_size_mb: Int)
  Success(success: String)
  UploadedFiles(uploaded_files: Dict(String, UploadedFile))
}

pub fn encode_upload_page_prop(prop: UploadPageProp) -> json.Json {
  case prop {
    Auth(auth_val) -> auth.encode_auth(auth_val)
    CsrfToken(csrf_token) -> json.string(csrf_token)
    MaxFiles(max_files) -> json.int(max_files)
    MaxSizeMb(max_size_mb) -> json.int(max_size_mb)
    Success(success) -> json.string(success)
    UploadedFiles(uploaded_files) ->
      json.dict(uploaded_files, function.identity, encode_uploaded_file)
  }
}
