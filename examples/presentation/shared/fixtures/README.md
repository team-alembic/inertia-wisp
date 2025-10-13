# JSON Fixtures for Type Safety Testing

This directory contains JSON fixtures that serve as the contract between the Gleam backend and TypeScript frontend.

## Purpose

These fixtures ensure that:
1. **Gleam encoders** produce the correct JSON structure
2. **Zod schemas** validate the expected JSON structure
3. **Backend and frontend stay in sync** - changes to either side that break the contract will fail tests

## How It Works

### The Contract

Each fixture file represents the expected JSON format for a specific data type:

- `image_data.json` - ImageData structure
- `content_block_heading.json` - Heading content block
- `content_block_code.json` - Code block with syntax highlighting
- `content_block_columns.json` - Recursive columns layout
- `slide.json` - Complete slide with multiple content blocks
- `slide_navigation.json` - Navigation state

### Backend Tests (Gleam)

Location: `backend/test/fixtures_test.gleam`

These tests:
1. Create Gleam data structures
2. Encode them to JSON using production encoders
3. Compare the output to the fixture files

**Example:**
```gleam
pub fn slide_encodes_to_fixture_test() {
  let slide = content.Slide(
    number: 1,
    title: "Welcome",
    content: [...],
    notes: "..."
  )
  
  let encoded = content.slide_to_json(slide) |> json.to_string()
  let fixture = read_fixture("slide.json")
  
  assert normalize_json(encoded) == normalize_json(fixture)
}
```

### Frontend Tests (TypeScript)

Location: `frontend/test/fixtures.test.ts`

These tests:
1. Load fixture files from disk
2. Parse them as JSON
3. Validate them against Zod schemas
4. Assert on specific expected values

**Example:**
```typescript
it('validates slide fixture against Zod schema', () => {
  const fixture = loadFixture('slide.json')
  const result = SlideSchema.safeParse(fixture)
  
  expect(result.success).toBe(true)
  expect(result.data.number).toBe(1)
  expect(result.data.title).toBe('Welcome to Inertia-Wisp')
})
```

## Running the Tests

### Backend Tests
```bash
cd backend
gleam test
```

### Frontend Tests
```bash
cd frontend
npm install  # Install vitest if not already installed
npm test
```

## Benefits

1. **Single Source of Truth**: Fixtures define the exact contract
2. **Independent Testing**: Backend and frontend tests run separately
3. **Easy Debugging**: Failed tests point directly to the mismatch
4. **Documentation**: Fixtures show developers the exact expected format
5. **Version Control**: Changes to the contract are visible in git diffs
6. **No Complex Setup**: No need to run JavaScript from Gleam or vice versa

## Adding New Fixtures

When adding a new data type that crosses the backend/frontend boundary:

1. **Create the fixture file** in this directory with example data
2. **Add backend test** in `backend/test/fixtures_test.gleam`:
   ```gleam
   pub fn my_type_encodes_to_fixture_test() {
     let data = MyType(...)
     let encoded = my_type_to_json(data) |> json.to_string()
     let fixture = read_fixture("my_type.json")
     assert normalize_json(encoded) == normalize_json(fixture)
   }
   ```
3. **Add frontend test** in `frontend/test/fixtures.test.ts`:
   ```typescript
   it('validates my_type fixture against Zod schema', () => {
     const fixture = loadFixture('my_type.json')
     const result = MyTypeSchema.safeParse(fixture)
     expect(result.success).toBe(true)
     // Assert on specific fields
   })
   ```

## TDD Workflow

When changing data structures:

1. **Update the fixture** to reflect the desired change
2. **Run backend tests** - they should fail (RED)
3. **Update Gleam type and encoder** - tests should pass (GREEN)
4. **Run frontend tests** - they should fail (RED)
5. **Update Zod schema** - tests should pass (GREEN)
6. **Refactor** both sides as needed

This ensures both sides stay in sync throughout the development process.

## Fixture Guidelines

- **Use realistic data**: Fixtures should represent actual use cases
- **Cover edge cases**: Include examples of optional fields, empty arrays, etc.
- **Keep them minimal**: Only include necessary fields
- **Make them readable**: Pretty-print JSON with proper indentation
- **Test recursive types**: Include examples of nested structures (e.g., Columns blocks)

## What NOT to Test

- **Implementation details**: Don't test internal functions, only public encoders
- **Trivial types**: Simple scalars don't need fixtures
- **Generated code**: Don't test Gleam's JSON encoder or Zod's validator
- **Business logic**: These tests verify structure, not behavior

## Maintenance

When the contract changes:
1. Update the fixture file
2. Update backend encoder and test
3. Update frontend schema and test
4. All tests must pass before merging

This keeps the type safety contract explicit and testable.