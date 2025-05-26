# File Uploads with Inertia Gleam

This document covers the file upload functionality in Inertia Gleam, including configuration, validation, and usage examples.

## Overview

Inertia Gleam provides comprehensive file upload support with:

- **Multipart form data parsing** - Extract files from HTTP requests
- **File validation** - Size, type, and count restrictions
- **Progress tracking** - Monitor upload progress (framework for implementation)
- **Error handling** - Detailed validation error messages
- **Type safety** - Strong typing for uploaded files and configurations

## Basic Usage

### Simple File Upload

```gleam
import inertia_gleam

pub fn handle_upload(req: wisp.Request) -> wisp.Response {
  case inertia_gleam.get_uploaded_files_default(req) {
    Ok(files) -> {
      // Files uploaded successfully
      inertia_gleam.context(req)
      |> inertia_gleam.assign_prop("files", inertia_gleam.files_to_json(files))
      |> inertia_gleam.render("UploadSuccess")
    }
    Error(errors) -> {
      // Handle validation errors
      inertia_gleam.context(req)
      |> inertia_gleam.assign_errors(errors)
      |> inertia_gleam.render("UploadForm")
    }
  }
}
```

### Using Context API

```gleam
pub fn upload_form_with_files(req: wisp.Request) -> wisp.Response {
  inertia_gleam.context(req)
  |> inertia_gleam.assign_files_default()  // Automatically extracts and validates files
  |> inertia_gleam.assign_prop("title", json.string("Upload Form"))
  |> inertia_gleam.render("UploadForm")
}
```

## Configuration

### Default Configuration

The default upload configuration allows:
- **Max file size**: 10MB per file
- **Max files**: 5 files per request
- **Allowed types**: Common image, document, and text files

```gleam
let default_config = inertia_gleam.default_upload_config()
// UploadConfig(
//   max_file_size: 10_000_000,  // 10MB
//   allowed_types: ["image/jpeg", "image/png", "image/gif", "image/webp", 
//                   "application/pdf", "text/plain", "application/msword", ...],
//   max_files: 5
// )
```

### Custom Configuration

```gleam
let config = inertia_gleam.upload_config(
  max_file_size: 5_000_000,  // 5MB
  allowed_types: ["image/jpeg", "image/png", "application/pdf"],
  max_files: 3
)

// Use with context
inertia_gleam.context(req)
|> inertia_gleam.assign_files(config)
|> inertia_gleam.render("UploadForm")

// Or extract files directly
case inertia_gleam.get_uploaded_files(req, config) {
  Ok(files) -> handle_success(files)
  Error(errors) -> handle_errors(errors)
}
```

## File Types

### UploadedFile Type

```gleam
pub type UploadedFile {
  UploadedFile(
    filename: String,        // Original filename from client
    content_type: String,    // MIME type
    size: Int,              // File size in bytes
    content: BitArray,      // Raw file content
  )
}
```

### UploadConfig Type

```gleam
pub type UploadConfig {
  UploadConfig(
    max_file_size: Int,           // Maximum bytes per file
    allowed_types: List(String),  // Allowed MIME types
    max_files: Int,               // Maximum number of files
  )
}
```

## Validation

### Automatic Validation

Files are automatically validated against the provided configuration:

```gleam
// This will validate:
// - Total number of files <= max_files
// - Each file size <= max_file_size  
// - Each file type in allowed_types
case inertia_gleam.get_uploaded_files(req, config) {
  Ok(files) -> // All files passed validation
  Error(errors) -> // Contains specific validation errors
}
```

### Validation Errors

Errors are returned as a `Dict(String, String)` mapping field names to error messages:

```gleam
// Example error responses:
// #("avatar", "File too large. Maximum size is 5MB")
// #("document", "File type not allowed. Allowed types: image/jpeg, image/png")
// #("_files", "Too many files uploaded. Maximum 3 allowed")
// #("_form", "Request is not multipart/form-data")
```

### Content Type Detection

The library can detect file types from content:

```gleam
import inertia_gleam/uploads

let detected_type = uploads.detect_content_type(file_content)
// Returns MIME type based on file header bytes
```

## Frontend Integration

### File Information JSON

Files are converted to JSON for frontend consumption:

```gleam
let file_json = inertia_gleam.file_to_json(uploaded_file)
// {
//   "filename": "document.pdf",
//   "content_type": "application/pdf", 
//   "size": 1048576
// }
```

### Multiple Files

```gleam
// Convert all uploaded files to JSON
let files_json = files_to_json(files_dict)
// {
//   "avatar": {"filename": "profile.jpg", "content_type": "image/jpeg", "size": 204800},
//   "document": {"filename": "resume.pdf", "content_type": "application/pdf", "size": 512000}
// }
```

## Complete Example

### Backend Handler

