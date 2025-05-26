import { useState, ChangeEvent, FormEvent } from "react";
import { Head, Link, router } from "@inertiajs/react";
import { CreateUserPageProps, CreateUserPagePropsSchema, CreateUserFormSchema, validateFormData, withValidatedProps } from "../schemas";

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
  const [clientErrors, setClientErrors] = useState<Record<string, string>>({});

  const handleSubmit = (e: FormEvent<HTMLFormElement>) => {
    e.preventDefault();
    
    // Client-side validation with Zod
    const validation = validateFormData(CreateUserFormSchema, formData);
    
    if (!validation.success) {
      setClientErrors(validation.errors);
      return;
    }
    
    // Clear client errors if validation passes
    setClientErrors({});
    setIsSubmitting(true);

    router.post("/users", {
      ...validation.data,
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
    
    // Clear error for this field when user starts typing
    if (clientErrors[name]) {
      setClientErrors(prev => ({ ...prev, [name]: "" }));
    }
  };

  // Merge server errors and client errors, preferring server errors
  const allErrors = { ...clientErrors, ...errors };

  return (
    <>
      <Head title="Create New User (Improved)" />
      
      <div className="min-h-screen bg-gradient-to-br from-indigo-50 via-white to-cyan-50">
        <div className="mx-auto max-w-2xl px-4 py-16 sm:px-6 sm:py-24 lg:max-w-7xl lg:px-8">
          
          {/* Header */}
          <div className="text-center mb-12">
            <div className="mx-auto h-16 w-16 rounded-full bg-gradient-to-r from-blue-500 to-cyan-600 flex items-center justify-center mb-6">
              <svg className="h-8 w-8 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M13 10V3L4 14h7v7l9-11h-7z" />
              </svg>
            </div>
            <h1 className="text-4xl font-bold tracking-tight text-gray-900 sm:text-5xl">
              Create New User
            </h1>
            <p className="mt-4 text-lg text-gray-600">
              Improved validation with advanced error handling
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
              
              {/* Improved Features Notice */}
              <div className="bg-gradient-to-r from-blue-50 to-cyan-50 border-l-4 border-blue-400 p-4 m-6 rounded-md">
                <div className="flex">
                  <div className="flex-shrink-0">
                    <svg className="h-5 w-5 text-blue-400" viewBox="0 0 20 20" fill="currentColor">
                      <path fillRule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z" clipRule="evenodd" />
                    </svg>
                  </div>
                  <div className="ml-3">
                    <h3 className="text-sm font-medium text-blue-800">Improved Version</h3>
                    <div className="mt-2 text-sm text-blue-700">
                      <p>Enhanced form with prop validation, client-side validation, and improved error handling patterns.</p>
                    </div>
                  </div>
                </div>
              </div>

              {/* Errors */}
              {(allErrors?.name || allErrors?.email) && (
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
                          {allErrors?.name && (
                            <li><strong>Name:</strong> {allErrors.name}</li>
                          )}
                          {allErrors?.email && (
                            <li><strong>Email:</strong> {allErrors.email}</li>
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
                          placeholder-gray-400 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent
                          disabled:bg-gray-50 disabled:text-gray-500 disabled:cursor-not-allowed
                          ${allErrors?.name 
                            ? 'border-red-300 text-red-900 focus:ring-red-500' 
                            : 'border-gray-300 text-gray-900'
                          }
                        `}
                        placeholder="Enter your full name"
                      />
                      {!allErrors?.name && formData.name.length > 0 && (
                        <div className="absolute inset-y-0 right-0 pr-3 flex items-center">
                          <svg className="h-5 w-5 text-blue-500" fill="currentColor" viewBox="0 0 20 20">
                            <path fillRule="evenodd" d="M16.707 5.293a1 1 0 010 1.414l-8 8a1 1 0 01-1.414 0l-4-4a1 1 0 011.414-1.414L8 12.586l7.293-7.293a1 1 0 011.414 0z" clipRule="evenodd" />
                          </svg>
                        </div>
                      )}
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
                          placeholder-gray-400 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent
                          disabled:bg-gray-50 disabled:text-gray-500 disabled:cursor-not-allowed
                          ${allErrors?.email 
                            ? 'border-red-300 text-red-900 focus:ring-red-500' 
                            : 'border-gray-300 text-gray-900'
                          }
                        `}
                        placeholder="Enter your email address"
                      />
                      {!allErrors?.email && formData.email.includes('@') && (
                        <div className="absolute inset-y-0 right-0 pr-3 flex items-center">
                          <svg className="h-5 w-5 text-blue-500" fill="currentColor" viewBox="0 0 20 20">
                            <path fillRule="evenodd" d="M16.707 5.293a1 1 0 010 1.414l-8 8a1 1 0 01-1.414 0l-4-4a1 1 0 011.414-1.414L8 12.586l7.293-7.293a1 1 0 011.414 0z" clipRule="evenodd" />
                          </svg>
                        </div>
                      )}
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
                          : 'text-white bg-gradient-to-r from-blue-500 to-cyan-600 hover:from-blue-600 hover:to-cyan-700 shadow-lg hover:shadow-xl transform hover:-translate-y-0.5'
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

              {/* Improved Features Info */}
              <div className="bg-gradient-to-r from-gray-50 to-gray-100 px-6 py-4 border-t border-gray-200">
                <h4 className="text-sm font-medium text-gray-900 mb-3">Improved Form Features</h4>
                <div className="space-y-2 text-xs text-gray-600">
                  <div className="flex items-start space-x-2">
                    <div className="h-1.5 w-1.5 bg-blue-400 rounded-full mt-1.5 flex-shrink-0"></div>
                    <span>Runtime schema validation with detailed error handling</span>
                  </div>
                  <div className="flex items-start space-x-2">
                    <div className="h-1.5 w-1.5 bg-blue-400 rounded-full mt-1.5 flex-shrink-0"></div>
                    <span>Client-side validation before submission</span>
                  </div>
                  <div className="flex items-start space-x-2">
                    <div className="h-1.5 w-1.5 bg-blue-400 rounded-full mt-1.5 flex-shrink-0"></div>
                    <span>Type safety with compile-time and runtime checking</span>
                  </div>
                  <div className="flex items-start space-x-2">
                    <div className="h-1.5 w-1.5 bg-blue-400 rounded-full mt-1.5 flex-shrink-0"></div>
                    <span>Error merging - client errors shown immediately, server errors on submission</span>
                  </div>
                  <div className="flex items-start space-x-2">
                    <div className="h-1.5 w-1.5 bg-blue-400 rounded-full mt-1.5 flex-shrink-0"></div>
                    <span>Schema consistency with backend validation rules</span>
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