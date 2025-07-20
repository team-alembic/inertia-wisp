## WORKFLOW AND PLANNING PROCESS - MANDATORY

We work by specifying one feature or fix at a time, following a structured planning and implementation process.

### Planning Templates

**For Features**: Use `/notes/templates/feature-plan-template.md`
**For Bugs/Fixes**: Use `/notes/templates/fix-plan-template.md`

### Feature Development Workflow

1. **Planning Phase** (MANDATORY FIRST STEP)
   - Copy `/notes/templates/feature-plan-template.md` to `/notes/features/<number>-<name>.md`
   - Complete all sections of the plan template
   - Get human approval before proceeding
   - **NO IMPLEMENTATION WORK BEGINS WITHOUT AN APPROVED PLAN**

2. **Implementation Phase**
   - Follow TDD process strictly (Red → Green → Refactor with human review)
   - One git commit per implementation task
   - Stop for human review after each task completion
   - Update plan tasks to mark completion status

3. **Completion Phase**
   - Update plan to reflect any changes from original design
   - Ensure all implementation tasks are marked complete

### Bug/Fix Development Workflow

1. **Issue Documentation** (MANDATORY FIRST STEP)
   - Copy `/notes/templates/fix-plan-template.md` to `/notes/fixes/<number>-<name>.md`
   - Complete investigation and root cause analysis
   - Design fix approach and get approval
   - **NO FIX IMPLEMENTATION WITHOUT DOCUMENTED ROOT CAUSE**

2. **Fix Implementation**
   - Follow TDD process for fix and regression tests
   - Test fix thoroughly before deployment
   - Update plan tasks to mark completion status

3. **Resolution Documentation**
   - Update monitoring and testing to prevent recurrence

### Critical Rules

- **REFUSE TO IMPLEMENT** any feature without an approved plan document
- **REFUSE TO FIX** any bug without documented root cause analysis
- **ALWAYS COMPLETE PLANNING** before starting work
- **ONE COMMIT PER TASK** with human review between tasks
- **DOCUMENT ALL DECISIONS** in the appropriate plan sections

### Template Usage Guidelines

**For Feature Planning:**
1. Copy `feature-plan-template.md` to `/notes/features/<number>-<name>.md`
2. Complete all six sections thoroughly:
   - Product Level Requirements (business objectives, success metrics)
   - User Level Requirements (motivations, UX affordances)
   - Architectural Constraints (system integration, technical limits)
   - Implementation Design (domain model, workflows, modules)
   - Testing Plan (TDD, integration, performance, product)
   - Implementation Tasks (phased breakdown with checkboxes)

**For Bug/Fix Planning:**
1. Copy `fix-plan-template.md` to `/notes/fixes/<number>-<name>.md`
2. Complete all four sections thoroughly:
   - Issue (problem description, impact, reproduction steps)
   - Root Cause Analysis (investigation findings, system behavior)
   - Fix Design (proposed solution, implementation approach)
   - Testing Plan (verification, regression, production monitoring)

### Implementation Process Rules

**MANDATORY SEQUENCE:**
1. **Planning** → Complete template → Get approval
2. **Implementation** → TDD with human review after each task
3. **Tracking** → Update task completion status in plan

**FORBIDDEN PATTERNS:**
- Starting implementation without approved plan
- Making architectural changes based on assumptions
- Implementing fixes without root cause analysis
- Committing code without explicit human approval

Don't ever commit code unless I tell you to.

## SERVER EXECUTION RULES - STRICTLY ENFORCED

**NEVER run servers or long-running processes.** This includes but is not limited to:
- `gleam run`
- `npm start` / `npm run dev`
- `python -m http.server`
- `cargo run`
- Any server or development process

**ONLY the human runs servers.** Your role is to:
- Implement and modify code
- Provide clear instructions for the human to test
- Never attempt to start, stop, or manage running processes

**VIOLATION OF THIS RULE IS STRICTLY FORBIDDEN**

## INVESTIGATION AND PRECISION RULES - MANDATORY

**ALWAYS investigate before implementing. Never make assumptions about how systems work.**

### Investigation Requirements

**BEFORE proposing any fix or implementation:**

