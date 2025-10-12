# Presentation Example

A meta presentation that demonstrates Inertia-Wisp by using it to present itself! This example showcases how to build a presentation system where:

- Each slide is a route on the backend
- The backend acts as a CMS, providing all content
- The frontend is a generic rendering engine
- Full type safety from Gleam to TypeScript

## Getting Started

### Prerequisites

- Gleam installed ([gleam.run](https://gleam.run))
- Node.js and npm installed
- mkcert installed for trusted HTTPS certificates
  - macOS: `brew install mkcert`
  - Linux: See [mkcert installation guide](https://github.com/FiloSottile/mkcert)
- A modern web browser

### Quick Start

```bash
# 1. Generate trusted HTTPS certificates (first time only)
make certs

# 2. Install all dependencies (Gleam + frontend)
make deps

# 3. Build frontend assets
make build

# 4. Run the presentation server
make run
```

Then open your browser to **https://localhost:8444/**

**Note:** The certificates are automatically trusted by your system thanks to mkcert - no browser warnings!

### Development Mode

For active development with auto-rebuilding:

```bash
# Terminal 1: Watch and rebuild frontend assets
make dev-frontend

# Terminal 2: Run the server (restart when you change backend code)
make dev-server
```

### Available Make Commands

```bash
make all          # Install dependencies and build (default)
make certs        # Generate trusted HTTPS certificates with mkcert
make deps         # Install Gleam and frontend dependencies
make build        # Build frontend assets
make run          # Run the presentation server
make dev          # Show development mode instructions
make dev-frontend # Watch and rebuild frontend assets
make dev-server   # Run the server
make clean        # Remove build artifacts
make rebuild      # Clean and rebuild everything
make help         # Show all available commands
```

## Navigation

- **Arrow Right** → Next slide
- **Arrow Left** → Previous slide
- **Click links** in the footer to navigate
- **Current slide**: Shows as `N / Total` in the bottom right

## What This Demonstrates

### Backend as CMS Pattern

- Slide content defined in Gleam modules (`src/slides/`)
- Rich content types (headings, code blocks, lists, quotes, etc.)
- Navigation logic handled server-side
- Props serialization to JSON

### Generic Frontend Templates

- Single `Slide.tsx` component renders all slides
- Content blocks rendered dynamically based on type
- Keyboard navigation with arrow keys
- Responsive design with Tailwind CSS

### Type Safety

- Gleam types in `slides/content.gleam`
- JSON encoding in `props/slide_props.gleam`
- TypeScript types in `frontend/src/types.ts`
- End-to-end type safety across the boundary

## Project Structure

```
presentation/
├── src/
│   ├── presentation.gleam        # Main application entry point
│   ├── handlers/
│   │   └── slides.gleam          # Slide route handlers
│   ├── slides/
│   │   ├── content.gleam         # Slide content types
│   │   ├── slide_01.gleam        # Individual slide definitions
│   │   ├── slide_02.gleam
│   │   └── ...
│   └── props/
│       └── slide_props.gleam     # JSON serialization for slides
├── frontend/
│   ├── src/
│   │   ├── app.tsx               # Inertia app setup
│   │   ├── types.ts              # TypeScript type definitions
│   │   ├── styles.css            # Tailwind CSS
│   │   └── Pages/
│   │       └── Slide.tsx         # Generic slide renderer
│   └── package.json
├── priv/
│   ├── static/                    # Built assets (generated)
│   │   ├── css/styles.css
│   │   ├── js/main.js
│   │   └── images/
│   │       └── alembic-logo.png
│   └── certs/                     # HTTPS certificates (mkcert)
├── test/
│   └── presentation_test.gleam   # Tests
├── Makefile                       # Build automation
└── README.md                      # This file
```

## Content Block Types

The `ContentBlock` type in `slides/content.gleam` supports:

- **`Heading`** - Main slide headings (large, bold text)
- **`Subheading`** - Secondary headings
- **`Paragraph`** - Body text
- **`CodeBlock`** - Syntax-highlighted code with language specification (uses Prism.js with custom Gleam language definition)
- **`BulletList`** - Unordered lists
- **`NumberedList`** - Ordered lists
- **`Quote`** - Blockquotes with attribution
- **`Image`** - Images with URL, alt text, and width
- **`Columns`** - 2-column layout (40% left, 60% right) containing nested content blocks
- **`Spacer`** - Vertical spacing between elements

## Adding New Slides

### 1. Create a Slide Module

Create a new file in `src/slides/`:

```gleam
// src/slides/slide_05.gleam
import slides/content.{type Slide, Heading, Paragraph, BulletList, CodeBlock, Image}

pub fn slide() -> Slide {
  content.Slide(
    number: 5,
    title: "My New Slide",
    content: [
      Heading("My New Slide"),
      Image("/static/images/my-logo.png", "My Logo", 300),
      Paragraph("Introduction to this topic..."),
      BulletList([
        "First point",
        "Second point",
        "Third point",
      ]),
      CodeBlock(
        "pub fn hello() -> String {\n  \"Hello, World!\"\n}",
        "gleam",
        [1],  // Highlight line 1
      ),
    ],
    notes: "Speaker notes go here",
  )
}
```

### 2. Update the Handler

Edit `src/handlers/slides.gleam`:

1. Add import at the top:
   ```gleam
   import slides/slide_05
   ```

2. Increment the `total_slides` constant:
   ```gleam
   const total_slides = 5
   ```

3. Add case in the `get_slide()` function:
   ```gleam
   fn get_slide(number: Int) -> content.Slide {
     case number {
       1 -> slide_01.slide()
       2 -> slide_02.slide()
       3 -> slide_03.slide()
       4 -> slide_04.slide()
       5 -> slide_05.slide()
       _ -> panic as "Invalid slide number"
     }
   }
   ```

### 3. Rebuild and Run

```bash
make run
```

No frontend changes needed - the generic renderer handles all content types!

## Architecture Flow

```
Browser Request → Wisp → Inertia Handler → Slide Content (Gleam)
                                                ↓
                                         Props as JSON
                                                ↓
                                    React Component ← TypeScript Types
                                                ↓
                                          Rendered HTML
```

**Key Insight:** The backend controls everything. The frontend is just a rendering engine.

### Type Safety Journey

1. **Define Gleam types** → `slides/content.gleam`
   ```gleam
   pub type Slide {
     Slide(number: Int, title: String, content: List(ContentBlock), notes: String)
   }
   ```

2. **Create JSON encoders** → `props/slide_props.gleam`
   ```gleam
   fn encode_slide(slide: content.Slide) -> Json { ... }
   ```

3. **Define TypeScript types** → `frontend/src/types.ts`
   ```typescript
   export interface Slide {
     number: number;
     title: string;
     content: SlideContentBlock[];
     notes: string;
   }
   ```

4. **Render in React** → `frontend/src/Pages/Slide.tsx`
   ```typescript
   function Slide({ slide, navigation }: SlidePageProps) { ... }
   ```

Any mismatch causes compilation errors!

## Extending This Example

### Add Syntax Highlighting

Install a syntax highlighting library:

```bash
cd frontend
npm install prismjs @types/prismjs
cd ..
```

Then update `frontend/src/Pages/Slide.tsx` to highlight code blocks.

### Add Speaker Notes View

Create a new route in `src/handlers/slides.gleam`:

```gleam
["slides", slide_num, "notes"], http.Get -> 
  slides.view_notes(req, slide_num)
```

Create a new page component `frontend/src/Pages/Notes.tsx` to display them.

### Add Overview/Grid View

Create a handler that shows all slides as thumbnails:

```gleam
["slides", "overview"], http.Get -> 
  slides.overview(req)
```

### Add Slide Transitions

Use a React animation library like Framer Motion:

```bash
cd frontend
npm install framer-motion
cd ..
```

Wrap slide content in animated components.

## Testing

Run the test suite:

```bash
gleam test
```

The tests verify:
- Each slide has the correct number
- Navigation logic works correctly (previous/next URLs)
- Slides have titles and content

## Syntax Highlighting

Code blocks use **Prism.js** for syntax highlighting with the "Tomorrow" theme.

**Supported Languages:**
- Gleam (custom language definition)
- TypeScript
- JavaScript
- JSX/TSX
- Bash
- JSON
- Many others via Prism.js

**Gleam Support:** We've created a custom Gleam language definition for Prism.js that provides proper syntax highlighting for:
- Keywords (`pub`, `fn`, `let`, `use`, `case`, `type`, etc.)
- Functions (snake_case identifiers before parentheses)
- Types (PascalCase identifiers)
- Strings, comments, numbers, booleans
- Operators (`->`, `<-`, `|>`, etc.)

The custom definition is defined in `frontend/src/Pages/Slide.tsx` and automatically registered with Prism on load.

## Troubleshooting

### Certificate Issues

**Need to regenerate certificates?**
```bash
make certs
```

This will create fresh certificates using mkcert. The certificates are automatically trusted by your system.

**mkcert not installed?**
- macOS: `brew install mkcert`
- Linux: See [mkcert installation guide](https://github.com/FiloSottile/mkcert)
- Windows: Download from [mkcert releases](https://github.com/FiloSottile/mkcert/releases)

After installing mkcert for the first time, run:
```bash
mkcert -install  # Install the local CA (one-time setup)
make certs       # Generate certificates for this project
```

### Other Issues

**Port already in use?**
- Change the port in `src/presentation.gleam` (search for `8444`)

**Build errors?**
- Run `make clean` then `make all`

**Slides not appearing?**
- Ensure frontend assets are built: `make build`
- Check that `static/js/main.js` and `static/css/styles.css` exist

**Changes not appearing?**
- Frontend changes: Run `make dev-frontend` in watch mode
- Backend changes: Restart the server with `make run`

## License

MIT