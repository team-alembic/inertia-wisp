# Fix #001: gleam_otp API Breaking Changes

## Issue

After updating mist to version 5.0 and wisp to version 1.8, the project fails to compile due to breaking changes in gleam_otp library, which was automatically updated from version 0.16.1 to 1.0.0.

The compilation errors include:

1. **Module import issues:**
   - `gleam/otp/supervisor` module not found (should be `gleam/otp/supervision`)

2. **Actor API changes:**
   - `actor.start_spec()` function signature changed
   - `actor.Spec` constructor changed
   - `actor.Ready` constructor changed
   - `actor.Next` type parameters order changed

3. **Process call API changes:**
   - `process.call()` function signature changed - parameter order is different

4. **Supervision API changes:**
   - `supervisor.ChildSpec` moved to `supervision.ChildSpec`
   - `supervisor.worker` moved to `supervision.worker`

### Affected Files:
- `src/inertia_wisp/internal/ssr/supervisor.gleam`

### Dependencies Updated:
- gleam_otp: 0.16.1 → 1.0.0
- gleam_erlang: 0.34.0 → 1.0.0
- glisten: 7.0.1 → 8.0.0
- gramps: 3.0.1 → 3.0.2
- mist: 4.0.7 → 5.0.0 ✅
- wisp: 1.7.0 → 1.8.0 ✅

## Fix

The fix involved updating the SSR supervisor code to use the new gleam_otp 1.0.0 API:

1. **Updated imports**: Changed `gleam/otp/supervisor` to `gleam/otp/supervision`

2. **Actor initialization**: Replaced `actor.start_spec()` with the new builder pattern:
   ```gleam
   actor.new(initial_state)
   |> actor.on_message(handle_message)
   |> actor.start
   ```

3. **Message handler signature**: Changed parameter order from `(message, state)` to `(state, message)`

4. **Process calls**: Replaced `process.call()` with `actor.call()` and updated parameter order from `(subject, message, timeout)` to `(subject, timeout, make_message)`

5. **Supervision child specs**: Updated to use `supervision.ChildSpecification(Subject(SSRMessage))` and handle the new `actor.Started(pid, data)` structure

6. **Return types**: Updated the `start_link` function to properly extract the subject from `actor.Started`

The most significant changes were:
- Actor initialization now uses a builder pattern
- Process calls use a callback function pattern instead of direct message constructors
- Child specifications require explicit type parameters and proper handling of Started structs

## Conclusion

The fix was successfully implemented and all tests pass. The new gleam_otp 1.0.0 API provides a more consistent and type-safe interface compared to the 0.x versions. The breaking changes were primarily:

- More explicit type annotations required
- Builder pattern for actor creation
- Callback-based message sending instead of direct constructors
- Better separation of concerns in the supervision tree

The updated dependency versions are now:
- mist: 4.0.7 → 5.0.0 ✅
- wisp: 1.7.0 → 1.8.0 ✅
- gleam_otp: 0.16.1 → 1.0.0 ✅ (API compatibility fixed)
- gleam_erlang: 0.34.0 → 1.0.0 ✅
- Additional dependencies updated as required by the new versions

## Examples Updates

All example applications in the `examples/` directory were also updated:

### examples/demo
- Updated dependencies to mist 5.0.0 and wisp 1.8.0
- Fixed `mist.start_http` → `mist.start`
- Fixed `process.start` → `process.spawn` in dev script

### examples/typed-demo/backend
- Updated dependencies to mist 5.0.0 and wisp 1.8.0  
- Fixed `mist.start_http` → `mist.start`
- Fixed `process.start` → `process.spawn` in dev script

### examples/typed-demo/shared_types
- Dependencies automatically updated through the main project

### Breaking Changes Fixed in Examples
1. **mist 5.0.0**: `start_http()` function removed, replaced with `start()`
2. **gleam_erlang 1.0.0**: `process.start(fn, bool)` replaced with `process.spawn(fn)`

All examples now compile successfully and are compatible with the new versions.