1. **Read actual code/documentation** - Don't assume how libraries or frameworks work
2. **Verify the problem precisely** - Understand exactly what's broken vs what's working
3. **Research established patterns** - Check how official implementations handle similar cases
4. **Confirm expectations** - Ask clarifying questions about expected vs actual behavior

**FORBIDDEN: Making assumptions about system behavior**
```
❌ "The component should work like this..."
❌ "This is probably because..."
❌ "Let me implement this fix..."
```

**REQUIRED: Evidence-based investigation**
```
✅ "Let me check how the official adapter handles this..."
✅ "Looking at the backend code, I can see..."
✅ "The error shows X, which means..."
```

### Precision Requirements

**BE SPECIFIC about what exactly needs to be fixed:**

- Distinguish between symptoms and root causes
- Identify which data is missing vs which is incorrect vs which is delayed
- Understand the difference between frontend rendering issues vs backend data issues
- Verify whether problems are environmental, configuration, or implementation bugs

**Example of precision:**
```
❌ Vague: "The loading states aren't working"
✅ Precise: "User Analytics shows blank while loading, then shows loading skeleton after request completes"
```

### Implementation Validation

**BEFORE implementing any architectural decision:**

1. **Check industry standards** - How do official implementations handle this?
2. **Verify compatibility** - Does this approach align with framework conventions?
3. **Confirm scope** - Are we fixing the right layer of the problem?

**Questions to ask yourself:**
- "Have I confirmed this is how [framework/library] is supposed to work?"
- "What evidence do I have that this approach is correct?"
- "Am I fixing the actual problem or just symptoms?"

**VIOLATION OF THESE RULES WILL BE REJECTED**

## TEST-DRIVEN DEVELOPMENT (TDD) - MANDATORY APPROACH

**ALL development must follow strict Test-Driven Development practices. NO EXCEPTIONS.**

### TDD Cycle - Red, Green, Refactor

1. **RED**: Write a failing test first
   - **FIRST**: Define function signatures using `todo` keyword in production code
   - **THEN**: Write the simplest possible test that describes the desired behavior
   - **FINALLY**: Run test to confirm it fails for the right reason (logic failure, NOT compilation error)

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

**Phase 1: Define Types and Function Stubs (MANDATORY FIRST STEP)**
```gleam
// Define types first
pub type User {
  User(name: String, email: String)
}

// Create function stubs with todo - THIS MUST BE DONE BEFORE WRITING TESTS
pub fn create_user(name: String, email: String) -> User {
  todo as "implement create_user"
}

pub fn validate_email(email: String) -> Bool {
  todo as "implement validate_email"
}
```

**CRITICAL**: Function stubs must exist in production code BEFORE writing tests. Tests failing due to compilation errors (missing functions) violates TDD - tests should fail due to logic, not missing interfaces.

**VIOLATION PREVENTION**: If you find yourself writing tests for non-existent functions that cause compilation errors, STOP. Go back and create the function stubs with `todo` first.

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
8. **CONSOLIDATE redundant tests during RED phase before implementing**

### Human Review Requirements

**During RED Phase (before implementation):**
- MUST review tests for redundancy and consolidate if needed
- MUST ensure each test verifies distinct behavior
- MUST eliminate tests with >80% identical assertions

**After GREEN Phase (tests pass):**
- MUST present implementation to human for review
- MUST wait for human feedback on potential refactorings
- MUST get explicit approval before continuing

**After REFACTOR Phase (if any):**
- MUST present refactored code to human
- MUST wait for approval before starting next RED-GREEN cycle

**VIOLATION OF THIS PROCESS IS STRICTLY FORBIDDEN**

This approach ensures high-quality, well-tested, maintainable code that evolves naturally from requirements with proper human oversight.

## REACT + INERTIA.JS DEVELOPMENT RULES

When working with React and frontend code, you MUST also follow the conventions in `/REACT.md`. Key rules:

**COMPONENT ARCHITECTURE:**
- Keep components under 100 lines (extract sub-components if larger)
- Co-locate loading states with their corresponding components
- Use composition over complex conditional rendering
- Follow the component extraction patterns defined in REACT.md

**INERTIA.JS + REACT INTEGRATION:**
- Components should primarily render props received from backend
- Minimal client-side state (only UI state like forms, modals)
- **useEffect is rarely needed** - when used, MUST include comment justifying why
- Use Inertia's `<Deferred>` component with `fallback` prop for loading states
- Follow the form handling patterns with `useForm` hook

