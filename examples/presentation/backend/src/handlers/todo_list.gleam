//// Todo list handler
////
//// Demonstrates shared types and Inertia's merge functionality.
//// Instead of managing state server-side, we use merge to accumulate todos client-side.

import gleam/dynamic/decode
import gleam/float
import gleam/option
import gleam/time/timestamp
import inertia_wisp/inertia
import shared/todo_list
import wisp.{type Request, type Response}

/// GET /todo - Display the todo list
pub fn show_todo_list(req: Request) -> Response {
  let props = todo_list.TodoProps(todos: [])

  req
  |> inertia.response_builder("TodoList")
  |> inertia.props(props, todo_list.encode_todo_props)
  |> inertia.merge("todos", option.Some(["id"]), False)
  |> inertia.response(200)
}

/// POST /todo/add - Add a new todo
/// Uses merge to append the new todo to the client-side list
pub fn add_todo(req: Request) -> Response {
  use add_request <- decode_json_body(req, todo_list.decode_add_todo_request())

  // Create a new todo with a timestamp-based ID
  let id = get_timestamp_id()
  let new_todo =
    todo_list.Todo(id: id, text: add_request.text, completed: False)

  // Return just the new todo - merge will append it to the client-side list
  let props = todo_list.TodoProps(todos: [new_todo])

  req
  |> inertia.response_builder("TodoList")
  |> inertia.props(props, todo_list.encode_todo_props)
  |> inertia.merge("todos", option.Some(["id"]), False)
  |> inertia.response(200)
}

/// POST /todo/toggle - Toggle a todo's completed status
/// Client sends the entire todo, we toggle completed and return it
/// Uses merge to update the specific todo in the client-side list
pub fn toggle_todo(req: Request) -> Response {
  use toggle_request <- decode_json_body(
    req,
    todo_list.decode_toggle_todo_request(),
  )
  // Toggle the completed status
  let updated_todo =
    todo_list.Todo(
      ..toggle_request.item,
      completed: !toggle_request.item.completed,
    )

  let props = todo_list.TodoProps(todos: [updated_todo])

  req
  |> inertia.response_builder("TodoList")
  |> inertia.props(props, todo_list.encode_todo_props)
  |> inertia.merge("todos", option.Some(["id"]), False)
  |> inertia.response(200)
}

// ============================================================================
// Helpers
// ============================================================================

fn decode_json_body(
  req: Request,
  decoder: decode.Decoder(a),
  next: fn(a) -> Response,
) -> Response {
  use body <- wisp.require_json(req)
  let result = decode.run(body, decoder)
  case result {
    Ok(decoded) -> next(decoded)
    _ -> wisp.unprocessable_content()
  }
}

/// Generate a unique ID based on current timestamp
fn get_timestamp_id() -> Int {
  timestamp.system_time() |> timestamp.to_unix_seconds() |> float.round()
}
