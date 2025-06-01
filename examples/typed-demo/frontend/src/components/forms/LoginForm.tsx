import type { FormEvent } from "react";
import { useForm } from "@inertiajs/react";
import { LoginRequest } from "@shared_types/shared_types/auth.mjs";
import type { ProjectType } from "../../types/gleam-projections";

interface LoginFormProps {
  title: string;
  message: string;
  demo_info: string[];
  errors?: Record<string, string> | undefined;
}

// TypeScript projection of LoginRequest to JavaScript-compatible interface
// This automatically converts Option<T> to T | null and maintains type safety
type LoginFormData = ProjectType<LoginRequest>;

export default function LoginForm({
  title,
  message,
  demo_info,
  errors,
}: LoginFormProps) {
  const { data, setData, post, processing } = useForm<LoginFormData>({
    email: "",
    password: "",
    remember_me: null,
  });

  const handleSubmit = (e: FormEvent) => {
    e.preventDefault();
    post("/auth/login");
  };

  return (
    <div className="max-w-md mx-auto p-6">
      <div className="bg-white shadow-lg rounded-lg overflow-hidden">
        <div className="bg-gradient-to-r from-indigo-500 to-purple-600 px-6 py-8">
          <h1 className="text-3xl font-bold text-white">{title}</h1>
          <p className="text-indigo-100 mt-2">{message}</p>
        </div>

        <div className="px-6 py-8">
          {demo_info && demo_info.length > 0 && (
            <div className="mb-6 p-4 bg-blue-50 border border-blue-200 rounded-md">
              <h3 className="text-sm font-medium text-blue-800 mb-2">
                Demo Information:
              </h3>
              <ul className="text-sm text-blue-700 space-y-1">
                {demo_info.map((info, index) => (
                  <li key={index}>{info}</li>
                ))}
              </ul>
            </div>
          )}

          <form onSubmit={handleSubmit} className="space-y-6">
            <div>
              <label
                htmlFor="email"
                className="block text-sm font-medium text-gray-700 mb-2"
              >
                Email
              </label>
              <input
                type="email"
                id="email"
                value={data.email}
                onChange={(e) => setData("email", e.target.value)}
                className={`w-full px-3 py-2 border rounded-md shadow-sm focus:outline-none focus:ring-2 focus:ring-indigo-500 ${
                  errors?.email ? "border-red-500" : "border-gray-300"
                }`}
                placeholder="Enter your email"
              />
              {errors?.email && (
                <p className="mt-1 text-sm text-red-600">{errors.email}</p>
              )}
            </div>

            <div>
              <label
                htmlFor="password"
                className="block text-sm font-medium text-gray-700 mb-2"
              >
                Password
              </label>
              <input
                type="password"
                id="password"
                value={data.password}
                onChange={(e) => setData("password", e.target.value)}
                className={`w-full px-3 py-2 border rounded-md shadow-sm focus:outline-none focus:ring-2 focus:ring-indigo-500 ${
                  errors?.password ? "border-red-500" : "border-gray-300"
                }`}
                placeholder="Enter your password"
              />
              {errors?.password && (
                <p className="mt-1 text-sm text-red-600">{errors.password}</p>
              )}
            </div>

            <div className="flex items-center">
              <input
                type="checkbox"
                id="remember_me"
                checked={data.remember_me === true}
                onChange={(e) =>
                  setData("remember_me", e.target.checked || null)
                }
                className="h-4 w-4 text-indigo-600 focus:ring-indigo-500 border-gray-300 rounded"
              />
              <label
                htmlFor="remember_me"
                className="ml-2 block text-sm text-gray-700"
              >
                Remember me
              </label>
            </div>

            <div className="flex justify-between items-center pt-4">
              <button
                type="button"
                onClick={() => window.history.back()}
                className="px-4 py-2 text-gray-600 bg-gray-200 rounded-md hover:bg-gray-300 focus:outline-none focus:ring-2 focus:ring-gray-500"
              >
                Back
              </button>
              <button
                type="submit"
                disabled={processing}
                className="px-6 py-2 bg-indigo-600 text-white rounded-md hover:bg-indigo-700 focus:outline-none focus:ring-2 focus:ring-indigo-500 disabled:opacity-50 disabled:cursor-not-allowed"
              >
                {processing ? "Signing in..." : "Sign In"}
              </button>
            </div>
          </form>
        </div>
      </div>
    </div>
  );
}
