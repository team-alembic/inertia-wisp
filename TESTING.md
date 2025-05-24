# Testing the Inertia Gleam Implementation

## Quick Start Test

1. **Start the Gleam server:**
   ```bash
   cd examples/minimal
   gleam run
   ```
   Server should start on http://localhost:8000

2. **Test browser requests (should return HTML):**
   ```bash
   curl http://localhost:8000/
   curl http://localhost:8000/about
   ```
   
   Expected: HTML response with `<div id="app" data-page="...">` containing JSON

3. **Test Inertia XHR requests (should return JSON):**
   ```bash
   curl -H "X-Inertia: true" http://localhost:8000/
   curl -H "X-Inertia: true" http://localhost:8000/about
   ```
   
   Expected: JSON response like:
   ```json
   {
     "component": "Home",
     "props": {"message": "Hello from Gleam!", "timestamp": 1234567890},
     "url": "/",
     "version": "1"
   }
   ```

## Frontend Integration Test

1. **Build and start the frontend:**
   ```bash
   cd examples/minimal/frontend
   npm install
   npm run build
   ```

2. **Start the Gleam server:**
   ```bash
   cd examples/minimal
   gleam run
   ```

3. **Open http://localhost:8000 in browser**

4. **Test scenarios:**
   - Initial page load should show "Welcome to Inertia Gleam!"
   - Click "Go to About" - should navigate without full page reload
   - Click "Back to Home" - should navigate without full page reload
   - Test XHR vs Full reload buttons to see the difference

## Expected Behavior

### ✅ Success Criteria

- **Initial Load**: Browser requests return HTML with embedded JSON in `data-page`
- **Navigation**: XHR requests with `X-Inertia: true` return JSON only
- **Props**: Props are correctly serialized and available in React components
- **Routing**: Multiple routes work ("/", "/about")
- **Headers**: Responses include `X-Inertia: true` and `Vary: X-Inertia` for XHR requests

### 🔍 Debug Tips

1. **Check server logs** for request details
2. **Browser Network tab** to see request/response headers
3. **Console errors** for component resolution issues
4. **JSON validation** for malformed responses

## Manual Test Cases

### Test 1: Basic HTML Response
```bash
curl -v http://localhost:8000/
```
Should contain:
- `Content-Type: text/html`
- `<div id="app" data-page="{...}">`
- JSON in data-page with component "Home"

### Test 2: Basic JSON Response  
```bash
curl -v -H "X-Inertia: true" http://localhost:8000/
```
Should contain:
- `Content-Type: application/json`
- `X-Inertia: true` header
- `Vary: X-Inertia` header
- JSON body with component, props, url, version

### Test 3: Props Serialization
```bash
curl -H "X-Inertia: true" http://localhost:8000/ | jq .props
```
Should show:
```json
{
  "message": "Hello from Gleam!",
  "timestamp": "2024-01-01T00:00:00Z"
}
```

### Test 4: Different Routes
```bash
curl -H "X-Inertia: true" http://localhost:8000/about | jq .component
```
Should return: `"About"`

### Test 5: 404 Handling
```bash
curl -v http://localhost:8000/nonexistent
```
Should return 404 status

## Automated Tests

Run the unit tests:
```bash
gleam test
```

Current test coverage:
- ✅ Configuration creation
- ✅ Prop helpers (string, int, bool)
- ✅ Props dictionary creation
- ✅ Page object creation
- ✅ JSON encoding
- ✅ HTML template generation
- ✅ Initial state creation

## Next Steps

Once basic functionality works:

1. **Add form submission tests**
2. **Test partial reloads** with `X-Inertia-Partial-Data` header
3. **Test version mismatches** for asset versioning
4. **Performance testing** with large prop objects
5. **Add CSS asset handling**

## Troubleshooting

### Server won't start
- Check port 8000 isn't in use: `lsof -i :8000`
- Verify all dependencies installed: `gleam deps download`

### JSON malformed
- Check prop serialization in logs
- Validate with: `curl ... | jq`

### Frontend not working
- Check browser console for errors
- Verify frontend assets are built: `ls examples/minimal/static/js/`
- Check component names match exactly
- Ensure ESBuild watch is running for development

### Navigation not working
- Verify `X-Inertia` header in requests
- Check response headers include `X-Inertia: true`
- Ensure component resolver finds components