import { useState, ChangeEvent, FormEvent } from "react";
import { Head, Link, router } from "@inertiajs/react";
import { CreateUserPageProps, CreateUserPagePropsSchema, withValidatedProps } from "../schemas";

interface CreateUserFormData {
  name: string;
  email: string;
}

function CreateUser({ errors, old, csrf_token, auth }: CreateUserPageProps) {
  const [formData, setFormData] = useState<CreateUserFormData>({
    name: old?.name || "",
    email: old?.email || "",
  });
  const [isSubmitting, setIsSubmitting] = useState<boolean>(false);

  const handleSubmit = (e: FormEvent<HTMLFormElement>) => {
    e.preventDefault();
    setIsSubmitting(true);

    router.post("/users", {
      ...formData,
      _token: csrf_token,
    }, {
      onFinish: () => setIsSubmitting(false),
    });
  };

  const handleChange = (e: ChangeEvent<HTMLInputElement>) => {
    const { name, value } = e.target;
    setFormData(prev => ({
      ...prev,
      [name]: value
    }));
  };

  return (
    <>
      <Head title="Create New User" />
      
      <div className="min-h-screen bg-gradient-to-br from-indigo-50 via-white to-cyan-50">
        <div className="mx-auto max-w-2xl px-4 py-16 sm:px-6 sm:py-24 lg:max-w-7xl lg:px-8">
          
          {/* Header */}
          <div className="text-center mb-12">
            <div className="mx-auto h-16 w-16 rounded-full bg-gradient-to-r from-indigo-500 to-purple-600 flex items-center justify-center mb-6">
              <svg className="h-8 w-8 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 6v6m0 0v6m0-6h6m-6 0H6" />
              </svg>
            </div>
            <h1 className="text-4xl font-bold tracking-tight text-gray-900 sm:text-5xl">
              Create New User
            </h1>
            <p className="mt-4 text-lg text-gray-600">
              Add a new user to the system with form validation
            </p>
            
            <Link 
              href="/users" 
              className="mt-6 inline-flex items-center px-4 py-2 border border-transparent text-sm font-medium rounded-md text-indigo-700 bg-indigo-100 hover:bg-indigo-200 transition-colors duration-200"
            >
              <svg className="mr-2 h-4 w-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M10 19l-7-7m0 0l7-7m-7 7h18" />
              </svg>
              Back to Users
            </Link>
          </div>

          <div className="mx-auto max-w-xl">
            
            {/* Main Card */}
            <div className="bg-white shadow-xl ring-1 ring-gray-900/5 rounded-2xl overflow-hidden">
              
              {/* Errors */}
              {(errors?.name || errors?.email) && (
                <div className="bg-red-50 border-l-4 border-red-400 p-4 m-6 rounded-md">
                  <div className="flex">
                    <div className="flex-shrink-0">
                      <svg className="h-5 w-5 text-red-400" viewBox="0 0 20 20" fill="currentColor">
                        <path fillRule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zM8.707 7.293a1 1 0 00-1.414 1.414L8.586 10l-1.293 1.293a1 1 0 101.414 1.414L10 11.414l1.293 1.293a1 1 0 001.414-1.414L11.414 10l1.293-1.293a1 1 0 00-1.414-1.414L10 8.586 8.707 7.293z" clipRule="evenodd" />
                      </svg>
                    </div>
                    <div className="ml-3">
                      <h3 className="text-sm font-medium text-red-800">Validation errors:</h3>
                      <div className="mt-2 text-sm text-red-700">
                        <ul className="list-disc pl-5 space-y-1">
                          {errors?.name && (
                            <li><strong>Name:</strong> {errors.name}</li>
                          )}
                          {errors?.email && (
                            <li><strong>Email:</strong> {errors.email}</li>
                          )}
                        </ul>
                      </div>
                    </div>
                  </div>
                </div>
              )}

              <div className="p-6">
                
                {/* Create Form */}
                <form onSubmit={handleSubmit} className="space-y-6">
                  
                  {/* Name Field */}
                  <div>
                    <label htmlFor="name" className="block text-sm font-medium text-gray-700 mb-2">
                      Full Name
                    </label>
                    <div className="relative">
                      <div className="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
                        <svg className="h-5 w-5 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                          <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z" />
                        </svg>
                      </div>
                      <input
                        type="text"
                        id="name"
                        name="name"
                        value={formData.name}
                        onChange={handleChange}
                        disabled={isSubmitting}
                        className={`
                          block w-full pl-10 pr-3 py-3 border rounded-lg shadow-sm 
                          placeholder-gray-400 focus:outline-none focus:ring-2 focus:ring-indigo-500 focus:border-transparent
                          disabled:bg-gray-50 disabled:text-gray-500 disabled:cursor-not-allowed
                          ${errors?.name 
                            ? 'border-red-300 text-red-900 focus:ring-red-500' 
                            : 'border-gray-300 text-gray-900'
                          }
                        `}
                        placeholder="Enter your full name"
                      />
                    </div>
                  </div>

                  {/* Email Field */}
                  <div>
                    <label htmlFor="email" className="block text-sm font-medium text-gray-700 mb-2">
                      Email Address
                    </label>
                    <div className="relative">
                      <div className="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
                        <svg className="h-5 w-5 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                          <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M3 8l7.89 5.26a2 2 0 002.22 0L21 8M5 19h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v10a2 2 0 002 2z" />
                        </svg>
                      </div>
                      <input
                        type="email"
                        id="email"
                        name="email"
                        value={formData.email}
                        onChange={handleChange}
                        disabled={isSubmitting}
                        className={`
                          block w-full pl-10 pr-3 py-3 border rounded-lg shadow-sm 
                          placeholder-gray-400 focus:outline-none focus:ring-2 focus:ring-indigo-500 focus:border-transparent
                          disabled:bg-gray-50 disabled:text-gray-500 disabled:cursor-not-allowed
                          ${errors?.email 
                            ? 'border-red-300 text-red-900 focus:ring-red-500' 
                            : 'border-gray-300 text-gray-900'
                          }
                        `}
                        placeholder="Enter your email address"
                      />
                    </div>
                  </div>

                  {/* Action Buttons */}
                  <div className="flex flex-col sm:flex-row gap-3">
                    <button
                      type="submit"
                      disabled={isSubmitting}
                      className={`
                        flex-1 inline-flex justify-center items-center px-4 py-3 border border-transparent 
                        text-sm font-medium rounded-lg transition-all duration-200
                        ${isSubmitting 
                          ? 'bg-gray-300 text-gray-500 cursor-not-allowed' 
                          : 'text-white bg-gradient-to-r from-indigo-500 to-purple-600 hover:from-indigo-600 hover:to-purple-700 shadow-lg hover:shadow-xl transform hover:-translate-y-0.5'
                        }
                      `}
                    >
                      {isSubmitting ? (
                        <>
                          <svg className="animate-spin -ml-1 mr-3 h-5 w-5 text-gray-500" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
                            <circle className="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" strokeWidth="4"></circle>
                            <path className="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
                          </svg>
                          Creating...
                        </>
                      ) : (
                        <>
                          <svg className="mr-2 h-5 w-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 6v6m0 0v6m0-6h6m-6 0H6" />
                          </svg>
                          Create User
                        </>
                      )}
                    </button>

                    <Link
                      href="/users"
                      className="flex-1 inline-flex justify-center items-center px-4 py-3 border border-gray-300 text-sm font-medium rounded-lg text-gray-700 bg-white hover:bg-gray-50 transition-colors duration-200"
                    >
                      <svg className="mr-2 h-4 w-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M6 18L18 6M6 6l12 12" />
                      </svg>
                      Cancel
                    </Link>
                  </div>

                </form>

              </div>

              {/* Validation Info */}
              <div className="bg-gradient-to-r from-gray-50 to-gray-100 px-6 py-4 border-t border-gray-200">
                <h4 className="text-sm font-medium text-gray-900 mb-3">Form Validation Demo</h4>
                <div className="space-y-2 text-xs text-gray-600">
                  <div className="flex items-start space-x-2">
                    <div className="h-1.5 w-1.5 bg-gray-400 rounded-full mt-1.5 flex-shrink-0"></div>
                    <span>Name is required and must be at least 2 characters</span>
                  </div>
                  <div className="flex items-start space-x-2">
                    <div className="h-1.5 w-1.5 bg-gray-400 rounded-full mt-1.5 flex-shrink-0"></div>
                    <span>Email is required and must contain @</span>
                  </div>
                  <div className="flex items-start space-x-2">
                    <div className="h-1.5 w-1.5 bg-gray-400 rounded-full mt-1.5 flex-shrink-0"></div>
                    <span>Email must be unique (try using alice@example.com)</span>
                  </div>
                  <div className="flex items-start space-x-2">
                    <div className="h-1.5 w-1.5 bg-gray-400 rounded-full mt-1.5 flex-shrink-0"></div>
                    <span>Validation errors are preserved when form submission fails</span>
                  </div>
                  <div className="flex items-start space-x-2">
                    <div className="h-1.5 w-1.5 bg-gray-400 rounded-full mt-1.5 flex-shrink-0"></div>
                    <span>Form data is preserved on validation errors</span>
                  </div>
                </div>
              </div>

              {/* Auth Info */}
              {auth?.authenticated && (
                <div className="bg-gray-50 px-6 py-4">
                  <div className="flex items-center justify-center">
                    <div className="flex items-center space-x-2">
                      <div className="h-2 w-2 bg-green-400 rounded-full"></div>
                      <p className="text-sm text-gray-600">
                        Logged in as: <span className="font-medium text-gray-900">{auth.user}</span>
                      </p>
                    </div>
                  </div>
                </div>
              )}

            </div>
          </div>
        </div>
      </div>
    </>
  );
}

export default withValidatedProps(CreateUserPagePropsSchema, CreateUser);