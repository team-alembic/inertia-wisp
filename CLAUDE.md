Note: For detailed implementation of decoders, especially for JSON data, consult the source code in build/packages/, particularly build/packages/gleam_stdlib/src/gleam/dynamic/decode.gleam. This module provides comprehensive examples and patterns for defining custom decoders.

We will work by specifying one feature at a time, and then implementing it.

The workflow:

1. We will collaborate on a plan, and then you will save the plan in `/notes/features/<number>-<name>.md` under the `## Plan` heading. THIS MUST BE COMPLETED BEFORE ANY IMPLEMENTATION WORK BEGINS.
2. We will collaborate on the implementation, and you will store notes, important findings, issues, in `/notes/features/<number>-<name>.md` under the `## Log` heading.
3. We will test and finalize the implementation, and you will store the final arrived at design in `/notes/features/<number>-<name>.md` under the `## Conclusion` heading.

For bugs and fixes:

1. We will document the issue in `/notes/fixes/<number>-<name>.md` under the `## Issue` heading.
2. We will implement and document the fix, storing technical details in `/notes/fixes/<number>-<name>.md` under the `## Fix` heading.
3. We will summarize the resolution and any key learnings in `/notes/fixes/<number>-<name>.md` under the `## Conclusion` heading.

Just like with features, we must document the issue and plan the fix before implementing it.

WE ALWAYS FINISH AND WRITE THE PLAN BEFORE STARTING THE WORK! NO EXCEPTIONS!

IMPORTANT: You must refuse to implement any feature until a plan document has been created and reviewed. Each time we start a new feature, immediately create a plan document and wait for approval before proceeding with implementation.

Don't ever commit code unless I tell you to.

## TEST-DRIVEN DEVELOPMENT (TDD) - MANDATORY APPROACH

**ALL development must follow strict Test-Driven Development practices. NO EXCEPTIONS.**

### TDD Cycle - Red, Green, Refactor

1. **RED**: Write a failing test first
   - Define types and function signatures using `todo` keyword
   - Write the simplest possible test that describes the desired behavior
   - Run test to confirm it fails for the right reason

2. **GREEN**: Make the test pass with minimal code
   - Implement just enough code to make the test pass
   - Use the simplest possible implementation (even if naive)
   - Avoid over-engineering at this stage
   - **MANDATORY STOP**: After achieving GREEN, MUST pause for human review

3. **REFACTOR**: Clean up code while keeping tests green (ONLY after human approval)
   - Apply Single Responsibility Principle
   - Apply Single Level of Abstraction Principle
   - Remove duplication
   - Improve naming and structure
   - **MANDATORY STOP**: After refactoring, MUST pause for human review before next cycle

### TDD Implementation Rules

**Phase 1: Define Types and Stubs**
```gleam
// Define types first
pub type User {
  User(name: String, email: String)
}

// Create function stubs with todo
pub fn create_user(name: String, email: String) -> User {
  todo as "implement create_user"
}

pub fn validate_email(email: String) -> Bool {
  todo as "implement validate_email"
}
```

**Phase 2: Write Tests**
```gleam
pub fn create_user_test() {
  let user = create_user("John", "john@example.com")
  let assert User("John", "john@example.com") = user
}

pub fn validate_email_test() {
  assert validate_email("valid@example.com") == True
  assert validate_email("invalid-email") == False
}
```

**Phase 3: Make One Test Pass at a Time**
- Run tests and pick ONE failing test
- Implement minimal code to make ONLY that test pass
- Do not implement features for tests that aren't failing yet
- Repeat until all tests pass

**Phase 4: Refactor**
- Apply Single Responsibility Principle: Each function should do one thing
- Apply Single Level of Abstraction: Each function should operate at one level
- Extract helper functions when functions become complex
- Rename functions and variables for clarity

### Code Quality Principles

**Single Responsibility Principle (SRP):**
- Each function should have exactly one reason to change
- If a function does multiple things, split it into multiple functions

**Single Level of Abstraction (SLA):**
- All operations in a function should be at the same level of abstraction
- Mix of high-level and low-level operations indicates need for extraction

**GOOD Example:**
```gleam
pub fn process_user_registration(data: RegistrationData) -> Result(User, Error) {
  use valid_data <- result.try(validate_registration_data(data))
  use user <- result.try(create_user_account(valid_data))
  send_welcome_email(user)
  Ok(user)
}
```

