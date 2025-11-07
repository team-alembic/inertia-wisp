import gleeunit

/// Main function for test runner with command line argument support
///
/// Supports filtering tests by module name pattern or running all tests.
/// Usage examples:
/// - `gleam test` - runs all tests
/// - `gleam test -- response_builder` - runs tests matching "response_builder"
/// - `gleam test -- prop` - runs tests matching "prop"
///
pub fn main() {
  gleeunit.main()
}
