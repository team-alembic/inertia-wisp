// Re-export Gleam types and functions with cleaner names for TypeScript
import {
  type Todo as Todo$,
  type TodoProps as TodoProps$,
  type AddTodoRequest as AddTodoRequest$,
  type ToggleTodoRequest as ToggleTodoRequest$,
  Todo,
  AddTodoRequest$AddTodoRequest,
  ToggleTodoRequest$ToggleTodoRequest,
  decode_todo_props,
  encode_add_todo_request,
  encode_toggle_todo_request,
  TodoProps$TodoProps$todos,
  Todo$Todo$id,
  Todo$Todo$text,
  Todo$Todo$completed,
} from "@gleam/shared/shared/todo_list.mjs";

// Types
export type { Todo$, TodoProps$, AddTodoRequest$, ToggleTodoRequest$ };

// Constructors (cleaner names)
export const createTodo = Todo;
export const createAddTodoRequest = AddTodoRequest$AddTodoRequest;
export const createToggleTodoRequest = ToggleTodoRequest$ToggleTodoRequest;

// Encoders (for sending to server)
export const encodeAddTodoRequest = encode_add_todo_request;
export const encodeToggleTodoRequest = encode_toggle_todo_request;

// TodoProps accessors
export const getTodos = TodoProps$TodoProps$todos;

// Todo accessors
export const getId = Todo$Todo$id;
export const getText = Todo$Todo$text;
export const getCompleted = Todo$Todo$completed;

// Decoders
export const decodeTodoProps = decode_todo_props;
