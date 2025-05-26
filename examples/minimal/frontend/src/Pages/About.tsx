import { Head, Link, router } from "@inertiajs/react";
import { AboutPageProps, AboutPagePropsSchema, withValidatedProps } from "../schemas";

function About({ page_title, auth, csrf_token }: AboutPageProps) {
  return (
    <>
      <Head title={page_title} />
      
      <div className="min-h-screen bg-gradient-to-br from-indigo-50 via-white to-cyan-50">
        <div className="mx-auto max-w-2xl px-4 py-16 sm:px-6 sm:py-24 lg:max-w-7xl lg:px-8">
          
          {/* Header */}
          <div className="text-center mb-12">
            <div className="mx-auto h-16 w-16 rounded-full bg-gradient-to-r from-indigo-500 to-purple-600 flex items-center justify-center mb-6">
              <svg className="h-8 w-8 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
              </svg>
            </div>
            <h1 className="text-4xl font-bold tracking-tight text-gray-900 sm:text-5xl">
              {page_title}
            </h1>
            <p className="mt-4 text-lg text-gray-600">
              Learn about this Inertia.js and Gleam integration
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

          <div className="mx-auto max-w-3xl">
            
            {/* Main Card */}
            <div className="bg-white shadow-xl ring-1 ring-gray-900/5 rounded-2xl overflow-hidden">
              
              <div className="p-6">
                
                {/* Navigation */}
                <div className="mb-8">
                  <h3 className="text-lg font-semibold text-gray-900 mb-4">Quick Navigation</h3>
                  <div className="flex flex-wrap gap-3">
                    <Link 
                      href="/" 
                      className="inline-flex items-center px-4 py-2 border border-transparent text-sm font-medium rounded-lg text-indigo-700 bg-indigo-100 hover:bg-indigo-200 transition-colors duration-200"
                    >
                      <svg className="mr-2 h-4 w-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M3 12l2-2m0 0l7-7 7 7M5 10v10a1 1 0 001 1h3m10-11l2 2m-2-2v10a1 1 0 01-1 1h-3m-6 0a1 1 0 001-1v-4a1 1 0 011-1h2a1 1 0 011 1v4a1 1 0 001 1m-6 0h6" />
                      </svg>
                      Home
                    </Link>
                    <Link 
                      href="/users" 
                      className="inline-flex items-center px-4 py-2 border border-transparent text-sm font-medium rounded-lg text-green-700 bg-green-100 hover:bg-green-200 transition-colors duration-200"
                    >
                      <svg className="mr-2 h-4 w-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 4.354a4 4 0 110 5.292M15 21H3v-1a6 6 0 0112 0v1zm0 0h6v-1a6 6 0 00-9-5.197m13.5-9a2.5 2.5 0 11-5 0 2.5 2.5 0 015 0z" />
                      </svg>
                      Users (Forms Demo)
                    </Link>
                  </div>
                </div>

                {/* About Content */}
                <div className="mb-8">
                  <h2 className="text-2xl font-bold text-gray-900 mb-6">About Inertia Gleam</h2>
                  
                  <div className="prose prose-indigo max-w-none">
                    <p className="text-gray-600 mb-6">
                      This demo showcases a full-stack application that bridges the gap between modern frontend development and the emerging Gleam programming language.
                    </p>
                    
                    <div className="bg-gradient-to-r from-indigo-50 to-purple-50 rounded-lg p-6 mb-6">
                      <h3 className="text-lg font-semibold text-gray-900 mb-4">Technology Stack</h3>
                      <div className="space-y-3">
                        <div className="flex items-center space-x-3">
                          <div className="h-8 w-8 rounded-full bg-indigo-100 flex items-center justify-center">
                            <svg className="h-4 w-4 text-indigo-600" fill="currentColor" viewBox="0 0 20 20">
                              <path d="M3 4a1 1 0 011-1h12a1 1 0 011 1v2a1 1 0 01-1 1H4a1 1 0 01-1-1V4zM3 10a1 1 0 011-1h6a1 1 0 011 1v6a1 1 0 01-1 1H4a1 1 0 01-1-1v-6zM14 9a1 1 0 00-1 1v6a1 1 0 001 1h2a1 1 0 001-1v-6a1 1 0 00-1-1h-2z" />
                            </svg>
                          </div>
                          <div>
                            <p className="font-medium text-gray-900">Backend: Gleam + Wisp</p>
                            <p className="text-sm text-gray-600">Type-safe functional programming with excellent performance</p>
                          </div>
                        </div>
                        
                        <div className="flex items-center space-x-3">
                          <div className="h-8 w-8 rounded-full bg-cyan-100 flex items-center justify-center">
                            <svg className="h-4 w-4 text-cyan-600" fill="currentColor" viewBox="0 0 20 20">
                              <path fillRule="evenodd" d="M12.316 3.051a1 1 0 01.633 1.265l-4 12a1 1 0 11-1.898-.632l4-12a1 1 0 011.265-.633zM5.707 6.293a1 1 0 010 1.414L3.414 10l2.293 2.293a1 1 0 11-1.414 1.414l-3-3a1 1 0 010-1.414l3-3a1 1 0 011.414 0zm8.586 0a1 1 0 011.414 0l3 3a1 1 0 010 1.414l-3 3a1 1 0 11-1.414-1.414L16.586 10l-2.293-2.293a1 1 0 010-1.414z" clipRule="evenodd" />
                            </svg>
                          </div>
                          <div>
                            <p className="font-medium text-gray-900">Frontend: React + Inertia.js</p>
                            <p className="text-sm text-gray-600">Modern SPA experience without API complexity</p>
                          </div>
                        </div>
                        
                        <div className="flex items-center space-x-3">
                          <div className="h-8 w-8 rounded-full bg-purple-100 flex items-center justify-center">
                            <svg className="h-4 w-4 text-purple-600" fill="currentColor" viewBox="0 0 20 20">
                              <path fillRule="evenodd" d="M3 3a1 1 0 000 2v8a2 2 0 002 2h2.586l-1.293 1.293a1 1 0 101.414 1.414L10 15.414l2.293 2.293a1 1 0 001.414-1.414L12.414 15H15a2 2 0 002-2V5a1 1 0 100-2H3zm11.707 4.707a1 1 0 00-1.414-1.414L10 9.586 8.707 8.293a1 1 0 00-1.414 0l-2 2a1 1 0 101.414 1.414L8 10.414l1.293 1.293a1 1 0 001.414 0l4-4z" clipRule="evenodd" />
                            </svg>
                          </div>
                          <div>
                            <p className="font-medium text-gray-900">Features: Full-stack TypeScript</p>
                            <p className="text-sm text-gray-600">SPA navigation, forms, validation, file uploads</p>
                          </div>
                        </div>
                      </div>
                    </div>
                    
                    <div className="grid md:grid-cols-2 gap-6 mb-6">
                      <div className="bg-white border border-gray-200 rounded-lg p-4">
                        <h4 className="font-semibold text-gray-900 mb-2">Why Gleam?</h4>
                        <ul className="text-sm text-gray-600 space-y-1">
                          <li>• Type safety without complexity</li>
                          <li>• Functional programming paradigm</li>
                          <li>• Excellent error messages</li>
                          <li>• Concurrent and fault-tolerant</li>
                        </ul>
                      </div>
                      
                      <div className="bg-white border border-gray-200 rounded-lg p-4">
                        <h4 className="font-semibold text-gray-900 mb-2">Why Inertia.js?</h4>
                        <ul className="text-sm text-gray-600 space-y-1">
                          <li>• No API layer needed</li>
                          <li>• Server-side routing</li>
                          <li>• SPA-like experience</li>
                          <li>• Simple data flow</li>
                        </ul>
                      </div>
                    </div>
                  </div>
                </div>

                {/* Test Navigation */}
                <div>
                  <h4 className="text-lg font-semibold text-gray-900 mb-4">Test Navigation</h4>
                  <div className="flex flex-col sm:flex-row gap-3">
                    <button
                      onClick={() => router.visit("/about")}
                      className="inline-flex items-center justify-center px-4 py-2 border border-indigo-300 text-sm font-medium rounded-md text-indigo-700 bg-white hover:bg-indigo-50 transition-colors duration-200"
                    >
                      <svg className="mr-2 h-4 w-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15" />
                      </svg>
                      Reload About (XHR)
                    </button>
                    <button 
                      onClick={() => (window.location.href = "/about")}
                      className="inline-flex items-center justify-center px-4 py-2 border border-gray-300 text-sm font-medium rounded-md text-gray-700 bg-white hover:bg-gray-50 transition-colors duration-200"
                    >
                      <svg className="mr-2 h-4 w-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15" />
                      </svg>
                      Reload About (Full)
                    </button>
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

export default withValidatedProps(AboutPagePropsSchema, About);