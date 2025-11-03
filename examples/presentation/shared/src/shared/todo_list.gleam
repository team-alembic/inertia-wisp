import gleam/dict
import gleam/dynamic/decode
import gleam/json.{type Json}

// ============================================================================
// Types
// ============================================================================

pub type Todo {
  Todo(id: Int, text: String, completed: Bool)
}

pub type TodoProps {
  TodoProps(todos: List(Todo))
}

pub type AddTodoRequest {
  AddTodoRequest(text: String)
}

pub type ToggleTodoRequest {
  ToggleTodoRequest(item: Todo)
}

// ============================================================================
// Encoders (Gleam → JSON)
// ============================================================================

pub fn encode_todo(item: Todo) -> Json {
  json.object([
    #("id", json.int(item.id)),
    #("text", json.string(item.text)),
    #("completed", json.bool(item.completed)),
  ])
}

/// Encode todo props to JSON dict
pub fn encode_todo_props(props: TodoProps) -> dict.Dict(String, json.Json) {
  dict.from_list([
    #("todos", json.array(props.todos, encode_todo)),
  ])
}

pub fn encode_add_todo_request(request: AddTodoRequest) -> Json {
  json.object([#("text", json.string(request.text))])
}

pub fn encode_toggle_todo_request(request: ToggleTodoRequest) -> Json {
  json.object([#("item", encode_todo(request.item))])
}

// ============================================================================
// Decoders (JSON → Gleam)
// ============================================================================

pub fn decode_todo() -> decode.Decoder(Todo) {
  use id <- decode.field("id", decode.int)
  use text <- decode.field("text", decode.string)
  use completed <- decode.field("completed", decode.bool)
  decode.success(Todo(id:, text:, completed:))
}

pub fn decode_todo_props() -> decode.Decoder(TodoProps) {
  use todos <- decode.field("todos", decode.list(decode_todo()))
  decode.success(TodoProps(todos:))
}

pub fn decode_add_todo_request() -> decode.Decoder(AddTodoRequest) {
  use text <- decode.field("text", decode.string)
  decode.success(AddTodoRequest(text:))
}

pub fn decode_toggle_todo_request() -> decode.Decoder(ToggleTodoRequest) {
  use item <- decode.field("item", decode_todo())
  decode.success(ToggleTodoRequest(item:))
}
