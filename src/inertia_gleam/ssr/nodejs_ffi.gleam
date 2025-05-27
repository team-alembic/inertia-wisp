import gleam/dynamic.{type Dynamic}
import gleam/dynamic/decode
import gleam/result
import inertia_gleam/types.{type SSRResponse, SSRResponse}

/// External types for Erlang/Elixir interop
pub type Atom

pub type Pid

/// FFI errors that can occur when calling Node.js
pub type FFIError {
  SupervisorStartError(String)
  NodeCallError(String)
  SerializationError(String)
}

/// Configuration for starting a Node.js supervisor
pub type NodeSupervisorConfig {
  NodeSupervisorConfig(path: String, pool_size: Int, name: String)
}

// Direct FFI calls to NodeJS Elixir package
@external(erlang, "Elixir.NodeJS.Supervisor", "start_link")
fn nodejs_supervisor_start_link(
  opts: List(#(Atom, Dynamic)),
) -> Result(Pid, Dynamic)

@external(erlang, "Elixir.NodeJS", "call")
fn nodejs_call(
  module: Dynamic,
  args: List(Dynamic),
  opts: List(#(Atom, Dynamic)),
) -> Result(Dynamic, Dynamic)

// Helper to create atoms from strings
@external(erlang, "erlang", "binary_to_atom")
fn atom_from_string(s: String) -> Atom

/// Start a Node.js supervisor with the given configuration
pub fn start_supervisor(config: NodeSupervisorConfig) -> Result(Pid, FFIError) {
  let opts = [
    #(atom_from_string("path"), to_dynamic(config.path)),
    #(atom_from_string("pool_size"), to_dynamic(config.pool_size)),
    #(atom_from_string("name"), to_dynamic(atom_from_string(config.name))),
  ]

  nodejs_supervisor_start_link(opts)
  |> result.map_error(fn(_err) {
    SupervisorStartError("Failed to start NodeJS supervisor")
  })
}

/// Call the render function in a Node.js module
pub fn call_render(
  module: String,
  page: Dynamic,
  supervisor_name: String,
  timeout_ms: Int,
) -> Result(SSRResponse, FFIError) {
  // Create {module, "render"} tuple for the function call
  let module_tuple = #(module, "render")
  let args = [page]
  let opts = [
    #(atom_from_string("binary"), to_dynamic(True)),
    #(atom_from_string("name"), to_dynamic(atom_from_string(supervisor_name))),
    #(atom_from_string("timeout"), to_dynamic(timeout_ms)),
  ]
  let dynamic_module = to_dynamic(module_tuple)

  nodejs_call(dynamic_module, args, opts)
  |> result.map_error(fn(_err) {
    // echo err
    NodeCallError("SSR render failed")
  })
  |> result.then(fn(ssr_result) {
    let decoder = {
      use head <- decode.field("head", decode.list(decode.string))
      use body <- decode.field("body", decode.string)
      decode.success(SSRResponse(head, body))
    }
    decode.run(ssr_result, decoder)
    |> result.map_error(fn(_err) {
      // echo err
      NodeCallError("SSR result decode failed")
    })
  })
}

/// Check if a Node.js supervisor is running
pub fn supervisor_running(_name: String) -> Bool {
  // For now, just return False since we don't have a supervisor running
  // In Phase 2, this will be properly implemented
  False
}

// Helper to convert any value to Dynamic
@external(erlang, "gleam@dynamic", "from")
fn to_dynamic(value: a) -> Dynamic

/// Convert a Gleam string to an Erlang atom
pub fn string_to_atom(s: String) -> Atom {
  atom_from_string(s)
}
