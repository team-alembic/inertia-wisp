import React from "react";
import { Head, Link } from "@inertiajs/react";
import { 
  AboutPageProps, 
  AboutPagePropsSchema, 
  withValidatedProps, 
  validateProps,
  ValidationErrorFallbackProps 
} from "../schemas";

// Example 1: Basic usage with validateProps (simplified API)
function BasicAbout({ page_title, auth, csrf_token }: AboutPageProps) {
  return (
    <div className="p-4 bg-white rounded-lg border border-gray-200">
      <h2 className="text-lg font-semibold text-gray-900 mb-2">{page_title}</h2>
      <p className="text-sm text-gray-600 mb-3">This component uses the basic validateProps HOC.</p>
      {auth?.authenticated && (
        <div className="flex items-center space-x-2">
          <div className="h-2 w-2 bg-green-400 rounded-full"></div>
          <p className="text-sm text-green-700">Welcome, {auth.user}!</p>
        </div>
      )}
    </div>
  );
}

const BasicAboutValidated = validateProps(AboutPagePropsSchema, BasicAbout);

// Example 2: Advanced usage with custom error boundary
function CustomErrorFallback({ error, reset }: ValidationErrorFallbackProps) {
  return (
    <div className="p-6 bg-red-50 border-l-4 border-red-400 rounded-lg">
      <div className="flex">
        <div className="flex-shrink-0">
          <svg className="h-5 w-5 text-red-400" viewBox="0 0 20 20" fill="currentColor">
            <path fillRule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zM8.707 7.293a1 1 0 00-1.414 1.414L8.586 10l-1.293 1.293a1 1 0 101.414 1.414L10 11.414l1.293 1.293a1 1 0 001.414-1.414L11.414 10l1.293-1.293a1 1 0 00-1.414-1.414L10 8.586 8.707 7.293z" clipRule="evenodd" />
          </svg>
        </div>
        <div className="ml-3">
          <h3 className="text-sm font-medium text-red-800">🚨 Oops! Something went wrong</h3>
          <div className="mt-2 text-sm text-red-700">
            <p className="mb-3">The page data doesn't match what we expected:</p>
            <pre className="bg-red-100 p-3 rounded text-xs overflow-auto border border-red-200">
              {error.message}
            </pre>
            <button 
              onClick={reset}
              className="mt-3 inline-flex items-center px-3 py-1.5 border border-transparent text-xs font-medium rounded text-white bg-red-600 hover:bg-red-700 transition-colors duration-200"
            >
              Try Again
            </button>
          </div>
        </div>
      </div>
    </div>
  );
}

function AdvancedAbout({ page_title, auth, csrf_token }: AboutPageProps) {
  return (
    <div className="p-4 bg-white rounded-lg border border-gray-200">
      <h2 className="text-lg font-semibold text-gray-900 mb-2">{page_title} (Advanced)</h2>
      <p className="text-sm text-gray-600 mb-3">This component uses the advanced withValidatedProps HOC with custom error handling.</p>
      {auth?.authenticated && (
        <div className="flex items-center space-x-2">
          <div className="h-2 w-2 bg-green-400 rounded-full"></div>
          <p className="text-sm text-green-700">Welcome, {auth.user}!</p>
        </div>
      )}
    </div>
  );
}

const AdvancedAboutValidated = withValidatedProps(
  AboutPagePropsSchema, 
  AdvancedAbout,
  {
    ErrorFallback: CustomErrorFallback,
    logErrors: true,
    onError: (error, props) => {
      // Could send to error reporting service
      console.warn("Validation error reported:", error.message);
    }
  }
);

// Example 3: No validation (for comparison)
function UnvalidatedAbout(props: any) {
  return (
    <div className="p-4 bg-white rounded-lg border border-gray-200">
      <h2 className="text-lg font-semibold text-gray-900 mb-2">{props.page_title || "Unknown Title"}</h2>
      <p className="text-sm text-gray-600 mb-3">This component accepts any props without validation.</p>
      <div className="flex items-center space-x-2">
        <svg className="h-4 w-4 text-yellow-500" fill="currentColor" viewBox="0 0 20 20">
          <path fillRule="evenodd" d="M8.257 3.099c.765-1.36 2.722-1.36 3.486 0l5.58 9.92c.75 1.334-.213 2.98-1.742 2.98H4.42c-1.53 0-2.493-1.646-1.743-2.98l5.58-9.92zM11 13a1 1 0 11-2 0 1 1 0 012 0zm-1-8a1 1 0 00-1 1v3a1 1 0 002 0V6a1 1 0 00-1-1z" clipRule="evenodd" />
        </svg>
        <p className="text-sm text-yellow-700 font-medium">
          No type safety or runtime validation!
        </p>
      </div>
    </div>
  );
}