```gleam
import gleam/dict
import gleam/json
import inertia_gleam

pub fn upload_form_page(req: wisp.Request) -> wisp.Response {
  inertia_gleam.context(req)
  |> inertia_gleam.assign_prop("max_files", json.int(3))
  |> inertia_gleam.assign_prop("max_size_mb", json.int(5))
  |> inertia_gleam.assign_prop("allowed_types", json.array([
      json.string("image/jpeg"),
      json.string("image/png"),
      json.string("application/pdf")
    ], json.identity))
  |> inertia_gleam.render("UploadForm")
}

pub fn handle_upload(req: wisp.Request) -> wisp.Response {
  let config = inertia_gleam.upload_config(
    max_file_size: 5_000_000,  // 5MB
    allowed_types: ["image/jpeg", "image/png", "application/pdf"],
    max_files: 3
  )

  case inertia_gleam.get_uploaded_files(req, config) {
    Ok(files) -> {
      // Save files and redirect
      let file_count = dict.size(files)
      let message = "Successfully uploaded " <> int_to_string(file_count) <> " files"
      
      inertia_gleam.context(req)
      |> inertia_gleam.assign_prop("success", json.string(message))
      |> inertia_gleam.assign_prop("files", files_to_json(files))
      |> inertia_gleam.render("UploadSuccess")
    }
    Error(errors) -> {
      // Return form with errors
      inertia_gleam.context(req)
      |> inertia_gleam.assign_errors(errors)
      |> inertia_gleam.assign_prop("max_files", json.int(3))
      |> inertia_gleam.assign_prop("max_size_mb", json.int(5))
      |> inertia_gleam.render("UploadForm")
    }
  }
}
```

### Routes

```gleam
case wisp.path_segments(req), req.method {
  ["upload"], http.Get -> upload_form_page(req)
  ["upload"], http.Post -> handle_upload(req)
  // ...
}
```

### Frontend (React)

```jsx
import { useForm } from '@inertiajs/react'

function UploadForm({ max_files, max_size_mb, allowed_types, errors }) {
  const { data, setData, post, processing } = useForm({
    files: []
  })

  const submit = (e) => {
    e.preventDefault()
    
    const formData = new FormData()
    for (let i = 0; i < data.files.length; i++) {
      formData.append(`file_${i}`, data.files[i])
    }
    
    post('/upload', {
      data: formData,
      forceFormData: true
    })
  }

  return (
    <form onSubmit={submit}>
      <div>
        <label>Choose files (max {max_files}, {max_size_mb}MB each):</label>
        <input
          type="file"
          multiple
          accept={allowed_types.join(',')}
          onChange={(e) => setData('files', e.target.files)}
        />
        {errors.files && <div className="error">{errors.files}</div>}
      </div>
      
      <button type="submit" disabled={processing}>
        {processing ? 'Uploading...' : 'Upload Files'}
      </button>
    </form>
  )
}
```

## Progress Tracking

### Backend Progress Endpoint

```gleam
pub fn upload_progress(req: wisp.Request) -> wisp.Response {
  // In a real implementation, track progress in cache/database
  let progress = json.object([
    #("uploaded", json.int(1024000)),
    #("total", json.int(2048000)), 
    #("percent", json.int(50)),
    #("status", json.string("uploading"))
  ])

  wisp.json_response(json.to_string_tree(progress), 200)
}
```

### Frontend Progress Tracking

```jsx
import { useState, useEffect } from 'react'

function UploadWithProgress() {
  const [progress, setProgress] = useState(null)
  
  const checkProgress = () => {
    fetch('/upload/progress')
      .then(res => res.json())
      .then(setProgress)
  }

  useEffect(() => {
    if (processing) {
      const interval = setInterval(checkProgress, 1000)
      return () => clearInterval(interval)
    }
  }, [processing])

  return (
    <div>
      {progress && (
        <div className="progress-bar">
          <div 
            className="progress-fill" 
            style={{ width: `${progress.percent}%` }}
          />
          <span>{progress.percent}% uploaded</span>
        </div>
      )}
      {/* Upload form */}
    </div>
  )
}
```

## Security Considerations

### File Type Validation

- Always validate both the declared MIME type and detected content type
- Use content-based detection to prevent MIME type spoofing
- Implement server-side scanning for malicious content

### File Size Limits

- Set reasonable size limits to prevent DoS attacks
- Validate file sizes on both client and server
- Consider total upload size limits per user/session

### File Storage

- Store uploaded files outside the web root
- Use unique filenames to prevent conflicts and enumeration
- Implement virus scanning for uploaded files
- Consider cloud storage for scalability

### Access Control

- Verify user permissions before allowing uploads
- Implement rate limiting for upload endpoints
- Log all upload activities for audit trails

## Testing

### Unit Tests

```gleam
import inertia_gleam/testing

pub fn file_upload_test() {
  let req = testing.inertia_request()
    |> testing.set_content_type("multipart/form-data; boundary=test")
    |> testing.set_body(multipart_body)

  let result = inertia_gleam.get_uploaded_files_default(req)
  
  case result {
    Ok(files) -> {
      dict.size(files) |> should.equal(2)
      // Test individual files...
    }
    Error(_) -> should.be_true(False)
  }
}
```

### Integration Tests

Test complete upload workflows including validation errors and success cases.

## Limitations

### Current Implementation

- Multipart parsing is simplified and may need enhancement for production use
- File saving requires integration with file system libraries (simplifile)
- Progress tracking requires session/cache storage implementation

### Future Enhancements

- Streaming uploads for large files
- Chunked upload support
- Built-in cloud storage integration
- Advanced image processing (resize, format conversion)
- Virus scanning integration