**TYPESCRIPT CONVENTIONS:**
- Always define props interfaces
- Keep frontend types in sync with backend data structures
- Use proper event handler types

Consult `/REACT.md` for complete conventions including Tailwind CSS patterns, testing guidelines, and anti-patterns to avoid.

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

**CRITICAL VIOLATION PREVENTION**: Never use `case` statements with `assert False` fallbacks in tests. This is a code smell that indicates you should use `let assert` patterns instead.

```gleam
// FORBIDDEN - conditional assert False
case result {
  Ok(value) -> {
    // assertions here
  }
  _ -> assert False  // NEVER DO THIS
}

// REQUIRED - let assert patterns
let assert Ok(value) = result
// assertions here
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

**FORBIDDEN - "Doesn't crash" tests:**
```gleam
pub fn json_encoding_test() {
  let json_result = encode_data(data)
  // BAD: Only tests that function doesn't crash
  assert json.to_string(json_result) != ""
}
```

**REQUIRED - Tests that verify actual data:**
```gleam
pub fn json_encoding_test() {
  let json_result = encode_data(data)
  let json_string = json.to_string(json_result)
  // GOOD: Verifies actual JSON structure and values
  assert string.contains(json_string, "\"name\":\"John\"")
  assert string.contains(json_string, "\"active\":true")
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

## MEANINGFUL TEST ASSERTIONS - STRICTLY ENFORCED

**Every test assertion MUST verify the specific behavior the test claims to test. NO EXCEPTIONS.**

**FORBIDDEN - Tests with assertions that don't verify the claimed behavior:**
```gleam
pub fn user_authentication_works_test() {
  let response = auth.login(username, password)
  // This only tests that login doesn't crash, NOT that authentication works!
  assert testing.component(response) == Ok("Dashboard")
}

pub fn expensive_calculation_is_optimized_test() {
  let result = calculate_something(input)
  // This doesn't test optimization at all!
  assert result == ExpectedResult(42)
}

pub fn caching_improves_performance_test() {
  let result = cached_function(input)
  // This doesn't verify caching OR performance!
  assert result.is_ok()
}
```

**REQUIRED - Tests with assertions that verify the actual claimed behavior:**
```gleam
pub fn user_authentication_works_test() {
  let response = auth.login(valid_username, valid_password)

  // Verify successful authentication
  assert testing.component(response) == Ok("Dashboard")

  // Verify user session is created
  let assert Ok(user_id) = testing.prop(response, "current_user_id", decode.int)
  assert user_id > 0

  // Verify authentication token is present
  let assert Ok(token) = testing.prop(response, "auth_token", decode.string)
  assert string.length(token) > 20
}

pub fn expensive_calculation_is_deferred_test() {
  let response = dashboard.load_page(req, db)

  // Verify basic data loads immediately
  let assert Ok(user_count) = testing.prop(response, "user_count", decode.int)
  assert user_count > 0

  // Verify expensive calculation is NOT performed initially (the optimization!)
  let analytics_result = testing.prop(response, "analytics", decode.dynamic)
  assert result.is_error(analytics_result)
}

pub fn cache_prevents_duplicate_database_calls_test() {
  // Clear cache and make initial call
  cache.clear()
  let _first_result = cached_function(input)
  let initial_db_calls = test_db.call_count()

  // Make second call with same input
  let second_result = cached_function(input)
  let final_db_calls = test_db.call_count()

  // Verify cache hit (no additional DB calls)
  assert final_db_calls == initial_db_calls
  assert second_result.is_ok()
}
```

**CRITICAL TESTING PRINCIPLES:**

1. **Test Name Must Match Assertion**: If your test is called `foo_is_optimized_test`, your assertions must verify the optimization
2. **Assert on the Actual Behavior**: Don't just assert that functions return Ok() when testing complex behaviors
3. **Test Both Positive and Negative Cases**: Verify what SHOULD happen AND what SHOULD NOT happen
4. **Be Specific About Expected Values**: Assert on actual data, not just types or success/failure
5. **Verify Side Effects**: If the behavior involves caching, database calls, or state changes, test those effects

**BEHAVIOR-DRIVEN ASSERTION CHECKLIST:**

Before writing any test, ask:
- "What specific behavior am I claiming to test?"
- "Do my assertions actually verify that behavior?"
- "Would this test catch a bug if the behavior was broken?"
- "Am I testing implementation details or actual behavior?"

**This rule applies to ALL tests in ALL modules. Violations will be rejected.**

## TEST QUALITY ENFORCEMENT - MANDATORY PROCESS

**ALL test implementation must follow this mandatory review process to prevent rule violations.**

### Pre-Test Writing Checklist (MANDATORY)

Before writing ANY test function, you MUST:

**STEP 0: Define Function Interfaces (if testing new functions)**
- Add function stubs with `todo` to production code FIRST
- Ensure all tests will COMPILE before writing them
- RED phase = logic failure, NOT compilation failure

Then ask and answer these questions:

1. **"What specific behavior am I claiming to test?"**
   - Write down the exact behavior in one sentence
   - If you can't articulate it clearly, the test is unnecessary

2. **"What assertions will prove that behavior works?"**
   - List the specific values/conditions you'll assert on
   - Vague assertions like "result.is_ok()" are insufficient

3. **"What would break if I removed this test that wouldn't be caught by other tests?"**
   - If the answer is "nothing", the test is redundant

4. **"Does my test name match what I'm actually asserting?"**
   - Test name must precisely describe the verified behavior

### Post-Test Writing Review (MANDATORY)

After writing tests, you MUST:

1. **Re-read each test against FORBIDDEN examples**
   - Compare your test to the "FORBIDDEN" patterns in this document
   - Eliminate any test that matches forbidden patterns

2. **Verify assertion-to-behavior alignment**
   - Read test name, then read assertions
   - Confirm assertions actually verify the claimed behavior

3. **Apply the "Exercise vs Behavior" test**
   - If your test only calls functions without meaningful assertions, DELETE IT
   - If your test just verifies "no crash", DELETE IT

**Active Rule Application (MANDATORY)

When implementing tests:

1. **Keep CLAUDE.md open** - Reference testing rules actively, not from memory
2. **Quote relevant rules** - When explaining test design, cite specific rule violations prevented
3. **Justify every test** - Be prepared to defend why each test adds unique value
4. **Check test names against assertions** - Test name must match what you're actually verifying
5. **Never test framework responsibilities** - Don't test error handling if it's handled by the framework, not your code

**Enforcement Questions

When presenting tests, be prepared to answer:
- "What specific behavior does test X verify?"
- "How do these assertions prove the claimed behavior?"
- "Which tests would you remove and why?"
- "What rule violations did you prevent?"
- "Does this test name match what the assertions actually verify?"
- "Are you testing your code's behavior or framework behavior?"

**COMMON VIOLATIONS TO CHECK FOR:**
1. Using `case` with `assert False` instead of `let assert` patterns
2. Tests that only verify "doesn't crash" instead of actual behavior
3. Test names that don't match what's being asserted
4. Testing framework error handling instead of your code's logic
5. Compilation errors in RED phase instead of logic failures

**FAILURE TO FOLLOW THIS PROCESS WILL RESULT IN REJECTED IMPLEMENTATIONS**

## PRODUCTION CODE PURITY RULES - STRICTLY ENFORCED

**NEVER add conditional behavior in production code that checks for test environment. This indicates poor abstraction.**

**FORBIDDEN - Environment-specific behavior in production code:**
```gleam
pub fn expensive_calculation(data: Data) -> Result(Analytics, Error) {
  // BAD: Conditional test behavior
  let delay = case is_test_environment() {
    True -> 0
    False -> 2000
  }
  process.sleep(delay)

  // actual calculation
  compute_analytics(data)
}

pub fn dashboard_page(req: Request, db: Connection) -> Response {
  // BAD: Different behavior based on test mode
  let use_cache = case is_running_tests() {
    True -> False
    False -> True
  }

  get_data(db, use_cache)
}
```

**REQUIRED - Clean abstraction with explicit parameters:**
```gleam
pub fn expensive_calculation(data: Data, delay_ms: Int) -> Result(Analytics, Error) {
  // GOOD: Explicit parameter, caller controls behavior
  process.sleep(delay_ms)
  compute_analytics(data)
}

pub fn dashboard_page(req: Request, db: Connection) -> Response {
  // GOOD: Extract delay from request, default to 0
  let delay = get_delay_param(req) |> option.unwrap(0)
  expensive_calculation(data, delay)
}
```

**KEY PRINCIPLES:**
1. **No Environment Detection**: Production code never checks if it's running in tests
2. **Explicit Parameters**: Behavior controlled by explicit function parameters
3. **Caller Control**: Test and production callers pass appropriate values
4. **Single Code Path**: Same code runs in all environments
5. **Default to Fast**: Default values should optimize for performance (tests and production)

**VIOLATIONS WILL BE REJECTED:**
- Any `is_test()`, `is_production()`, or similar environment checks
- Different code paths based on runtime environment detection
- Test-specific conditional logic in production modules

## TEST REDUNDANCY AND VALUE RULES - STRICTLY ENFORCED

**Tests are a maintenance burden just like production code. You MUST minimize redundancy and maximize value.**

**FORBIDDEN - Redundant tests that test the same behavior:**
```gleam
pub fn user_loads_immediately_test() {
  let response = users.index(req, db)
  assert testing.component(response) == Ok("Users/Index")
  let assert Ok(users) = testing.prop(response, "users", decode.list(decode.dynamic))
  assert list.length(users) > 0
}

pub fn user_page_renders_test() {
  let response = users.index(req, db)
  assert testing.component(response) == Ok("Users/Index")
  let assert Ok(users) = testing.prop(response, "users", decode.list(decode.dynamic))
  assert list.length(users) > 0
}

pub fn user_list_available_test() {
  let response = users.index(req, db)
  assert testing.component(response) == Ok("Users/Index")
  let assert Ok(users) = testing.prop(response, "users", decode.list(decode.dynamic))
  assert list.length(users) > 0
}
```

**REQUIRED - Minimal, high-value tests that cover distinct behaviors:**
```gleam
pub fn user_index_loads_with_basic_props_test() {
  let response = users.index(req, db)
  assert testing.component(response) == Ok("Users/Index")
  let assert Ok(users) = testing.prop(response, "users", decode.list(decode.dynamic))
  assert list.length(users) > 0
}

pub fn user_index_excludes_expensive_props_by_default_test() {
  let response = users.index(req, db)
  let analytics_result = testing.prop(response, "analytics", decode.dynamic)
  assert result.is_error(analytics_result)
}

pub fn user_index_includes_expensive_props_when_requested_test() {
  let req = testing.inertia_request() |> testing.partial_data(["analytics"])
  let response = users.index(req, db)
  let assert Ok(_analytics) = testing.prop(response, "analytics", decode.dynamic)
}
```

**MANDATORY TEST CONSOLIDATION RULES:**

1. **One Test Per Distinct Behavior**: Never write multiple tests that verify the same system behavior
2. **Eliminate Setup Duplication**: If 3+ tests have identical setup, they're probably testing the same thing
3. **Eliminate Assertion Duplication**: If 3+ tests have identical assertions, consolidate them
4. **Maximum 5 Tests Per Handler Function**: Force yourself to identify the truly distinct behaviors
5. **Each Test Must Add Unique Value**: Ask "What would break if I removed this test that wouldn't be caught by other tests?"

**CONSOLIDATION CHECKLIST:**

Before writing a new test, ask:
- "Does an existing test already verify this behavior?"
- "Can I add one assertion to an existing test instead of creating a new test?"
- "What unique system behavior does this test verify that no other test covers?"
- "If I had to explain why we need both Test A and Test B, could I give distinct reasons?"

**TEST VALUE HIERARCHY (High to Low):**

1. **Integration tests** that verify end-to-end user scenarios
2. **Behavior tests** that verify business logic and edge cases
3. **Contract tests** that verify API boundaries and data shapes
4. **Unit tests** for complex algorithms or validation logic
5. **Exercise tests** that just call functions (DELETE THESE)

**VIOLATIONS WILL BE REJECTED:**
- Writing multiple tests with >80% identical assertions
- Writing tests that only exercise code without verifying behavior
- Creating more than 5 tests for a single handler function
- Adding tests when existing tests already cover the behavior
