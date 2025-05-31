import { Link } from "@inertiajs/react";
import {
  decode_home_page_props,
  HomePageProps,
} from "../../shared/build/dev/javascript/shared_types/types.mjs";
import { withDecodedProps } from "./utils/decoders";

function Home(props: HomePageProps) {
  console.log({ props });
  return (
    <div className="min-h-screen bg-gradient-to-br from-blue-50 to-indigo-100">
      <div className="max-w-4xl mx-auto p-6">
        <div className="text-center py-12">
          <h1 className="text-5xl font-bold text-gray-900 mb-4">
            {props.title}
          </h1>
          <p className="text-xl text-gray-600 mb-12">{props.message}</p>
        </div>

        <div className="grid grid-cols-1 md:grid-cols-2 gap-8 mb-12">
          <div className="bg-white rounded-xl shadow-lg p-8 hover:shadow-xl transition-shadow">
            <div className="flex items-center mb-4">
              <div className="w-12 h-12 bg-blue-500 rounded-lg flex items-center justify-center">
                <svg
                  className="w-6 h-6 text-white"
                  fill="currentColor"
                  viewBox="0 0 20 20"
                >
                  <path d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z" />
                </svg>
              </div>
              <h3 className="text-xl font-semibold text-gray-900 ml-4">
                Type Safety
              </h3>
            </div>
            <p className="text-gray-600">
              Enjoy compile-time type safety across your entire stack with
              shared Gleam and TypeScript definitions.
            </p>
          </div>

          <div className="bg-white rounded-xl shadow-lg p-8 hover:shadow-xl transition-shadow">
            <div className="flex items-center mb-4">
              <div className="w-12 h-12 bg-green-500 rounded-lg flex items-center justify-center">
                <svg
                  className="w-6 h-6 text-white"
                  fill="currentColor"
                  viewBox="0 0 20 20"
                >
                  <path d="M13 6a3 3 0 11-6 0 3 3 0 016 0zM18 8a2 2 0 11-4 0 2 2 0 014 0zM14 15a4 4 0 00-8 0v3h8v-3z" />
                </svg>
              </div>
              <h3 className="text-xl font-semibold text-gray-900 ml-4">
                Shared Types
              </h3>
            </div>
            <p className="text-gray-600">
              Define your data structures once in Gleam and automatically
              generate TypeScript types for your frontend.
            </p>
          </div>

          <div className="bg-white rounded-xl shadow-lg p-8 hover:shadow-xl transition-shadow">
            <div className="flex items-center mb-4">
              <div className="w-12 h-12 bg-purple-500 rounded-lg flex items-center justify-center">
                <svg
                  className="w-6 h-6 text-white"
                  fill="currentColor"
                  viewBox="0 0 20 20"
                >
                  <path d="M4 4a2 2 0 00-2 2v8a2 2 0 002 2h12a2 2 0 002-2V6a2 2 0 00-2-2H4zm12 4l-6 4-6-4h12z" />
                </svg>
              </div>
              <h3 className="text-xl font-semibold text-gray-900 ml-4">
                Transformations
              </h3>
            </div>
            <p className="text-gray-600">
              Build your props incrementally using transformation functions
              while maintaining full type safety.
            </p>
          </div>

          <div className="bg-white rounded-xl shadow-lg p-8 hover:shadow-xl transition-shadow">
            <div className="flex items-center mb-4">
              <div className="w-12 h-12 bg-orange-500 rounded-lg flex items-center justify-center">
                <svg
                  className="w-6 h-6 text-white"
                  fill="currentColor"
                  viewBox="0 0 20 20"
                >
                  <path
                    fillRule="evenodd"
                    d="M4 2a1 1 0 011 1v2.101a7.002 7.002 0 0111.601 2.566 1 1 0 11-1.885.666A5.002 5.002 0 005.999 7H9a1 1 0 010 2H4a1 1 0 01-1-1V3a1 1 0 011-1zm.008 9.057a1 1 0 011.276.61A5.002 5.002 0 0014.001 13H11a1 1 0 110-2h5a1 1 0 011 1v5a1 1 0 11-2 0v-2.101a7.002 7.002 0 01-11.601-2.566 1 1 0 01.61-1.276z"
                    clipRule="evenodd"
                  />
                </svg>
              </div>
              <h3 className="text-xl font-semibold text-gray-900 ml-4">
                Partial Reloads
              </h3>
            </div>
            <p className="text-gray-600">
              Keep all the benefits of Inertia.js partial reloads while enjoying
              static type checking.
            </p>
          </div>
        </div>

        <div className="bg-white rounded-xl shadow-lg p-8">
          <h2 className="text-2xl font-bold text-gray-900 mb-6">Features</h2>
          <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
            {props.features.toArray().map((feature: string, index: number) => (
              <div key={index} className="flex items-center space-x-3">
                <div className="w-2 h-2 bg-blue-500 rounded-full"></div>
                <span className="text-gray-700">{feature}</span>
              </div>
            ))}
          </div>
        </div>

        <div className="text-center mt-12">
          <div className="flex justify-center space-x-4">
            <Link
              href="/user/1"
              className="bg-blue-600 text-white px-6 py-3 rounded-lg font-medium hover:bg-blue-700 transition-colors"
            >
              View User Profile
            </Link>
            <Link
              href="/blog/1"
              className="bg-green-600 text-white px-6 py-3 rounded-lg font-medium hover:bg-green-700 transition-colors"
            >
              Read Blog Post
            </Link>
            <Link
              href="/dashboard"
              className="bg-purple-600 text-white px-6 py-3 rounded-lg font-medium hover:bg-purple-700 transition-colors"
            >
              View Dashboard
            </Link>
          </div>
        </div>
      </div>
    </div>
  );
}

export default withDecodedProps(decode_home_page_props, Home);
