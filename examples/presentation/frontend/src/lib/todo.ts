export {
  // Types
  type Todo$,
  type TodoProps$,
  type AddTodoRequest$,
  type ToggleTodoRequest$,
  // Constructors
  Todo$Todo as createTodo,
  AddTodoRequest$AddTodoRequest as createAddTodoRequest,
  ToggleTodoRequest$ToggleTodoRequest as createToggleTodoRequest,
  // Accessors
  TodoProps$TodoProps$todos as getTodos,
  Todo$Todo$id as getId,
  Todo$Todo$text as getText,
  Todo$Todo$completed as getCompleted,
  // Codec
  decode_todo_props,
  encode_add_todo_request,
  encode_toggle_todo_request,
} from "@shared/todo_list.mjs";