// Main demo component
export default function ValidationExamples() {
  const demoProps = {
    page_title: "Validation Demo",
    csrf_token: "demo-token-123",
    auth: { authenticated: true, user: "demo@example.com" }
  };

  const [showInvalidProps, setShowInvalidProps] = React.useState(false);

  const invalidProps = {
    page_title: 123, // Should be string
    csrf_token: null, // Should be string
    auth: "invalid" // Should be object or undefined
  };

  const currentProps = showInvalidProps ? invalidProps : demoProps;

  return (
    <>
      <Head title="Page Props Validation Examples" />
      
      <div className="min-h-screen bg-gradient-to-br from-indigo-50 via-white to-cyan-50">
        <div className="mx-auto max-w-2xl px-4 py-16 sm:px-6 sm:py-24 lg:max-w-7xl lg:px-8">
          
          {/* Header */}
          <div className="text-center mb-12">
            <div className="mx-auto h-16 w-16 rounded-full bg-gradient-to-r from-indigo-500 to-purple-600 flex items-center justify-center mb-6">
              <svg className="h-8 w-8 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z" />
              </svg>
            </div>
            <h1 className="text-4xl font-bold tracking-tight text-gray-900 sm:text-5xl">
              Page Props Validation Examples
            </h1>
            <p className="mt-4 text-lg text-gray-600">
              Demonstrating different validation patterns for type-safe components
            </p>
            
            <Link 
              href="/" 
              className="mt-6 inline-flex items-center px-4 py-2 border border-transparent text-sm font-medium rounded-md text-indigo-700 bg-indigo-100 hover:bg-indigo-200 transition-colors duration-200"
            >
              <svg className="mr-2 h-4 w-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M10 19l-7-7m0 0l7-7m-7 7h18" />
              </svg>
              Back to Home
            </Link>
          </div>

          <div className="mx-auto max-w-4xl">
            
            {/* Main Card */}
            <div className="bg-white shadow-xl ring-1 ring-gray-900/5 rounded-2xl overflow-hidden">
              
              <div className="p-6">
                
                {/* Demo Controls */}
                <div className="mb-8">
                  <div className="bg-gradient-to-r from-gray-50 to-gray-100 rounded-lg p-6">
                    <h2 className="text-xl font-bold text-gray-900 mb-4">Demo Controls</h2>
                    
                    <label className="flex items-center space-x-3 mb-4">
                      <input
                        type="checkbox"
                        checked={showInvalidProps}
                        onChange={(e) => setShowInvalidProps(e.target.checked)}
                        className="h-4 w-4 text-indigo-600 focus:ring-indigo-500 border-gray-300 rounded"
                      />
                      <span className="text-sm font-medium text-gray-700">
                        Send invalid props to demonstrate error handling
                      </span>
                    </label>
                    
                    <div>
                      <h3 className="text-sm font-medium text-gray-900 mb-2">Current Props:</h3>
                      <pre className="bg-gray-200 p-3 rounded text-xs overflow-auto border border-gray-300 font-mono">
{JSON.stringify(currentProps, null, 2)}
                      </pre>
                    </div>
                  </div>
                </div>

                {/* Examples */}
                <div className="space-y-8">
                  
                  <section>
                    <div className="mb-4">
                      <h2 className="text-xl font-bold text-gray-900">1. Basic Validation (validateProps)</h2>
                      <p className="text-sm text-gray-600 mt-1">Simple HOC that validates props and throws on error:</p>
                    </div>
                    <div className="border border-gray-200 rounded-lg p-4 bg-gray-50">
                      <BasicAboutValidated {...(currentProps as any)} />
                    </div>
                  </section>

                  <section>
                    <div className="mb-4">
                      <h2 className="text-xl font-bold text-gray-900">2. Advanced Validation (withValidatedProps)</h2>
                      <p className="text-sm text-gray-600 mt-1">Full-featured HOC with custom error boundary and logging:</p>
                    </div>
                    <div className="border border-gray-200 rounded-lg p-4 bg-gray-50">
                      <AdvancedAboutValidated {...(currentProps as any)} />
                    </div>
                  </section>

                  <section>
                    <div className="mb-4">
                      <h2 className="text-xl font-bold text-gray-900">3. No Validation (for comparison)</h2>
                      <p className="text-sm text-gray-600 mt-1">Component without any validation (not recommended):</p>
                    </div>
                    <div className="border border-gray-200 rounded-lg p-4 bg-gray-50">
                      <UnvalidatedAbout {...(currentProps as any)} />
                    </div>
                  </section>
                  
                </div>

                {/* Benefits */}
                <div className="mt-8">
                  <div className="bg-gradient-to-r from-blue-50 to-indigo-50 rounded-lg p-6 border border-blue-200">
                    <h2 className="text-xl font-bold text-gray-900 mb-4">Benefits of HOC Pattern</h2>
                    <div className="space-y-3">
                      <div className="flex items-start space-x-3">
                        <div className="flex-shrink-0">
                          <div className="h-6 w-6 rounded-full bg-blue-100 flex items-center justify-center">
                            <svg className="h-4 w-4 text-blue-600" fill="currentColor" viewBox="0 0 20 20">
                              <path fillRule="evenodd" d="M16.707 5.293a1 1 0 010 1.414l-8 8a1 1 0 01-1.414 0l-4-4a1 1 0 011.414-1.414L8 12.586l7.293-7.293a1 1 0 011.414 0z" clipRule="evenodd" />
                            </svg>
                          </div>
                        </div>
                        <div>
                          <p className="text-sm font-medium text-gray-900">Clean Component Signatures</p>
                          <p className="text-sm text-gray-600">Components accept properly typed props</p>
                        </div>
                      </div>
                      
                      <div className="flex items-start space-x-3">
                        <div className="flex-shrink-0">
                          <div className="h-6 w-6 rounded-full bg-blue-100 flex items-center justify-center">
                            <svg className="h-4 w-4 text-blue-600" fill="currentColor" viewBox="0 0 20 20">
                              <path fillRule="evenodd" d="M16.707 5.293a1 1 0 010 1.414l-8 8a1 1 0 01-1.414 0l-4-4a1 1 0 011.414-1.414L8 12.586l7.293-7.293a1 1 0 011.414 0z" clipRule="evenodd" />
                            </svg>
                          </div>
                        </div>
                        <div>
                          <p className="text-sm font-medium text-gray-900">Automatic Validation</p>
                          <p className="text-sm text-gray-600">Props validated at component boundary</p>
                        </div>
                      </div>
                      
                      <div className="flex items-start space-x-3">
                        <div className="flex-shrink-0">
                          <div className="h-6 w-6 rounded-full bg-blue-100 flex items-center justify-center">
                            <svg className="h-4 w-4 text-blue-600" fill="currentColor" viewBox="0 0 20 20">
                              <path fillRule="evenodd" d="M16.707 5.293a1 1 0 010 1.414l-8 8a1 1 0 01-1.414 0l-4-4a1 1 0 011.414-1.414L8 12.586l7.293-7.293a1 1 0 011.414 0z" clipRule="evenodd" />
                            </svg>
                          </div>
                        </div>
                        <div>
                          <p className="text-sm font-medium text-gray-900">Better Developer Experience</p>
                          <p className="text-sm text-gray-600">Type errors at definition, not usage</p>
                        </div>
                      </div>
                      
                      <div className="flex items-start space-x-3">
                        <div className="flex-shrink-0">
                          <div className="h-6 w-6 rounded-full bg-blue-100 flex items-center justify-center">
                            <svg className="h-4 w-4 text-blue-600" fill="currentColor" viewBox="0 0 20 20">
                              <path fillRule="evenodd" d="M16.707 5.293a1 1 0 010 1.414l-8 8a1 1 0 01-1.414 0l-4-4a1 1 0 011.414-1.414L8 12.586l7.293-7.293a1 1 0 011.414 0z" clipRule="evenodd" />
                            </svg>
                          </div>
                        </div>
                        <div>
                          <p className="text-sm font-medium text-gray-900">Reusable & Customizable</p>
                          <p className="text-sm text-gray-600">Same HOC pattern for all page components with custom error UI and logging</p>
                        </div>
                      </div>
                    </div>
                  </div>
                </div>

              </div>
            </div>
          </div>
        </div>
      </div>
    </>
  );
}