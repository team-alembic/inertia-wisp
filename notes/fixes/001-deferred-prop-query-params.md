# Fix 001: Deferred Prop Query Parameter Persistence

## Issue

When using Inertia.js DeferredProp components, query parameters from the initial request are lost in subsequent partial requests for deferred data.

### Problem Description

The Dashboard page accepts a `?delay=5000` query parameter to control artificial delay for demonstration purposes. However, this parameter is only present in the initial request:

1. Initial request: `/dashboard?delay=5000` → delay_ms = 5000
2. First deferred prop request: `/dashboard` → delay_ms = 0  
3. Second deferred prop request: `/dashboard` → delay_ms = 0

### Root Cause

The issue is in `src/inertia_wisp/response_builder.gleam` in the `build_url_from_request` function:

```gleam
fn build_url_from_request(req: Request) -> String {
  let path = wisp.path_segments(req) |> string.join("/")
  "/" <> path
}
```

This function only extracts the path segments using `wisp.path_segments(req)` but ignores the query string (`req.query`). The resulting URL in the Inertia page data becomes `/dashboard` instead of `/dashboard?delay=5000`.

When Inertia.js makes partial requests for deferred props, it uses this URL as the base, causing query parameters to be lost.

### Evidence

In the initial HTML response, the `data-page` attribute shows:
```json
{
  "url": "/dashboard",
  "deferredProps": {
    "activity": ["activity_feed"],
    "default": ["analytics"]
  }
}
```

The `url` field should be `/dashboard?delay=5000` to preserve the query parameters.

## Fix

Modified the `build_url_from_request` function in `src/inertia_wisp/response_builder.gleam` to include query parameters when present:

```gleam
fn build_url_from_request(req: Request) -> String {
  let path = wisp.path_segments(req) |> string.join("/")
  let base_url = "/" <> path

  case req.query {
    option.Some(query) if query != "" -> base_url <> "?" <> query
    _ -> base_url
  }
}
```

This ensures that:
1. Query parameters are preserved in the Inertia page data URL
2. Partial requests for deferred props include the original query parameters
3. The delay parameter persists across all requests

### Testing Implementation

Created comprehensive tests in `test/response_builder_test.gleam`:

1. **`url_without_query_params_test`**: Verifies URLs without query params remain unchanged
2. **`url_with_query_params_test`**: Verifies single query parameter preservation 
3. **`url_with_multiple_query_params_test`**: Verifies multiple query parameters preservation
4. **`url_with_empty_query_string_test`**: Verifies empty query strings are handled correctly

### Testing Results

**RED Phase (Before Fix):**
- 29 tests total, 2 failures
- `url_with_query_params_test` failed: expected `/dashboard?delay=5000`, got `/dashboard`
- `url_with_multiple_query_params_test` failed: expected `/users?search=test&page=2&sort=name`, got `/users`

**GREEN Phase (After Fix):**
- 31 tests total, no failures
- All URL tests pass
- Dashboard handler tests continue to work correctly in test environment (0ms delay)

### Manual Verification

1. Visit `/dashboard?delay=5000` ✅
2. Initial request uses 5000ms delay ✅ 
3. Deferred prop requests also use 5000ms delay ✅
4. No query parameters still works correctly ✅

### Evidence from Official Adapters

**Laravel Adapter (`inertia-laravel/src/Response.php`):**
```php
protected function getUrl(Request $request): string
{
    $urlResolver = $this->urlResolver ?? function (Request $request) {
        $url = Str::start(Str::after($request->fullUrl(), $request->getSchemeAndHttpHost()), '/');
        
        $rawUri = Str::before($request->getRequestUri(), '?');
        
        return Str::endsWith($rawUri, '/') ? $this->finishUrlWithTrailingSlash($url) : $url;
    };
    
    return App::call($urlResolver, ['request' => $request]);
}
```

Uses `$request->fullUrl()` which includes query parameters.

**Phoenix Adapter (`inertia-phoenix/lib/inertia/controller.ex`):**
```elixir
defp request_path(conn) do
  IO.iodata_to_binary([conn.request_path, request_url_qs(conn.query_string)])
end

defp request_url_qs(""), do: ""
defp request_url_qs(qs), do: [??, qs]
```

Explicitly concatenates `conn.request_path` with `conn.query_string`.

**Both official adapters preserve query parameters in the URL field**, confirming this is the expected behavior for all Inertia.js backend adapters.

## Conclusion

**Status: ✅ COMPLETED**

This fix successfully ensures query parameter persistence in Inertia.js deferred prop workflows by including the query string in the URL field of the page data, allowing partial requests to maintain the original request context. 

**Key Outcomes:**
- Aligns the Gleam implementation with official Laravel and Phoenix adapters
- Preserves query parameters across deferred prop requests
- Maintains backward compatibility for URLs without query parameters
- Comprehensive test coverage ensures reliability
- Dashboard demo now works correctly with `?delay=` parameter

The fix is minimal, well-tested, and follows the established patterns from other official Inertia.js backend adapters.