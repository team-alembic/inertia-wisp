# Development Guidelines

## 1. WORKFLOW AND PLANNING

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

### Server Execution Rules

**NEVER run servers or long-running processes.** This includes:
- `gleam run`
- `npm start` / `npm run dev`
- `python -m http.server`
- `cargo run`
- Any server or development process

**ONLY the human runs servers.** Your role is to:
- Implement and modify code
- Provide clear instructions for the human to test
- Never attempt to start, stop, or manage running processes

**CRITICAL**: Violating this rule breaks trust. No exceptions.

### Critical Rules

- **REFUSE TO IMPLEMENT** any feature without an approved plan document
- **REFUSE TO FIX** any bug without documented root cause analysis
- **ALWAYS COMPLETE PLANNING** before starting work
- **ONE COMMIT PER TASK** with human review between tasks (VIOLATION: bundling multiple tasks breaks review process)
- **DOCUMENT ALL DECISIONS** in the appropriate plan sections
- **NO WORKAROUNDS** - always fix root causes properly (VIOLATION: manual responses instead of API fixes)
- **INVESTIGATE FIRST** - check existing patterns before implementing (SUCCESS: following user handler patterns)
- **REFACTOR INCREMENTALLY** - one function at a time with tests (VIOLATION: changing multiple functions at once)
- **FETCH EXTERNAL LINKS** - when user provides links, always fetch them before responding
- **UPDATE TESTS FIRST** - when changing implementation, update tests before changing code
- **SIMPLIFY CODE** - prefer simple, clear code over complex patterns (e.g., `let _ = expr` over `use _ <- result.try(expr)`)

Don't ever commit code unless I tell you to.

## 2. IMPLEMENTATION PRACTICES

### Never Create Workarounds

**FORBIDDEN: Creating workarounds when hitting API limitations**
```
❌ "Let me create a manual response to bypass the Response Builder API"
❌ "I'll duplicate this logic to avoid fixing the root cause"
❌ "This workaround will be faster than fixing the proper API"
```

**REQUIRED: Fix the root cause properly**
```
✅ "This API limitation shows we need to extend the Response Builder"
✅ "Let me investigate the proper way to solve this"
✅ "What's the right design that follows framework conventions?"
```

**Why this matters:**
- Workarounds create technical debt and maintenance burden
- They often indicate missing functionality that should be properly implemented
- Proper fixes benefit the entire codebase, not just your immediate need

### Refactor Incrementally - One Function at a Time

**FORBIDDEN: Trying to refactor multiple functions simultaneously**
```
❌ Refactoring 3 functions + extracting helpers + changing patterns all at once
❌ "Let me fix all the nested cases in one big change"
❌ Moving problems into helper functions instead of actually solving them
```

**REQUIRED: Refactor one function at a time, test after each change**
```
✅ Refactor function A → test → commit
✅ Refactor function B → test → commit  
✅ Extract common patterns after individual refactors are proven
```

**Process:**
1. **Pick ONE function** with problematic nested cases
2. **Refactor only that function** using proper patterns (`use` syntax, etc.)
3. **Test immediately** to ensure behavior is unchanged
4. **Commit the single function change**
5. **Repeat for next function**

### Investigate Before Implementing

**MANDATORY: Check existing patterns before writing new code**

**Before implementing any new pattern:**
1. **Search the codebase** for similar functionality
2. **Check how other handlers/modules solve the same problem**
3. **Follow established conventions** rather than inventing new ones
4. **Check external framework documentation** for standard approaches

**Examples from this project:**
- Checked how user handlers parse IDs → led to continuation-passing style
- Investigated Laravel/Phoenix adapters → confirmed 404 status codes are standard
- Examined wisp response functions → led to `inertia.response(builder, status)` API

### API Design Must Follow Framework Conventions

**REQUIRED: New APIs must be consistent with existing patterns**

**When extending APIs:**
```
✅ Follow existing parameter patterns: wisp.json_response(content, status)
✅ Maintain backward compatibility when possible
✅ Use the same naming conventions and parameter order
✅ Match the framework's style and philosophy
```

**FORBIDDEN:**
```
❌ Inventing new parameter patterns that differ from the framework
❌ Breaking existing APIs without migration path
❌ Using different naming conventions than the rest of the codebase
```

### Enforce One-Commit-Per-Task Rule Strictly

**CRITICAL VIOLATION: Bundling multiple tasks into one commit**

