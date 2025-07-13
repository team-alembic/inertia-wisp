//// Test utility functions for running EUnit tests with command line filtering
////
//// This module provides a main function that accepts command line arguments for
//// filtering tests by module name pattern, using Erlang's EUnit framework with
//// proper formatting and exit codes.

import gleam/erlang/charlist
import gleam/io
import gleam/list
import gleam/result
import gleam/string

/// Main function for test runner with command line argument support
///
/// Supports filtering tests by module name pattern or running all tests.
/// Usage examples:
/// - `gleam test` - runs all tests
/// - `gleam test -- home_page` - runs tests matching "home_page"
/// - `gleam test -- user` - runs tests matching "user"
///
pub fn main_with_args() -> Nil {
  let args = get_args()

  case args {
    [] -> {
      // No arguments - run all tests like gleeunit.main()
      run_all_tests()
    }
    [filter] -> {
      // Single argument - use as module filter
      run_filtered_tests(filter)
    }
    _multiple -> {
      // Multiple arguments - print usage and exit
      print_usage()
      halt(1)
    }
  }
}

/// Run all tests (equivalent to gleeunit.main())
fn run_all_tests() -> Nil {
  let options = [Verbose, NoTty, Report(#(GleeunitProgress, [Colored(True)]))]

  let result =
    find_files(matching: "**/*.{erl,gleam}", in: "test")
    |> list.map(gleam_to_erlang_module_name)
    |> list.map(dangerously_convert_string_to_atom(_, Utf8))
    |> run_eunit(options)

  let code = case result {
    Ok(_) -> 0
    Error(_) -> 1
  }
  halt(code)
}

/// Run tests filtered by module name pattern
fn run_filtered_tests(filter: String) -> Nil {
  io.println("Running tests matching: " <> filter)

  let options = [Verbose, NoTty, Report(#(GleeunitProgress, [Colored(True)]))]

  let matching_modules =
    find_files(matching: "**/*.{erl,gleam}", in: "test")
    |> list.map(gleam_to_erlang_module_name)
    |> list.filter(fn(module_name) { string.contains(module_name, filter) })

  case matching_modules {
    [] -> {
      io.println("No test modules found matching: " <> filter)
      halt(1)
    }
    modules -> {
      let count = case list.length(modules) {
        1 -> "1"
        2 -> "2"
        3 -> "3"
        _ -> "multiple"
      }
      io.println("Found " <> count <> " matching modules:")
      list.each(modules, fn(module) { io.println("  - " <> module) })
      io.println("")

      let result =
        modules
        |> list.map(dangerously_convert_string_to_atom(_, Utf8))
        |> run_eunit(options)

      let code = case result {
        Ok(_) -> 0
        Error(_) -> 1
      }
      halt(code)
    }
  }
}

/// Print usage information
fn print_usage() -> Nil {
  io.println("Usage:")
  io.println("  gleam test             - run all tests")
  io.println("  gleam test -- <filter> - run tests matching filter")
  io.println("")
  io.println("Examples:")
  io.println("  gleam test -- home_page - run home page tests")
  io.println("  gleam test -- user      - run user-related tests")
}

/// Convert Gleam file path to Erlang module name (same logic as gleeunit)
fn gleam_to_erlang_module_name(path: String) -> String {
  case string.ends_with(path, ".gleam") {
    True ->
      path
      |> string.replace(".gleam", "")
      |> string.replace("/", "@")
    False ->
      path
      |> string.split("/")
      |> list.last
      |> result.unwrap(path)
      |> string.replace(".erl", "")
  }
}

/// Run EUnit tests for a specific module
///
/// This function sets up EUnit with colored output and proper error handling,
/// then runs all test functions in the specified module.
///
/// ## Parameters
/// - `module_name`: The name of the test module to run (e.g., "home_page_test")
///
/// ## Example
/// ```gleam
/// pub fn main() {
///   test_util.run_module_tests("home_page_test")
/// }
/// ```
pub fn run_module_tests(module_name: String) -> Nil {
  let options = [Verbose, NoTty, Report(#(GleeunitProgress, [Colored(True)]))]
  let module_atom = dangerously_convert_string_to_atom(module_name, Utf8)

  let result = run_eunit([module_atom], options)

  let code = case result {
    Ok(_) -> 0
    Error(_) -> 1
  }
  halt(code)
}

// External functions for EUnit integration and command line argument access

@external(erlang, "init", "get_plain_arguments")
fn get_args_raw() -> List(charlist.Charlist)

/// Convert raw args (list of character lists) to strings
fn get_args() -> List(String) {
  get_args_raw()
  |> list.map(charlist.to_string)
}

@external(erlang, "gleeunit_ffi", "find_files")
fn find_files(matching matching: String, in in: String) -> List(String)

type Atom

type Encoding {
  Utf8
}

@external(erlang, "erlang", "binary_to_atom")
fn dangerously_convert_string_to_atom(a: String, b: Encoding) -> Atom

type ReportModuleName {
  GleeunitProgress
}

type GleeunitProgressOption {
  Colored(Bool)
}

type EunitOption {
  Verbose
  NoTty
  Report(#(ReportModuleName, List(GleeunitProgressOption)))
}

@external(erlang, "gleeunit_ffi", "run_eunit")
fn run_eunit(a: List(Atom), b: List(EunitOption)) -> Result(Nil, a)

@external(erlang, "erlang", "halt")
fn halt(a: Int) -> Nil
