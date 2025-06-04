import gleam/list
import gleeunit
import inertia_wisp/inertia
import inertia_wisp/testing
import wisp
import wisp/testing as wisp_testing

pub fn main() {
  gleeunit.main()
}

// Helper function to get header from response
fn get_header(response: wisp.Response, name: String) -> Result(String, Nil) {
  list.find_map(response.headers, fn(header) {
    case header {
      #(header_name, value) if header_name == name -> Ok(value)
      _ -> Error(Nil)
    }
  })
}

// Test 1: redirect should handle Inertia requests with 303 status
pub fn redirect_inertia_request_test() {
  let req = testing.inertia_request()
  let response = inertia.redirect(req, "/dashboard")
  
  // Should be a 303 redirect for Inertia requests
  assert response.status == 303
  
  // Should have location header
  case get_header(response, "location") {
    Ok(location) -> {
      assert location == "/dashboard"
    }
    Error(_) -> panic as "Location header should be present"
  }
}

// Test 2: redirect should handle non-Inertia requests with 303 status
pub fn redirect_non_inertia_request_test() {
  let req = wisp_testing.get("/", [])
  let response = inertia.redirect(req, "/home")
  
  // Should be a 303 redirect for non-Inertia requests too
  assert response.status == 303
  
  // Should have location header
  case get_header(response, "location") {
    Ok(location) -> {
      assert location == "/home"
    }
    Error(_) -> panic as "Location header should be present"
  }
}

// Test 3: redirect should handle absolute URLs
pub fn redirect_absolute_url_test() {
  let req = testing.inertia_request()
  let response = inertia.redirect(req, "https://example.com/external")
  
  assert response.status == 303
  
  case get_header(response, "location") {
    Ok(location) -> {
      assert location == "https://example.com/external"
    }
    Error(_) -> panic as "Location header should be present"
  }
}

// Test 4: redirect should handle relative URLs
pub fn redirect_relative_url_test() {
  let req = testing.inertia_request()
  let response = inertia.redirect(req, "../parent")
  
  assert response.status == 303
  
  case get_header(response, "location") {
    Ok(location) -> {
      assert location == "../parent"
    }
    Error(_) -> panic as "Location header should be present"
  }
}

// Test 5: redirect should handle URLs with query parameters
pub fn redirect_with_query_params_test() {
  let req = testing.inertia_request()
  let response = inertia.redirect(req, "/search?q=test&page=2")
  
  assert response.status == 303
  
  case get_header(response, "location") {
    Ok(location) -> {
      assert location == "/search?q=test&page=2"
    }
    Error(_) -> panic as "Location header should be present"
  }
}

// Test 6: redirect should handle URLs with fragments
pub fn redirect_with_fragment_test() {
  let req = testing.inertia_request()
  let response = inertia.redirect(req, "/page#section")
  
  assert response.status == 303
  
  case get_header(response, "location") {
    Ok(location) -> {
      assert location == "/page#section"
    }
    Error(_) -> panic as "Location header should be present"
  }
}

// Test 7: external_redirect should return 409 status
pub fn external_redirect_test() {
  let response = inertia.external_redirect("https://github.com/login")
  
  // Should be a 409 status for external redirects
  assert response.status == 409
  
  // Should have x-inertia-location header
  case get_header(response, "x-inertia-location") {
    Ok(location) -> {
      assert location == "https://github.com/login"
    }
    Error(_) -> panic as "X-Inertia-Location header should be present"
  }
}

// Test 8: external_redirect should not have location header
pub fn external_redirect_no_location_header_test() {
  let response = inertia.external_redirect("https://external.com")
  
  assert response.status == 409
  
  // Should NOT have standard location header
  case get_header(response, "location") {
    Ok(_) -> panic as "External redirect should not have location header"
    Error(_) -> Nil  // Expected
  }
  
  // Should have x-inertia-location header
  case get_header(response, "x-inertia-location") {
    Ok(location) -> {
      assert location == "https://external.com"
    }
    Error(_) -> panic as "X-Inertia-Location header should be present"
  }
}

// Test 9: external_redirect should handle complex URLs
pub fn external_redirect_complex_url_test() {
  let complex_url = "https://auth.example.com/oauth/authorize?client_id=123&redirect_uri=https://myapp.com/callback&state=xyz"
  let response = inertia.external_redirect(complex_url)
  
  assert response.status == 409
  
  case get_header(response, "x-inertia-location") {
    Ok(location) -> {
      assert location == complex_url
    }
    Error(_) -> panic as "X-Inertia-Location header should be present"
  }
}

// Test 10: redirect should handle empty URL (edge case)
pub fn redirect_empty_url_test() {
  let req = testing.inertia_request()
  let response = inertia.redirect(req, "")
  
  assert response.status == 303
  
  case get_header(response, "location") {
    Ok(location) -> {
      assert location == ""
    }
    Error(_) -> panic as "Location header should be present even for empty URL"
  }
}

// Test 11: external_redirect should handle empty URL (edge case)
pub fn external_redirect_empty_url_test() {
  let response = inertia.external_redirect("")
  
  assert response.status == 409
  
  case get_header(response, "x-inertia-location") {
    Ok(location) -> {
      assert location == ""
    }
    Error(_) -> panic as "X-Inertia-Location header should be present even for empty URL"
  }
}

// Test 12: redirect behavior should be same for Inertia vs non-Inertia
pub fn redirect_consistency_test() {
  let inertia_req = testing.inertia_request()
  let normal_req = wisp_testing.get("/", [])
  
  let inertia_response = inertia.redirect(inertia_req, "/target")
  let normal_response = inertia.redirect(normal_req, "/target")
  
  // Both should have same status
  assert inertia_response.status == normal_response.status
  assert inertia_response.status == 303
  
  // Both should have same location header
  let inertia_location = case get_header(inertia_response, "location") {
    Ok(loc) -> loc
    Error(_) -> panic as "Inertia redirect should have location"
  }
  
  let normal_location = case get_header(normal_response, "location") {
    Ok(loc) -> loc
    Error(_) -> panic as "Normal redirect should have location"
  }
  
  assert inertia_location == normal_location
  assert inertia_location == "/target"
}