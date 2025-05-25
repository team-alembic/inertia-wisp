# File Upload UI Guide

This guide explains how to use the file upload functionality in the Inertia Gleam minimal example.

## Overview

The file upload system provides a complete UI for uploading files with validation, progress indicators, and error handling. It consists of two main components:

- **UploadForm** - The main upload interface with drag & drop support
- **UploadSuccess** - Success page showing uploaded file details

## Features

### Upload Form Features
- **Drag & Drop Interface** - Users can drag files directly onto the upload area
- **File Browser** - Click to browse and select files traditionally
- **Real-time Validation** - Client-side validation before upload
- **File Preview** - Shows selected files with size and type information
- **Progress Indicators** - Visual feedback during upload process
- **Error Handling** - Clear error messages for validation failures

### Validation Features
- **File Size Limits** - Configurable maximum file size per file
- **File Type Restrictions** - Whitelist of allowed MIME types
- **File Count Limits** - Maximum number of files per upload
- **Real-time Feedback** - Immediate validation feedback to users

## Usage

### Accessing the Upload Form

Navigate to `/upload` in your browser or click the "File Upload Demo" link from the home page.

### Uploading Files

1. **Drag & Drop Method:**
   - Drag files from your file manager directly onto the upload area
   - The area will highlight when files are dragged over it
   - Drop files to select them for upload

2. **Browse Method:**
   - Click anywhere in the upload area
   - Select files using the standard file browser dialog
   - Multiple files can be selected if allowed

3. **Review Selected Files:**
   - Selected files appear in a list below the upload area
   - Each file shows name, size, and type
   - Remove individual files using the × button

4. **Upload Files:**
   - Click the "Upload Files" button
   - Progress indicator shows during upload
   - Success page appears after successful upload

### Configuration

The upload form respects server-side configuration:

- **max_files**: Maximum number of files (default: 3)
- **max_size_mb**: Maximum size per file in MB (default: 5MB)
- **allowed_types**: List of allowed MIME types (images, PDFs, etc.)

## UI Components

### UploadForm Component

Located: `frontend/src/Pages/UploadForm.tsx`

**Props:**
```typescript
interface UploadFormPageProps {
  auth?: { authenticated: boolean; user: string };
  csrf_token: string;
  max_files: number;
  max_size_mb: number;
  allowed_types?: string[];
  errors?: Record<string, string>;
}
```

**Key Features:**
- Responsive design with Tailwind CSS
- TypeScript validation with Zod schemas
- Drag & drop with visual feedback
- Client-side file validation
- FormData submission with multipart encoding

### UploadSuccess Component

Located: `frontend/src/Pages/UploadSuccess.tsx`

**Props:**
```typescript
interface UploadSuccessPageProps {
  auth?: { authenticated: boolean; user: string };
  csrf_token: string;
  success: string;
  uploaded_files: Record<string, {
    filename: string;
    content_type: string;
    size: number;
  }>;
}
```

**Key Features:**
- File type icons based on MIME type
- Formatted file sizes (Bytes, KB, MB, GB)
- Upload summary statistics
- Navigation back to upload form or home

## Backend Integration

### Routes

The upload functionality uses these routes:

```gleam
["upload"], http.Get -> uploads.upload_form_page(req)
["upload"], http.Post -> uploads.handle_file_upload(req)
```

### Handler Functions

**Upload Form Handler:**
```gleam
pub fn upload_form_page(req: wisp.Request) -> wisp.Response {
  inertia_gleam.context(req)
  |> utils.assign_common_props()
  |> inertia_gleam.assign_prop("max_files", json.int(3))
  |> inertia_gleam.assign_prop("max_size_mb", json.int(5))
  |> inertia_gleam.render("UploadForm")
}
```

**Upload Processing Handler:**
```gleam
pub fn handle_file_upload(req: wisp.Request) -> wisp.Response {
  let config = inertia_gleam.upload_config(
    max_file_size: 5_000_000,  // 5MB
    allowed_types: ["image/jpeg", "image/png", "image/gif", "application/pdf"],
    max_files: 3
  )

  case inertia_gleam.get_uploaded_files(req, config) {
    Ok(files) -> handle_successful_upload(req, files)
    Error(errors) -> handle_upload_errors(req, errors)
  }
}
```

## Styling

The upload UI uses Tailwind CSS with a clean, modern design:

- **Color Scheme**: Blue primary, gray neutrals, green success, red errors
- **Layout**: Centered cards with responsive breakpoints
- **Interactive States**: Hover effects, focus rings, disabled states
- **Typography**: Clear hierarchy with proper spacing

### Key Design Elements

- **Upload Area**: Dashed border that highlights on drag-over
- **File List**: Clean cards with file metadata and remove buttons
- **Progress States**: Loading spinners and status indicators
- **Error Display**: Red-themed error messages with clear descriptions

## Error Handling

### Client-Side Validation

- File size validation before upload
- File type checking against allowed list
- File count limit enforcement
- Immediate user feedback

### Server-Side Validation

- Comprehensive file validation on backend
- Detailed error messages returned to frontend
- Form redisplay with errors and preserved state

### Error Display

Errors are shown in a prominent red box above the upload form with:
- Clear error descriptions
- Field-specific error mapping
- Instructions for resolution

## Accessibility

- **Keyboard Navigation**: Full keyboard support for all interactions
- **Screen Readers**: Proper ARIA labels and semantic HTML
- **Focus Management**: Clear focus indicators and logical tab order
- **Error Announcements**: Screen reader friendly error messages

## Browser Compatibility

- **Modern Browsers**: Full support for Chrome, Firefox, Safari, Edge
- **File API**: Uses modern File API for drag & drop
- **FormData**: Multipart form submission support
- **Progressive Enhancement**: Falls back gracefully without JavaScript

## Testing the Upload UI

1. **Navigate to Upload Form**: Go to `/upload`
2. **Test Drag & Drop**: Drag files from file manager
3. **Test File Browser**: Click to browse files
4. **Test Validation**: Try uploading oversized or invalid files
5. **Test Success Flow**: Upload valid files and check success page
6. **Test Error Flow**: Upload invalid files and check error display

The upload UI provides a complete, production-ready file upload experience with comprehensive validation, error handling, and user feedback.