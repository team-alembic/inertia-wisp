import type { FormEvent } from "react";
import { useForm } from "@inertiajs/react";
import { ContactFormRequest } from "../../../../shared_types/build/dev/javascript/shared_types/types.mjs";
import type { GleamToJS } from "../../types/gleam-projections";

/**
 * ContactFormComponent - Type-Level Programming Solution Demo
 *
 * This component demonstrates the complete solution for using Gleam types with TypeScript
 * form libraries through advanced type-level programming techniques.
 *
 * THE PROBLEM:
 * - Gleam types compile to classes: new ContactFormRequest(name, email, subject, message, urgent)
 * - JavaScript form libraries expect plain objects: { name, email, subject, message, urgent }
 * - Option<T> and List<T> types don't match JavaScript | null and [] syntax
 *
 * THE SOLUTION:
 * - Use TypeScript type-level programming to automatically project Gleam types
 * - Transform Option<T> → T | null, List<T> → T[], classes → interfaces
 * - Maintain single source of truth while ensuring runtime compatibility
 *
 * BENEFITS:
 * ✅ No manual interface duplication
 * ✅ Automatic type conversion (Option<Bool> → boolean | null)
 * ✅ Full IntelliSense support and compile-time safety
 * ✅ Works seamlessly with Inertia.js useForm hook
 * ✅ Backend automatically receives properly typed Gleam data
 */

interface ContactFormProps {
  title: string;
  message: string;
  errors?: Record<string, string> | undefined;
}

/**
 * Type-level projection of ContactFormRequest to JavaScript-compatible interface
 *
 * Original Gleam type:
 *   ContactFormRequest(name: String, email: String, subject: String, message: String, urgent: Option<Bool>)
 *
 * Projected TypeScript interface:
 *   { name: string, email: string, subject: string, message: string, urgent: boolean | null }
 *
 * This transformation happens entirely at the type level - no runtime overhead!
 */
type ContactFormData = GleamToJS<ContactFormRequest>;

export default function ContactFormComponent({
  title,
  message,
  errors,
}: ContactFormProps) {
  // ✨ Type-safe form hook using projected Gleam type
  // The ContactFormData type is automatically derived from ContactFormRequest
  // with proper JavaScript-compatible types (Option<Bool> → boolean | null)
  const { data, setData, post, processing } = useForm<ContactFormData>({
    name: "",
    email: "",
    subject: "",
    message: "",
    urgent: null, // ✅ JavaScript null automatically becomes Option.None in Gleam
  });

  const handleSubmit = (e: FormEvent) => {
    e.preventDefault();
    // ✨ Automatic type conversion on submit:
    // JavaScript object → JSON → Gleam ContactFormRequest via decoders
    // The boolean | null becomes Option<Bool> seamlessly
    post("/contact");
  };

  return (
    <div className="max-w-2xl mx-auto p-6">
      <div className="bg-white shadow-lg rounded-lg overflow-hidden">
        <div className="bg-gradient-to-r from-teal-500 to-green-600 px-6 py-8">
          <h1 className="text-3xl font-bold text-white">{title}</h1>
          <p className="text-teal-100 mt-2">{message}</p>
        </div>

        <div className="px-6 py-8">
          <form onSubmit={handleSubmit} className="space-y-6">
            <div>
              <label
                htmlFor="name"
                className="block text-sm font-medium text-gray-700 mb-2"
              >
                Name
              </label>
              <input
                type="text"
                id="name"
                value={data.name}
                onChange={(e) => setData("name", e.target.value)}
                className={`w-full px-3 py-2 border rounded-md shadow-sm focus:outline-none focus:ring-2 focus:ring-teal-500 ${
                  errors?.name ? "border-red-500" : "border-gray-300"
                }`}
                placeholder="Enter your full name"
              />
              {errors?.name && (
                <p className="mt-1 text-sm text-red-600">{errors.name}</p>
              )}
            </div>

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
                className={`w-full px-3 py-2 border rounded-md shadow-sm focus:outline-none focus:ring-2 focus:ring-teal-500 ${
                  errors?.email ? "border-red-500" : "border-gray-300"
                }`}
                placeholder="Enter your email address"
              />
              {errors?.email && (
                <p className="mt-1 text-sm text-red-600">{errors.email}</p>
              )}
            </div>

            <div>
              <label
                htmlFor="subject"
                className="block text-sm font-medium text-gray-700 mb-2"
              >
                Subject
              </label>
              <input
                type="text"
                id="subject"
                value={data.subject}
                onChange={(e) => setData("subject", e.target.value)}
                className={`w-full px-3 py-2 border rounded-md shadow-sm focus:outline-none focus:ring-2 focus:ring-teal-500 ${
                  errors?.subject ? "border-red-500" : "border-gray-300"
                }`}
                placeholder="What is this about?"
              />
              {errors?.subject && (
                <p className="mt-1 text-sm text-red-600">{errors.subject}</p>
              )}
            </div>

            <div>
              <label
                htmlFor="message"
                className="block text-sm font-medium text-gray-700 mb-2"
              >
                Message
              </label>
              <textarea
                id="message"
                value={data.message}
                onChange={(e) => setData("message", e.target.value)}
                rows={6}
                className={`w-full px-3 py-2 border rounded-md shadow-sm focus:outline-none focus:ring-2 focus:ring-teal-500 ${
                  errors?.message ? "border-red-500" : "border-gray-300"
                }`}
                placeholder="Tell us how we can help you"
              />
              {errors?.message && (
                <p className="mt-1 text-sm text-red-600">{errors.message}</p>
              )}
            </div>

            <div className="flex items-center">
              <input
                type="checkbox"
                id="urgent"
                checked={data.urgent === true}
                onChange={(e) => setData("urgent", e.target.checked || null)}
                className="h-4 w-4 text-teal-600 focus:ring-teal-500 border-gray-300 rounded"
              />
              <label
                htmlFor="urgent"
                className="ml-2 block text-sm text-gray-700"
              >
                This is urgent
                {/* ✨ Type-safe Option handling: boolean | null → Option<Bool> */}
              </label>
            </div>

            <div className="flex justify-between items-center pt-4">
              <button
                type="button"
                onClick={() => window.history.back()}
                className="px-4 py-2 text-gray-600 bg-gray-200 rounded-md hover:bg-gray-300 focus:outline-none focus:ring-2 focus:ring-gray-500"
              >
                Cancel
              </button>
              <button
                type="submit"
                disabled={processing}
                className="px-6 py-2 bg-teal-600 text-white rounded-md hover:bg-teal-700 focus:outline-none focus:ring-2 focus:ring-teal-500 disabled:opacity-50 disabled:cursor-not-allowed"
              >
                {processing ? "Sending..." : "Send Message"}
              </button>
            </div>
          </form>
        </div>
      </div>
    </div>
  );
}