Previous violations included bundling:
1. news_feed handler implementation
2. news_article handler implementation  
3. category filtering support
4. integration tests
5. HTTP status code API extension
6. Code refactoring with `use` syntax

**REQUIRED Process:**
1. **Complete ONE task** (implement one handler, add one feature, write one test suite)
2. **STOP and commit** with descriptive message
3. **Get human review** before proceeding to next task
4. **Update plan** to mark task complete
5. **Begin next task** only after approval

**Why this matters:**
- Makes code easier to review and understand
- Enables rollback of specific changes if needed
- Catches issues early through incremental feedback
- Maintains proper TDD discipline with human oversight

### When Refactoring Fails, Step Back

**If a refactoring attempt creates more problems:**
1. **STOP immediately** - don't try to fix a broken refactor with more changes
2. **Revert to working state** 
3. **Analyze what went wrong** - usually trying to change too much at once
4. **Try smaller, incremental changes** - one pattern, one function, one concept
5. **Test after each small change**

**Red flags that indicate you should stop:**
- Compilation errors in multiple places
- Test failures that weren't there before
- Logic that's more complex after refactoring than before
- Having to make "just one more small change" repeatedly

### Investigation and Precision Requirements

**ALWAYS investigate before implementing. Never make assumptions about how systems work.**

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

**BE SPECIFIC about what exactly needs to be fixed:**

- Distinguish between symptoms and root causes
- Identify which data is missing vs which is incorrect vs which is delayed
- Understand the difference between frontend rendering issues vs backend data issues
- Verify whether problems are environmental, configuration, or implementation bugs

**BEFORE implementing any architectural decision:**

1. **Check industry standards** - How do official implementations handle this?
2. **Verify compatibility** - Does this approach align with framework conventions?
3. **Confirm scope** - Are we fixing the right layer of the problem?

**Questions to ask yourself:**
- "Have I confirmed this is how [framework/library] is supposed to work?"
- "What evidence do I have that this approach is correct?"
- "Am I fixing the actual problem or just symptoms?"

## 3. TEST-DRIVEN DEVELOPMENT

### Core TDD Process - Red, Green, Refactor

**ALL development must follow strict Test-Driven Development practices. NO EXCEPTIONS.**

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

### Function Stubs and Test Setup

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

### Testing Standards

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

**AVOID:**
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

**DO:**
```gleam
// Should be a non-empty string
let assert Ok(token) = result
assert token != ""
assert string.length(token) > 10
```

**CRITICAL**: Never work around the "no assert False" rule with nonsense assertions like `assert 1 == 2`. This violates the spirit of the rule.

### Gleam-Specific Testing Rules

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

### Meaningful Test Assertions

**Every test assertion MUST verify the specific behavior the test claims to test. NO EXCEPTIONS.**

**FORBIDDEN - Testing only existence/type correctness:**
```gleam
pub fn pagination_test() {
  let response = handler(req, db)
  // MEANINGLESS - only tests that value exists and decodes
  assert testing.prop(response, "meta", last_page_decoder) |> result.is_ok
  assert testing.prop(response, "meta", has_more_decoder) |> result.is_ok
}
```

**REQUIRED - Testing actual expected values:**
```gleam
pub fn pagination_test() {
  let response = handler(req, db)
  // MEANINGFUL - tests actual expected behavior
  assert testing.prop(response, "meta", last_page_decoder) == Ok(3)
  assert testing.prop(response, "meta", has_more_decoder) == Ok(True)
}
```

**DETERMINISTIC TESTING REQUIREMENT:**
- Tests must control input data to ensure predictable outputs
- Never use conditional assertions like `case last_page { 0 -> ..., _ -> ... }`
- Use controlled test data (e.g., "insert exactly 25 articles") to test exact expected values

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
```

### Test Quality Enforcement

**ALL test implementation must follow this mandatory review process to prevent rule violations.**

**MANDATORY PROCESS: Update Tests Before Implementation Changes**

When changing implementation (especially API configurations), ALWAYS:

1. **Identify affected tests** - find tests that verify the behavior being changed
2. **Update test expectations** - change test assertions to expect new behavior
3. **Run tests to confirm they fail** (RED phase)
4. **Then make implementation changes** (GREEN phase)
5. **Verify tests now pass**

**Example of correct process:**
```
1. Need to change MergeProp from deep: False to deep: True
2. Find test: assert deep == False
3. Update test: assert deep == True  
4. Run test - it fails (RED)
5. Change implementation: deep: True
6. Run test - it passes (GREEN)
```

**VIOLATION**: Changing implementation first, then being surprised by test failures.

**Pre-Test Writing Checklist (MANDATORY)**

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

**Post-Test Writing Review (MANDATORY)**

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

### Test Redundancy and Value Rules

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

## 4. CODE QUALITY RULES

### Production Code Purity

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
```

