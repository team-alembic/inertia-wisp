// import gleam/dynamic.{type Dynamic}
// import gleam/erlang/process.{type Subject}
// import gleam/otp/actor
// import gleam/otp/supervision

// import inertia_wisp/internal/ssr/nodejs_ffi
// import inertia_wisp/internal/types.{
//   type SSRConfig, type SSRError, type SSRMessage, GetStatus, NodeJSStartFailed,
//   RenderError, RenderPage, SSRStatus, StartNodeJS, StopNodeJS,
//   SupervisorNotStarted, UpdateConfig,
// }

// /// SSR supervisor state
// type State {
//   State(config: SSRConfig, nodejs_started: Bool)
// }

// /// Start the SSR supervisor
// pub fn start_link(
//   config: SSRConfig,
// ) -> Result(Subject(SSRMessage), actor.StartError) {
//   let initial_state = State(config: config, nodejs_started: False)

//   case
//     actor.new(initial_state)
//     |> actor.on_message(handle_message)
//     |> actor.start
//   {
//     Ok(actor.Started(_, subject)) -> Ok(subject)
//     Error(e) -> Error(e)
//   }
// }

// /// Start the SSR supervisor as a child in a supervision tree
// pub fn child_spec(
//   config: SSRConfig,
// ) -> supervision.ChildSpecification(Subject(SSRMessage)) {
//   supervision.worker(fn() {
//     case start_link(config) {
//       Ok(subject) -> {
//         case process.subject_owner(subject) {
//           Ok(pid) -> Ok(actor.Started(pid, subject))
//           Error(_) -> Error(actor.InitFailed("Failed to get process owner"))
//         }
//       }
//       Error(e) -> Error(e)
//     }
//   })
// }

// /// Handle messages sent to the SSR supervisor
// fn handle_message(
//   state: State,
//   message: SSRMessage,
// ) -> actor.Next(State, SSRMessage) {
//   case message {
//     StartNodeJS(client) -> {
//       case state.nodejs_started {
//         True -> {
//           process.send(client, Ok(Nil))
//           actor.continue(state)
//         }
//         False -> {
//           let node_config =
//             nodejs_ffi.NodeSupervisorConfig(
//               path: state.config.path,
//               pool_size: state.config.pool_size,
//               name: state.config.supervisor_name,
//             )

//           case nodejs_ffi.start_supervisor(node_config) {
//             Ok(_) -> {
//               let new_state = State(..state, nodejs_started: True)
//               process.send(client, Ok(Nil))
//               actor.continue(new_state)
//             }
//             Error(nodejs_ffi.SupervisorStartError(msg)) -> {
//               process.send(client, Error(NodeJSStartFailed(msg)))
//               actor.continue(state)
//             }
//             Error(_) -> {
//               process.send(client, Error(NodeJSStartFailed("Unknown error")))
//               actor.continue(state)
//             }
//           }
//         }
//       }
//     }

//     StopNodeJS(client) -> {
//       // For now, we'll just mark as stopped since nodejs package doesn't expose stop
//       let new_state = State(..state, nodejs_started: False)
//       process.send(client, Ok(Nil))
//       actor.continue(new_state)
//     }

//     GetStatus(client) -> {
//       let status =
//         SSRStatus(
//           enabled: state.config.enabled,
//           supervisor_running: state.nodejs_started,
//           config: state.config,
//         )
//       process.send(client, status)
//       actor.continue(state)
//     }

//     UpdateConfig(new_config, client) -> {
//       let new_state = State(..state, config: new_config)
//       process.send(client, Ok(Nil))
//       actor.continue(new_state)
//     }

//     RenderPage(page, _component, client) -> {
//       case state.nodejs_started && state.config.enabled {
//         False -> {
//           process.send(client, Error(SupervisorNotStarted))
//           actor.continue(state)
//         }
//         True -> {
//           case
//             nodejs_ffi.call_render(
//               state.config.module,
//               page,
//               state.config.supervisor_name,
//               state.config.timeout_ms,
//             )
//           {
//             Ok(ssr_response) -> {
//               process.send(client, Ok(ssr_response))
//               actor.continue(state)
//             }
//             Error(nodejs_ffi.NodeCallError(msg)) -> {
//               process.send(client, Error(RenderError(msg)))
//               actor.continue(state)
//             }
//             Error(_e) -> {
//               process.send(client, Error(RenderError("Render failed")))
//               actor.continue(state)
//             }
//           }
//         }
//       }
//     }
//   }
// }

// /// Client functions for interacting with the SSR supervisor
// /// Start the Node.js worker pool
// pub fn start_nodejs(supervisor: Subject(SSRMessage)) -> Result(Nil, SSRError) {
//   actor.call(supervisor, 5000, fn(client) { StartNodeJS(client) })
// }

// /// Stop the Node.js worker pool
// pub fn stop_nodejs(supervisor: Subject(SSRMessage)) -> Result(Nil, SSRError) {
//   actor.call(supervisor, 5000, fn(client) { StopNodeJS(client) })
// }

// /// Get the current status of the SSR system
// pub fn get_status(supervisor: Subject(SSRMessage)) -> types.SSRStatus {
//   actor.call(supervisor, 5000, fn(client) { GetStatus(client) })
// }

// /// Update the SSR configuration
// pub fn update_config(
//   supervisor: Subject(SSRMessage),
//   new_config: SSRConfig,
// ) -> Result(Nil, SSRError) {
//   actor.call(supervisor, 5000, fn(client) { UpdateConfig(new_config, client) })
// }

// /// Render a page using the SSR system
// pub fn render_page(
//   supervisor: Subject(SSRMessage),
//   page: Dynamic,
//   component: String,
// ) -> Result(types.SSRResponse, SSRError) {
//   actor.call(supervisor, 10_000, fn(client) {
//     RenderPage(page, component, client)
//   })
// }