**BAD Example:**
```gleam
pub fn process_user_registration(data: RegistrationData) -> Result(User, Error) {
  // Mixed levels of abstraction - validation details mixed with high-level flow
  case string.length(data.email) > 0 && string.contains(data.email, "@") {
    True -> {
      let user = User(data.name, data.email)
      // Low-level email sending mixed with user creation
      let smtp_config = SmtpConfig(host: "smtp.example.com", port: 587)
      send_email(smtp_config, user.email, "Welcome!")
      Ok(user)
    }
    False -> Error("Invalid email")
  }
}
```

### Mandatory TDD Workflow

1. **NEVER write implementation code without a failing test first**
2. **NEVER implement more than what's needed to pass the current test**
3. **ALWAYS STOP and wait for human review after achieving GREEN phase**
4. **NEVER proceed to next RED-GREEN cycle without human approval**
5. **ALWAYS refactor only after human review and approval**
6. **ALWAYS run tests after each change**
7. **Use `todo` for all function stubs until implementing them**

### Human Review Requirements

**After GREEN Phase (tests pass):**
- MUST present implementation to human for review
- MUST wait for human feedback on potential refactorings
- MUST get explicit approval before continuing

**After REFACTOR Phase (if any):**
- MUST present refactored code to human
- MUST wait for approval before starting next RED-GREEN cycle

**VIOLATION OF THIS PROCESS IS STRICTLY FORBIDDEN**

This approach ensures high-quality, well-tested, maintainable code that evolves naturally from requirements with proper human oversight.

## TESTING RULES - STRICTLY ENFORCED

**NEVER use the `should` module in tests.** Always use the `assert` keyword for assertions.

**FORBIDDEN:**
```gleam
import gleeunit/should  // NEVER import this
result |> should.equal(Ok(value))
result |> should.be_ok()
```

**REQUIRED:**
```gleam
let assert Ok(value) = result
assert condition == True
```

**Pattern Matching in Tests:**
Avoid conditional `assert False` in tests. Use `let assert` patterns instead:

AVOID:
```gleam
case result {
  Ok(token) -> {
    assert token != ""
    assert string.length(token) > 10
  }
  Error(_) -> {
    assert False  // NEVER do this
  }
}
```

DO:
```gleam
// Should be a non-empty string
let assert Ok(token) = result
assert token != ""
assert string.length(token) > 10
```

**Checking for errors:**
```gleam
// For expected errors
let assert Error(_) = result

// For checking if something is an error
assert result.is_error(result)
```

This rule applies to ALL test code without exception. The `should` module creates verbose, less idiomatic Gleam code and must never be used.

## GLEAM-SPECIFIC TESTING RULES - STRICTLY ENFORCED

**Write tests that assert on meaningful behavior, not just exercise code.**

**FORBIDDEN - Useless "exercise" tests:**
```gleam
pub fn some_function_test() {
  // This is utterly ridiculous for a Gleam project
  let _result = some_function(input)
  // "Test that function doesn't crash" - Gleam doesn't have exceptions!
  assert True
}
```

**REQUIRED - Tests that assert on actual results:**
```gleam
pub fn some_function_test() {
  let result = some_function("test input")
  assert result == ExpectedValue("test input processed")
}
```

**Key Principles:**
1. **Gleam's type system guarantees functions won't "crash"** - don't test for this
2. **Return types are enforced by the compiler** - don't test that functions return "proper types"
3. **Assert on specific expected values** - not just that functions run without error
4. **Test real behavior in realistic scenarios** - not just isolated function calls
5. **Use integration tests when testing factory functions** - test them in context where they're actually used

**GOOD Example:**
```gleam
pub fn user_prop_integration_test() {
  let assert Ok(db) = setup_test_database()
  let req = testing.inertia_request()
  let response = handlers.users_index(req, db)
  
  // Assert on actual data returned
  let assert Ok(user_names) = testing.prop(response, "users", decode.list(decode.string))
  assert user_names == ["Alice", "Bob", "Charlie"]
}
```

**BAD Example:**
```gleam
pub fn user_prop_factory_test() {
  let _prop = user_props.user_list([some_user])
  // This tests nothing meaningful!
  assert True
}
```