**REQUIRED - Clean abstraction with explicit parameters:**
```gleam
pub fn expensive_calculation(data: Data, delay_ms: Int) -> Result(Analytics, Error) {
  // GOOD: Explicit parameter, caller controls behavior
  process.sleep(delay_ms)
  compute_analytics(data)
}
```

**KEY PRINCIPLES:**
1. **No Environment Detection**: Production code never checks if it's running in tests
2. **Explicit Parameters**: Behavior controlled by explicit function parameters
3. **Caller Control**: Test and production callers pass appropriate values
4. **Single Code Path**: Same code runs in all environments
5. **Default to Fast**: Default values should optimize for performance (tests and production)

## 5. FRAMEWORK-SPECIFIC RULES

### React + Inertia.js Development

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

---

These rules were strengthened after real implementation problems in news feed development where:
- Workarounds were attempted instead of proper API fixes
- Multiple tasks were bundled into one commit instead of incremental review
- Refactoring tried to change too much at once instead of one function at a time
- Investigation of existing patterns led to much better solutions

**VIOLATION OF THESE RULES WILL BE REJECTED**

## 6. CRITICAL LESSONS FROM TASK 2 INFINITE SCROLL IMPLEMENTATION

### Rule Violations That Occurred and Must Be Prevented:

**1. SERVER EXECUTION VIOLATION (ZERO TOLERANCE)**
- **WHAT HAPPENED**: Executed `gleam run &` in terminal
- **WHY WRONG**: Only humans run servers, this is fundamental
- **PREVENTION**: Never use terminal for long-running processes, only provide instructions

**2. MEANINGLESS TEST ASSERTIONS (UNACCEPTABLE)**
- **WHAT HAPPENED**: `assert testing.prop(...) |> result.is_ok` (testing existence, not values)
- **WHY WRONG**: Tests should verify actual expected behavior, not just that values exist
- **PREVENTION**: Always assert on specific expected values, make tests deterministic

**3. IMPLEMENTATION-FIRST INSTEAD OF TDD (BREAKS PROCESS)**
- **WHAT HAPPENED**: Changed `deep: False` to `deep: True` before updating test
- **WHY WRONG**: Violates TDD RED-GREEN-REFACTOR cycle
- **PREVENTION**: Always update test expectations BEFORE changing implementation

**4. IGNORING USER-PROVIDED RESOURCES (INEFFICIENT)**
- **WHAT HAPPENED**: Didn't fetch external links when user provided them
- **WHY WRONG**: Leads to assumptions instead of evidence-based solutions
- **PREVENTION**: Always fetch and read provided links before responding

**5. OVERCOMPLICATING SOLUTIONS (POOR ENGINEERING)**
- **WHAT HAPPENED**: Custom intersection observer instead of built-in `<WhenVisible>`
- **WHY WRONG**: Reinventing wheels instead of using framework capabilities
- **PREVENTION**: Research existing solutions before implementing custom logic

**6. NEEDLESSLY COMPLEX SYNTAX (POOR READABILITY)**
- **WHAT HAPPENED**: `use _ <- result.try(expr)` when `let _ = expr` suffices
- **WHY WRONG**: Complex syntax when simple patterns work
- **PREVENTION**: Prefer simplicity - if ignoring results, just use `let _ = expr`

**7. GETTING SIDETRACKED BY TEST FAILURES (LOSING FOCUS)**
- **WHAT HAPPENED**: Debugging database setup instead of focusing on TDD RED phase
- **WHY WRONG**: Lost sight of TDD process and task objectives
- **PREVENTION**: Stay focused on current task phase, don't chase unrelated issues

### Success Patterns That Should Be Repeated:

**1. USING ECHO DEBUGGING EFFECTIVELY**
- Added echo statements to understand data flow
- Helped identify root cause (category filtering bug)
- Removed debug statements after fixing issue

**2. PROPER COMPONENT REFACTORING**
- Extracted logical sections into focused components
- Followed single responsibility principle
- Made codebase more maintainable for LLMs and humans

**3. INVESTIGATING EXISTING PATTERNS**
- Looked at how other handlers solve similar problems
- Found and fixed category filtering bug by understanding query logic
- Led to better solutions than inventing new patterns

These lessons are critical for future task implementation.