//// Todo list handler
////
//// Demonstrates shared types and Inertia's merge functionality.
//// Instead of managing state server-side, we use merge to accumulate todos client-side.

import gleam/dynamic/decode
import gleam/float
import gleam/option.{Some}
import gleam/time/timestamp
import inertia_wisp/inertia
import shared/todo_list.{Todo, TodoProps, ToggleTodoRequest}
import wisp.{type Request, type Response}

/// GET /todo - Display the todo list
pub fn show_todo_list(req: Request) -> Response {
  let props = TodoProps(todos: [])

  req
  |> inertia.response_builder("TodoList")
  |> inertia.props(props, todo_list.encode_todo_props)
  |> inertia.response(200)
}

/// POST /todo/add - Add a new todo
pub fn add_todo(req: Request) -> Response {
  use add_request <- decode_json_body(req, todo_list.decode_add_todo_request())

  let id = get_timestamp_id()
  let new_todo = Todo(id: id, text: add_request.text, completed: False)
  let props = TodoProps(todos: [new_todo])

  req
  |> inertia.response_builder("TodoList")
  |> inertia.props(props, todo_list.encode_todo_props)
  |> inertia.merge("todos", match_on: Some(["id"]), deep: False)
  |> inertia.response(200)
}

/// POST /todo/toggle - Toggle a todo's completed status
pub fn toggle_todo(req: Request) -> Response {
  use ToggleTodoRequest(item) <- decode_json_body(
    req,
    todo_list.decode_toggle_todo_request(),
  )
  // Toggle the completed status
  let updated_todo = Todo(..item, completed: !item.completed)
  let props = TodoProps(todos: [updated_todo])

  req
  |> inertia.response_builder("TodoList")
  |> inertia.props(props, todo_list.encode_todo_props)
  |> inertia.merge("todos", match_on: Some(["id"]), deep: False)
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
