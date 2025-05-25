import gleam/bit_array
import gleam/dict.{type Dict}

import gleam/int
import gleam/json
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/result
import gleam/string
import wisp.{type Request}

/// Represents an uploaded file
pub type UploadedFile {
  UploadedFile(
    filename: String,
    content_type: String,
    size: Int,
    content: BitArray,
  )
}

/// Configuration for file upload validation
pub type UploadConfig {
  UploadConfig(
    max_file_size: Int,
    allowed_types: List(String),
    max_files: Int,
  )
}

/// Result of file upload processing
pub type UploadResult {
  UploadSuccess(files: Dict(String, UploadedFile))
  UploadError(errors: Dict(String, String))
}

/// Default upload configuration
pub fn default_upload_config() -> UploadConfig {
  UploadConfig(
    max_file_size: 10_000_000,
    // 10MB
    allowed_types: [
      "image/jpeg", "image/png", "image/gif", "image/webp", "application/pdf",
      "text/plain", "application/msword",
      "application/vnd.openxmlformats-officedocument.wordprocessingml.document",
    ],
    max_files: 5,
  )
}

/// Create upload configuration with custom settings
pub fn upload_config(
  max_file_size max_size: Int,
  allowed_types types: List(String),
  max_files max: Int,
) -> UploadConfig {
  UploadConfig(
    max_file_size: max_size,
    allowed_types: types,
    max_files: max,
  )
}

/// Extract uploaded files from a multipart form request
pub fn extract_files(
  req: Request,
  config: UploadConfig,
) -> Result(Dict(String, UploadedFile), Dict(String, String)) {
  case get_content_type(req) {
    Some(content_type) -> {
      case string.starts_with(content_type, "multipart/form-data") {
        True -> parse_multipart_files(req, config)
        False -> Error(dict.from_list([#("_form", "Request is not multipart/form-data")]))
      }
    }
    None -> Error(dict.from_list([#("_form", "Request is not multipart/form-data")]))
  }
}

/// Validate a single uploaded file
pub fn validate_file(
  file: UploadedFile,
  config: UploadConfig,
) -> Result(UploadedFile, String) {
  use _ <- result.try(validate_file_size(file, config.max_file_size))
  use _ <- result.try(validate_file_type(file, config.allowed_types))
  Ok(file)
}

/// Validate multiple uploaded files
pub fn validate_files(
  files: Dict(String, UploadedFile),
  config: UploadConfig,
) -> Result(Dict(String, UploadedFile), Dict(String, String)) {
  // Check total number of files
  case dict.size(files) > config.max_files {
    True ->
      Error(
        dict.from_list([
          #("_files", "Too many files uploaded. Maximum " <> int.to_string(config.max_files) <> " allowed"),
        ]),
      )
    False -> {
      // Validate each file individually
      let validation_results =
        dict.fold(files, Ok(dict.new()), fn(acc, field_name, file) {
          case acc {
            Error(errors) -> Error(errors)
            Ok(valid_files) -> {
              case validate_file(file, config) {
                Ok(valid_file) ->
                  Ok(dict.insert(valid_files, field_name, valid_file))
                Error(error) ->
                  Error(dict.from_list([#(field_name, error)]))
              }
            }
          }
        })

      validation_results
    }
  }
}

/// Get the MIME type of an uploaded file based on content
pub fn detect_content_type(content: BitArray) -> String {
  case bit_array.slice(content, 0, 8) {
    Ok(header) -> {
      case header {
        // JPEG
        <<255, 216, 255, _:bytes>> -> "image/jpeg"
        // PNG  
        <<137, 80, 78, 71, 13, 10, 26, 10>> -> "image/png"
        // GIF87a or GIF89a
        <<71, 73, 70, 56, 55, 97, _:bytes>> -> "image/gif"
        <<71, 73, 70, 56, 57, 97, _:bytes>> -> "image/gif"
        // WebP
        <<82, 73, 70, 70, _:bytes>> -> "image/webp"
        // PDF
        <<37, 80, 68, 70, _:bytes>> -> "application/pdf"
        _ -> "application/octet-stream"
      }
    }
    Error(_) -> "application/octet-stream"
  }
}

/// Create a JSON representation of file info for frontend
pub fn file_to_json(file: UploadedFile) -> json.Json {
  json.object([
    #("filename", json.string(file.filename)),
    #("content_type", json.string(file.content_type)),
    #("size", json.int(file.size)),
  ])
}

/// Create JSON representation of multiple files
pub fn files_to_json(files: Dict(String, UploadedFile)) -> json.Json {
  let file_list =
    dict.fold(files, [], fn(acc, field_name, file) {
      [#(field_name, file_to_json(file)), ..acc]
    })

  json.object(file_list)
}

/// Save uploaded file to disk (placeholder - would need actual file system integration)
pub fn save_file(
  file: UploadedFile,
  directory: String,
) -> Result(String, String) {
  // This is a placeholder implementation
  // In a real application, you would:
  // 1. Generate a unique filename
  // 2. Write the content to the filesystem
  // 3. Return the saved file path
  let file_path = directory <> "/" <> file.filename
  // TODO: Implement actual file saving with simplifile
  Ok(file_path)
}

// Private helper functions

fn get_content_type(req: Request) -> Option(String) {
  list.find_map(req.headers, fn(header) {
    case header {
      #("content-type", value) -> Ok(value)
      _ -> Error(Nil)
    }
  })
  |> result.map_error(fn(_) { Nil })
  |> option.from_result
}

fn parse_multipart_files(
  _req: Request,
  _config: UploadConfig,
) -> Result(Dict(String, UploadedFile), Dict(String, String)) {
  // This is a simplified placeholder implementation
  // In a real implementation, you would:
  // 1. Parse the multipart boundary from content-type header
  // 2. Split the request body by boundary
  // 3. Parse each part to extract field name, filename, content-type, and content
  // 4. Create UploadedFile instances
  
  // For now, return empty result
  Ok(dict.new())
}

fn validate_file_size(file: UploadedFile, max_size: Int) -> Result(Nil, String) {
  case file.size > max_size {
    True -> {
      let max_mb = max_size / 1_000_000
      Error("File too large. Maximum size is " <> int.to_string(max_mb) <> "MB")
    }
    False -> Ok(Nil)
  }
}

fn validate_file_type(
  file: UploadedFile,
  allowed_types: List(String),
) -> Result(Nil, String) {
  case list.contains(allowed_types, file.content_type) {
    True -> Ok(Nil)
    False ->
      Error(
        "File type not allowed. Allowed types: " <> string.join(allowed_types, ", "),
      )
  }
}

