# Tailwind CSS v4 Setup (Standalone Binary)

This project uses **Tailwind CSS v4** with the standalone binary approach for maximum simplicity and performance.

## Setup Overview

- ✅ **Tailwind v4 Standalone Binary** - No Node.js dependencies required for CSS processing
- ✅ **No PostCSS** - Simplified build pipeline 
- ✅ **No Config File** - Zero configuration needed
- ✅ **Custom Components** - Organized component styles in `src/styles.css`
- ✅ **Headless UI** - Accessible, unstyled components for React

## File Structure

```
frontend/
├── src/
│   ├── styles.css          # Main CSS file with Tailwind v4 import + custom styles
│   └── main.tsx            # Entry point (CSS handled separately)
├── tailwindcss             # Standalone binary (macOS ARM64)
└── package.json            # Build scripts
```

## Build Scripts

```bash
# CSS Development
npm run build:css      # Build CSS (minified)
npm run watch:css      # Watch CSS for changes

# JavaScript Development  
npm run build:js       # Build JS bundle
npm run watch:js       # Watch JS for changes

# Combined Development
npm run dev            # Build CSS once, then watch both CSS + JS
npm run dev:quick      # Same as dev but skips type checking

# Production
npm run build          # Type check + build CSS + build JS
npm run build:fast     # Build CSS + build JS (no type check)
```

## How It Works

1. **CSS Processing**: The standalone `tailwindcss` binary processes `src/styles.css` and outputs to `../static/css/styles.css`
2. **JavaScript Processing**: esbuild bundles TypeScript/React code separately 
3. **HTML Template**: The Gleam backend includes the CSS via `<link>` tag in the HTML template

## Tailwind v4 Features

- **`@import "tailwindcss"`** - Single import, no need for separate base/components/utilities
- **Modern CSS Custom Properties** - Better performance and smaller output
- **No Configuration** - Works out of the box with sensible defaults
- **Faster Builds** - Standalone binary is much faster than Node.js toolchain

## Custom Components

The `src/styles.css` file includes reusable component classes:

```css
/* Upload form components */
.upload-zone          # File drop zone base styles
.upload-zone--active  # Active drag state
.upload-zone--inactive # Inactive/hover states

.file-item           # Individual file display
.btn-primary         # Primary button base
.btn-primary--enabled # Enabled button state  
.btn-primary--disabled # Disabled button state
```

## Dependencies

### Runtime Dependencies
- `@headlessui/react` - Accessible UI components
- `@inertiajs/react` - Inertia.js React adapter
- `react` + `react-dom` - React framework
- `zod` - Schema validation

### Dev Dependencies  
- `esbuild` - Fast JavaScript bundler
- `npm-run-all` - Run multiple scripts in parallel
- `typescript` - Type checking

## Development Workflow

1. **Start Development**:
   ```bash
   npm run dev
   ```

2. **Make Changes**: Edit React components and CSS - both will auto-rebuild

3. **Production Build**:
   ```bash
   npm run build
   ```

## Platform Notes

The included `tailwindcss` binary is for **macOS ARM64**. For other platforms:

1. Download the appropriate binary from [Tailwind CSS releases](https://github.com/tailwindlabs/tailwindcss/releases/latest)
2. Replace the `tailwindcss` file
3. Make it executable: `chmod +x tailwindcss`

Available platforms:
- `tailwindcss-linux-arm64`
- `tailwindcss-linux-x64` 
- `tailwindcss-macos-arm64`
- `tailwindcss-macos-x64`
- `tailwindcss-windows-arm64.exe`
- `tailwindcss-windows-x64.exe`