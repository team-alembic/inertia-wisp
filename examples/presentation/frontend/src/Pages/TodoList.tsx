import { useState } from "react";
import { router } from "@inertiajs/react";
import * as Todo from "../lib/todo";
import { decodeProps } from "../lib/decodeProps";
import { BackToPresentation } from "../components";
import React from "react";

function TodoList(props: Todo.TodoProps$) {
  const todosList = Todo.getTodos(props);
  const todos = Array.from(todosList);
  const [newTodoText, setNewTodoText] = useState("");

  const handleAddTodo = (e: React.FormEvent) => {
    e.preventDefault();
    const text = newTodoText.trim();
    if (text) {
      const request = Todo.createAddTodoRequest(text);

      router.post("/todo/add", Todo.encode_add_todo_request(request), {
        preserveScroll: true,
        preserveUrl: true,
        only: ["todos"],
        onSuccess: () => setNewTodoText(""),
      });
    }
  };

  const handleToggleTodo = (item: Todo.Todo$) => {
    const request = Todo.createToggleTodoRequest(item);
    router.post("/todo/toggle", Todo.encode_toggle_todo_request(request), {
      only: ["todos"],
      preserveUrl: true,
      preserveScroll: true,
    });
  };

  return (
    <div className="min-h-screen bg-gradient-to-br from-purple-100 via-blue-50 to-indigo-100 p-8">
      <div className="max-w-2xl mx-auto">
        <Header />

        {/* Add Todo Form */}
        <AddTodoForm
          handleAddTodo={handleAddTodo}
          newTodoText={newTodoText}
          setNewTodoText={setNewTodoText}
        />

        {/* Todo List */}
        <div className="bg-white/80 backdrop-blur-md rounded-lg p-6 mb-6 shadow-lg">
          {todos.length === 0 ? (
            <EmptyState />
          ) : (
            <div className="space-y-3">
              {todos.map((item) => (
                <TodoItem
                  key={Todo.getId(item)}
                  item={item}
                  handleToggleTodo={handleToggleTodo}
                />
              ))}
            </div>
          )}
        </div>

        <div className="mt-8">
          <BackToPresentation slideNumber={1} />
        </div>
      </div>
    </div>
  );
}

const Header = () => (
  <div className="bg-white/80 backdrop-blur-md rounded-lg p-6 mb-6 shadow-lg">
    <h1 className="text-3xl font-bold text-gray-900 mb-2">📝 Todo List Demo</h1>
    <p className="text-gray-700">
      Demonstrating shared types between Gleam and TypeScript
    </p>
  </div>
);

const EmptyState = () => (
  <p className="text-gray-500 text-center py-8">No todos yet. Add one above!</p>
);

interface AddTodoFormProps {
  handleAddTodo: React.FormEventHandler<HTMLFormElement>;
  newTodoText: string;
  setNewTodoText: (s: string) => void;
}
const AddTodoForm = ({
  handleAddTodo,
  newTodoText,
  setNewTodoText,
}: AddTodoFormProps) => (
  <form
    onSubmit={handleAddTodo}
    className="bg-white/80 backdrop-blur-md rounded-lg p-6 mb-6 shadow-lg"
  >
    <div className="flex gap-4">
      <input
        type="text"
        value={newTodoText}
        onChange={(e) => setNewTodoText(e.target.value)}
        placeholder="What needs to be done?"
        className="flex-1 px-4 py-3 rounded-lg bg-white border border-gray-300 text-gray-900 placeholder-gray-500 focus:outline-none focus:ring-2 focus:ring-purple-500 focus:border-transparent"
      />
      <button
        type="submit"
        disabled={!newTodoText.trim()}
        className="px-6 py-3 bg-purple-600 text-white rounded-lg font-semibold hover:bg-purple-700 transition disabled:opacity-50 disabled:cursor-not-allowed"
      >
        Add
      </button>
    </div>
  </form>
);

interface TodoItemProps {
  item: Todo.Todo$;
  handleToggleTodo: (item: Todo.Todo$) => void;
}
const TodoItem = ({ item, handleToggleTodo }: TodoItemProps) => (
  <div
    key={Todo.getId(item)}
    className="flex items-center gap-4 p-4 bg-white border border-gray-200 rounded-lg hover:border-purple-300 hover:shadow-md transition"
  >
    <input
      type="checkbox"
      checked={Todo.getCompleted(item)}
      onChange={() => handleToggleTodo(item)}
      className="w-5 h-5 rounded border-2 border-gray-400 text-purple-600 focus:ring-2 focus:ring-purple-500 cursor-pointer"
    />
    <span
      className={`flex-1 text-gray-900 ${
        Todo.getCompleted(item) ? "line-through opacity-50" : ""
      }`}
    >
      {Todo.getText(item)}
    </span>
  </div>
);

export default decodeProps(TodoList, Todo.decode_todo_props());
