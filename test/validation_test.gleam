import gleam/dict
import gleam/option
import gleeunit
import gleeunit/should
import inertia_gleam/validate

pub fn main() {
  gleeunit.main()
}

// Basic validation tests
pub fn validate_field_success_test() {
  let result =
    validate.validation_pipeline(fn() {
      use <- validate.validate_field("name", "John", validate.non_empty_string)
      validate.validation_valid("John")
    })

  should.equal(result, Ok("John"))
}

pub fn validate_field_failure_test() {
  let result =
    validate.validation_pipeline(fn() {
      use <- validate.validate_field("name", "", validate.non_empty_string)
      validate.validation_valid("test")
    })

  should.equal(result, Error(dict.from_list([#("name", "is required")])))
}

pub fn validate_field_multiple_errors_test() {
  let result =
    validate.validation_pipeline(fn() {
      use <- validate.validate_field("name", "", validate.non_empty_string)
      use <- validate.validate_field("email", "", validate.non_empty_string)
      validate.validation_valid("test")
    })

  let expected_errors = dict.from_list([
    #("name", "is required"),
    #("email", "is required"),
  ])
  should.equal(result, Error(expected_errors))
}

// Optional validation tests
pub fn validate_optional_field_none_test() {
  let result =
    validate.validation_pipeline(fn() {
      use <- validate.validate_optional_field("nickname", option.None, validate.non_empty_string)
      validate.validation_valid("success")
    })

  should.equal(result, Ok("success"))
}

pub fn validate_optional_field_some_valid_test() {
  let result =
    validate.validation_pipeline(fn() {
      use <- validate.validate_optional_field("nickname", option.Some("Johnny"), validate.non_empty_string)
      validate.validation_valid("success")
    })

  should.equal(result, Ok("success"))
}

pub fn validate_optional_field_some_invalid_test() {
  let result =
    validate.validation_pipeline(fn() {
      use <- validate.validate_optional_field("nickname", option.Some(""), validate.non_empty_string)
      validate.validation_valid("test")
    })

  should.equal(result, Error(dict.from_list([#("nickname", "is required")])))
}

// Pipeline tests
pub fn validation_pipeline_empty_test() {
  let result = validate.validation_pipeline(fn() {
    validate.validation_valid(42)
  })

  should.equal(result, Ok(42))
}

pub fn validation_pipeline_complex_test() {
  let result =
    validate.validation_pipeline(fn() {
      use <- validate.validate_field("username", "john_doe", validate.non_empty_string)
      use <- validate.validate_field("password", "secret123", validate.min_length(8))
      use <- validate.validate_optional_field("email", option.Some("john@example.com"), validate.contains("@"))
      validate.validation_valid(#("john_doe", "secret123", "john@example.com"))
    })

  should.equal(result, Ok(#("john_doe", "secret123", "john@example.com")))
}

// Error accumulation tests
pub fn accumulate_errors_all_valid_test() {
  let results = [
    validate.validation_valid("a"),
    validate.validation_valid("b"),
    validate.validation_valid("c"),
  ]

  let result = validate.accumulate_errors(results)
  should.equal(result, validate.validation_valid(["a", "b", "c"]))
}

pub fn accumulate_errors_mixed_test() {
  let results = [
    validate.validation_valid("a"),
    validate.Invalid(dict.from_list([#("field1", "error1")])),
    validate.validation_valid("c"),
    validate.Invalid(dict.from_list([#("field2", "error2")])),
  ]

  let result = validate.accumulate_errors(results)
  let expected_errors = dict.from_list([
    #("field1", "error1"),
    #("field2", "error2"),
  ])
  should.equal(result, validate.Invalid(expected_errors))
}

pub fn accumulate_errors_empty_list_test() {
  let result = validate.accumulate_errors([])
  should.equal(result, validate.validation_valid([]))
}

// Common validator tests
pub fn non_empty_string_valid_test() {
  should.equal(validate.non_empty_string("hello"), Ok("hello"))
}

pub fn non_empty_string_with_whitespace_test() {
  should.equal(validate.non_empty_string("  hello  "), Ok("hello"))
}

pub fn non_empty_string_empty_test() {
  should.equal(validate.non_empty_string(""), Error("is required"))
}

pub fn non_empty_string_whitespace_only_test() {
  should.equal(validate.non_empty_string("   "), Error("is required"))
}

pub fn min_length_valid_test() {
  let validator = validate.min_length(5)
  should.equal(validator("hello"), Ok("hello"))
  should.equal(validator("hello world"), Ok("hello world"))
}

pub fn min_length_invalid_test() {
  let validator = validate.min_length(5)
  should.equal(validator("hi"), Error("must be at least 5 characters"))
}

pub fn max_length_valid_test() {
  let validator = validate.max_length(10)
  should.equal(validator("hello"), Ok("hello"))
  should.equal(validator("hello test"), Ok("hello test"))
}

pub fn max_length_invalid_test() {
  let validator = validate.max_length(5)
  should.equal(validator("hello world"), Error("must be at most 5 characters"))
}

pub fn contains_valid_test() {
  let validator = validate.contains("@")
  should.equal(validator("user@example.com"), Ok("user@example.com"))
}

pub fn contains_invalid_test() {
  let validator = validate.contains("@")
  should.equal(validator("userexample.com"), Error("must contain '@'"))
}

pub fn combine_validators_all_pass_test() {
  let validator = validate.combine([
    validate.non_empty_string,
    validate.min_length(3),
    validate.max_length(10),
  ])
  should.equal(validator("hello"), Ok("hello"))
}

pub fn combine_validators_first_fails_test() {
  let validator = validate.combine([
    validate.non_empty_string,
    validate.min_length(3),
  ])
  should.equal(validator(""), Error("is required"))
}

pub fn combine_validators_second_fails_test() {
  let validator = validate.combine([
    validate.non_empty_string,
    validate.min_length(10),
  ])
  should.equal(validator("hello"), Error("must be at least 10 characters"))
}

pub fn combine_validators_empty_list_test() {
  let validator = validate.combine([])
  should.equal(validator("anything"), Ok("anything"))
}

// Complex scenario tests
pub fn user_registration_validation_success_test() {
  let result =
    validate.validation_pipeline(fn() {
      use <- validate.validate_field("username", "john_doe", validate.combine([
        validate.non_empty_string,
        validate.min_length(3),
        validate.max_length(20),
      ]))
      use <- validate.validate_field("email", "john@example.com", validate.combine([
        validate.non_empty_string,
        validate.contains("@"),
      ]))
      use <- validate.validate_field("password", "secret123!", validate.combine([
        validate.non_empty_string,
        validate.min_length(8),
      ]))
      use <- validate.validate_optional_field("full_name", option.Some("John Doe"), validate.non_empty_string)
      validate.validation_valid(#("john_doe", "john@example.com", "secret123!", "John Doe"))
    })

  should.equal(result, Ok(#("john_doe", "john@example.com", "secret123!", "John Doe")))
}

pub fn user_registration_validation_multiple_errors_test() {
  let result =
    validate.validation_pipeline(fn() {
      use <- validate.validate_field("username", "", validate.non_empty_string)
      use <- validate.validate_field("email", "invalid-email", validate.contains("@"))
      use <- validate.validate_field("password", "123", validate.min_length(8))
      validate.validation_valid("user")
    })

  let expected_errors = dict.from_list([
    #("username", "is required"),
    #("email", "must contain '@'"),
    #("password", "must be at least 8 characters"),
  ])
  should.equal(result, Error(expected_errors))
}

pub fn validation_with_custom_validator_test() {
  let is_even = fn(n: Int) -> Result(Int, String) {
    case n % 2 {
      0 -> Ok(n)
      _ -> Error("must be even")
    }
  }

  let result =
    validate.validation_pipeline(fn() {
      use <- validate.validate_field("number", 42, is_even)
      validate.validation_valid(42)
    })

  should.equal(result, Ok(42))

  let result2 =
    validate.validation_pipeline(fn() {
      use <- validate.validate_field("number", 43, is_even)
      validate.validation_valid(43)
    })

  should.equal(result2, Error(dict.from_list([#("number", "must be even")])))
}