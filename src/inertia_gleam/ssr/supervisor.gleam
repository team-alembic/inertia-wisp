import gleam/erlang/process.{type Subject}
import gleam/otp/actor
import gleam/otp/supervisor

import inertia_gleam/ssr/config.{type SSRConfig}
import inertia_gleam/ssr/nodejs_ffi

/// Messages that the SSR supervisor can handle
pub type Message {
  StartNodeJS(reply_with: Subject(Result(Nil, SSRError)))
  StopNodeJS(reply_with: Subject(Result(Nil, SSRError)))
  GetStatus(reply_with: Subject(SSRStatus))
  UpdateConfig(SSRConfig, reply_with: Subject(Result(Nil, SSRError)))
  RenderPage(String, String, reply_with: Subject(Result(String, SSRError)))
}

/// Current status of the SSR system
pub type SSRStatus {
  SSRStatus(enabled: Bool, supervisor_running: Bool, config: SSRConfig)
}

/// SSR supervisor errors
pub type SSRError {
  SupervisorNotStarted
  NodeJSStartFailed(String)
  NodeJSStopFailed(String)
  ConfigurationError(String)
  RenderError(String)
}

/// SSR supervisor state
type State {
  State(config: SSRConfig, nodejs_started: Bool)
}

/// Start the SSR supervisor
pub fn start_link(
  config: SSRConfig,
) -> Result(Subject(Message), actor.StartError) {
  let initial_state = State(config: config, nodejs_started: False)

  actor.start_spec(actor.Spec(
    init: fn() { actor.Ready(initial_state, process.new_selector()) },
    init_timeout: 5000,
    loop: handle_message,
  ))
}

/// Start the SSR supervisor as a child in a supervision tree
pub fn child_spec(config: SSRConfig) -> supervisor.ChildSpec(Message, Nil, Nil) {
  supervisor.worker(fn(_) { start_link(config) })
}

/// Handle messages sent to the SSR supervisor
fn handle_message(message: Message, state: State) -> actor.Next(Message, State) {
  case message {
    StartNodeJS(client) -> {
      case state.nodejs_started {
        True -> {
          process.send(client, Ok(Nil))
          actor.continue(state)
        }
        False -> {
          let node_config =
            nodejs_ffi.NodeSupervisorConfig(
              path: state.config.path,
              pool_size: state.config.pool_size,
              name: state.config.supervisor_name,
            )

          case nodejs_ffi.start_supervisor(node_config) {
            Ok(_) -> {
              let new_state = State(..state, nodejs_started: True)
              process.send(client, Ok(Nil))
              actor.continue(new_state)
            }
            Error(nodejs_ffi.SupervisorStartError(msg)) -> {
              process.send(client, Error(NodeJSStartFailed(msg)))
              actor.continue(state)
            }
            Error(_) -> {
              process.send(client, Error(NodeJSStartFailed("Unknown error")))
              actor.continue(state)
            }
          }
        }
      }
    }

    StopNodeJS(client) -> {
      // For now, we'll just mark as stopped since nodejs package doesn't expose stop
      let new_state = State(..state, nodejs_started: False)
      process.send(client, Ok(Nil))
      actor.continue(new_state)
    }

    GetStatus(client) -> {
      let status =
        SSRStatus(
          enabled: state.config.enabled,
          supervisor_running: state.nodejs_started,
          config: state.config,
        )
      process.send(client, status)
      actor.continue(state)
    }

    UpdateConfig(new_config, client) -> {
      case config.validate(new_config) {
        Ok(validated_config) -> {
          let new_state = State(..state, config: validated_config)
          process.send(client, Ok(Nil))
          actor.continue(new_state)
        }
        Error(_) -> {
          process.send(
            client,
            Error(ConfigurationError("Invalid configuration")),
          )
          actor.continue(state)
        }
      }
    }

    RenderPage(page_json, _component, client) -> {
      case state.nodejs_started && state.config.enabled {
        False -> {
          process.send(client, Error(SupervisorNotStarted))
          actor.continue(state)
        }
        True -> {
          case
            nodejs_ffi.call_render(
              state.config.module,
              page_json,
              state.config.supervisor_name,
              state.config.timeout_ms,
            )
          {
            Ok(html) -> {
              process.send(client, Ok(html))
              actor.continue(state)
            }
            Error(nodejs_ffi.NodeCallError(msg)) -> {
              process.send(client, Error(RenderError(msg)))
              actor.continue(state)
            }
            Error(e) -> {
              process.send(client, Error(RenderError("Render failed")))
              actor.continue(state)
            }
          }
        }
      }
    }
  }
}

/// Client functions for interacting with the SSR supervisor
/// Start the Node.js worker pool
pub fn start_nodejs(supervisor: Subject(Message)) -> Result(Nil, SSRError) {
  process.call(supervisor, StartNodeJS, 5000)
}

/// Stop the Node.js worker pool
pub fn stop_nodejs(supervisor: Subject(Message)) -> Result(Nil, SSRError) {
  process.call(supervisor, StopNodeJS, 5000)
}

/// Get the current status of the SSR system
pub fn get_status(supervisor: Subject(Message)) -> SSRStatus {
  process.call(supervisor, GetStatus, 5000)
}

/// Update the SSR configuration
pub fn update_config(
  supervisor: Subject(Message),
  new_config: SSRConfig,
) -> Result(Nil, SSRError) {
  process.call(supervisor, UpdateConfig(new_config, _), 5000)
}

/// Render a page using the SSR system
pub fn render_page(
  supervisor: Subject(Message),
  page_json: String,
  component: String,
) -> Result(String, SSRError) {
  process.call(supervisor, RenderPage(page_json, component, _), 10_000)
}
