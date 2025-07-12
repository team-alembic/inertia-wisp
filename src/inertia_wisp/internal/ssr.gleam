// // FIXME: SSR
// //
// /// SSR response from Node.js
// pub type SSRResponse {
//   SSRResponse(head: List(String), body: String)
// }

// /// Result of an SSR rendering attempt
// pub type SSRResult {
//   /// SSR succeeded and returned rendered content
//   SSRSuccess(response: SSRResponse)
//   /// SSR failed but should fallback to CSR gracefully
//   SSRFallback(reason: String)
//   /// SSR failed with an error that should be raised
//   SSRError(error: String)
// }

// /// Messages that the SSR supervisor can handle
// pub type SSRMessage {
//   StartNodeJS(reply_with: Subject(Result(Nil, SSRError)))
//   StopNodeJS(reply_with: Subject(Result(Nil, SSRError)))
//   GetStatus(reply_with: Subject(SSRStatus))
//   UpdateConfig(SSRConfig, reply_with: Subject(Result(Nil, SSRError)))
//   RenderPage(
//     dynamic.Dynamic,
//     String,
//     reply_with: Subject(Result(SSRResponse, SSRError)),
//   )
// }

// /// Current status of the SSR system
// pub type SSRStatus {
//   SSRStatus(enabled: Bool, supervisor_running: Bool, config: SSRConfig)
// }

// /// SSR supervisor errors
// pub type SSRError {
//   SupervisorNotStarted
//   NodeJSStartFailed(String)
//   RenderError(String)
// }

// pub fn ssr_error_to_string(error: SSRError) -> String {
//   case error {
//     SupervisorNotStarted -> "SSR supervisor not started"
//     NodeJSStartFailed(message) -> "Failed to start Node.js: " <> message
//     RenderError(message) -> "SSR render failed: " <> message
//   }
// }

// /// SSR configuration settings
// pub type SSRConfig {
//   SSRConfig(
//     /// Whether SSR is enabled globally
//     enabled: Bool,
//     /// Path to directory containing the ssr.js file
//     path: String,
//     /// Name of the Node.js module (without .js extension)
//     module: String,
//     /// Number of Node.js worker processes in the pool
//     pool_size: Int,
//     /// Timeout for SSR renders in milliseconds
//     timeout_ms: Int,
//     /// Name for the supervisor process
//     supervisor_name: String,
//   )
// }

// // //// @internal
// // ////
// // //// Server-Side Rendering (SSR) coordination for Inertia.js applications.
// // ////
// // //// This module provides the core SSR functionality that enables server-side
// // //// rendering of Inertia.js pages for improved SEO, faster initial page loads,
// // //// and better user experience. It coordinates between the Gleam server and
// // //// a Node.js process pool that handles the actual rendering.
// // ////
// // //// ## How SSR Works
// // ////
// // //// 1. **Process Pool**: Manages a pool of Node.js processes for rendering
// // //// 2. **Message Passing**: Sends page data to Node.js processes via JSON
// // //// 3. **HTML Generation**: Receives rendered HTML from the frontend framework
// // //// 4. **Fallback Handling**: Gracefully falls back to client-side rendering on errors
// // ////
// // //// ## Architecture
// // ////
// // //// ```
// // //// Gleam Server -> SSR Supervisor -> Node.js Process Pool -> Frontend Framework
// // //// ```
// // ////
// // //// The SSR system uses Erlang's actor model to manage:
// // //// - A supervisor that oversees the Node.js processes
// // //// - Individual worker processes for parallel rendering
// // //// - Message queues for handling rendering requests
// // //// - Timeout and error handling for reliability
// // ////
// // //// ## Configuration
// // ////
// // //// SSR requires configuration of:
// // //// - Node.js script path for rendering
// // //// - Process pool size for concurrency
// // //// - Timeout values for request handling
// // //// - Module names for component resolution
// // ////
// // //// ## Error Handling
// // ////
// // //// The SSR system is designed to be resilient:
// // //// - Failed renders fall back to client-side rendering
// // //// - Process crashes are automatically recovered
// // //// - Timeouts prevent hanging requests
// // //// - Detailed error reporting for debugging

// // import gleam/dynamic
// // import gleam/dynamic/decode
// // import gleam/erlang/process.{type Subject}
// // import gleam/json
// // import gleam/result
// // import inertia_wisp/internal/ssr/supervisor
// // import inertia_wisp/internal/types.{type SSRConfig, type SSRMessage}

// // /// Start the SSR supervisor with the given configuration
// // pub fn start_supervisor(
// //   ssr_config: SSRConfig,
// // ) -> Result(Subject(SSRMessage), String) {
// //   use sup <- result.try(
// //     supervisor.start_link(ssr_config)
// //     |> result.map_error(fn(_) { "Failed to start supervisor" }),
// //   )
// //   use _ <- result.try(
// //     supervisor.start_nodejs(sup)
// //     |> result.map_error(fn(_) { "Failed to start Node.js workers" }),
// //   )
// //   Ok(sup)
// // }

// // pub fn render_page(
// //   supervisor: Subject(SSRMessage),
// //   page: types.Page,
// // ) -> types.SSRResult {
// //   let status = supervisor.get_status(supervisor)
// //   case status.enabled {
// //     False -> types.SSRFallback("SSR not enabled")
// //     True -> {
// //       let page_data =
// //         create_page_data(page.component, page.props, page.url, page.version)
// //       case supervisor.render_page(supervisor, page_data, page.component) {
// //         Ok(response) -> types.SSRSuccess(response)
// //         Error(ssr_error) -> {
// //           types.SSRFallback(
// //             "SSR render failed: " <> types.ssr_error_to_string(ssr_error),
// //           )
// //         }
// //       }
// //     }
// //   }
// // }

// // /// Create page data structure expected by Inertia.js SSR
// // fn create_page_data(
// //   component: String,
// //   props: json.Json,
// //   url: String,
// //   version: String,
// // ) -> dynamic.Dynamic {
// //   let assert Ok(props) = json.parse(json.to_string(props), decode.dynamic)
// //   dynamic.properties([
// //     #(dynamic.string("component"), dynamic.string(component)),
// //     #(dynamic.string("props"), props),
// //     #(dynamic.string("url"), dynamic.string(url)),
// //     #(dynamic.string("version"), dynamic.string(version)),
// //   ])
// // }

// // /// Stop SSR supervisorSSRMessage
// // pub fn stop(supervisor: Subject(types.SSRMessage)) -> Result(Nil, String) {
// //   case supervisor.stop_nodejs(supervisor) {
// //     Ok(result) -> Ok(result)
// //     Error(_) -> Error("Failed to stop Node.js workers")
// //   }
// // }
