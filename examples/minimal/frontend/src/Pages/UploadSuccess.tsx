import { Head, Link } from '@inertiajs/react';
import { UploadSuccessPageProps, UploadSuccessPagePropsSchema, withValidatedProps } from '../schemas';

function UploadSuccess({ 
  auth, 
  success, 
  uploaded_files 
}: UploadSuccessPageProps) {
  const formatFileSize = (bytes: number): string => {
    if (bytes === 0) return '0 Bytes';
    const k = 1024;
    const sizes = ['Bytes', 'KB', 'MB', 'GB'];
    const i = Math.floor(Math.log(bytes) / Math.log(k));
    return parseFloat((bytes / Math.pow(k, i)).toFixed(2)) + ' ' + sizes[i];
  };

  const getFileIcon = (contentType: string): string => {
    if (contentType.startsWith('image/')) return '🖼️';
    if (contentType === 'application/pdf') return '📄';
    if (contentType.startsWith('text/')) return '📝';
    if (contentType.includes('word')) return '📄';
    return '📁';
  };

  const fileEntries = Object.entries(uploaded_files);

  return (
    <>
      <Head title="Upload Successful" />
      
      <div className="min-h-screen bg-gray-100 py-6 flex flex-col justify-center sm:py-12">
        <div className="relative py-3 sm:max-w-2xl sm:mx-auto">
          <div className="relative px-4 py-10 bg-white shadow-lg sm:rounded-3xl sm:p-20">
            
            {/* Success Header */}
            <div className="max-w-md mx-auto">
              <div className="flex items-center space-x-5">
                <div className="h-14 w-14 bg-green-200 rounded-full flex flex-shrink-0 justify-center items-center text-green-600 text-2xl">
                  ✅
                </div>
                <div className="block pl-2 font-semibold text-xl self-start text-gray-700">
                  <h2 className="leading-relaxed">Upload Successful!</h2>
                  <p className="text-sm text-gray-500 font-normal leading-relaxed">
                    {success}
                  </p>
                </div>
              </div>

              {/* Navigation */}
              <div className="mt-6 flex space-x-4">
                <Link 
                  href="/upload" 
                  className="text-blue-600 hover:text-blue-800 text-sm font-medium"
                >
                  ← Upload More Files
                </Link>
                <Link 
                  href="/" 
                  className="text-gray-600 hover:text-gray-800 text-sm font-medium"
                >
                  Back to Home
                </Link>
              </div>

              {/* Uploaded Files List */}
              {fileEntries.length > 0 && (
                <div className="mt-8">
                  <h3 className="text-lg font-medium text-gray-900 mb-4">
                    Uploaded Files ({fileEntries.length})
                  </h3>
                  
                  <div className="space-y-3">
                    {fileEntries.map(([fieldName, file]) => (
                      <div 
                        key={fieldName} 
                        className="flex items-center p-4 bg-green-50 border border-green-200 rounded-lg"
                      >
                        <div className="flex-shrink-0 text-2xl mr-4">
                          {getFileIcon(file.content_type)}
                        </div>
                        
                        <div className="flex-1 min-w-0">
                          <h4 className="text-sm font-medium text-gray-900 truncate">
                            {file.filename}
                          </h4>
                          <div className="mt-1 flex items-center space-x-4 text-sm text-gray-500">
                            <span>{formatFileSize(file.size)}</span>
                            <span>•</span>
                            <span>{file.content_type}</span>
                          </div>
                        </div>
                        
                        <div className="flex-shrink-0">
                          <div className="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-green-100 text-green-800">
                            Uploaded
                          </div>
                        </div>
                      </div>
                    ))}
                  </div>
                </div>
              )}

              {/* Summary Stats */}
              <div className="mt-8 p-4 bg-gray-50 rounded-lg">
                <h3 className="text-sm font-medium text-gray-900 mb-3">Upload Summary</h3>
                <div className="grid grid-cols-2 gap-4 text-sm">
                  <div>
                    <span className="text-gray-500">Total Files:</span>
                    <span className="ml-2 font-medium text-gray-900">{fileEntries.length}</span>
                  </div>
                  <div>
                    <span className="text-gray-500">Total Size:</span>
                    <span className="ml-2 font-medium text-gray-900">
                      {formatFileSize(
                        fileEntries.reduce((total, [, file]) => total + file.size, 0)
                      )}
                    </span>
                  </div>
                </div>
              </div>

              {/* Actions */}
              <div className="mt-8 space-y-3">
                <Link
                  href="/upload"
                  className="w-full flex justify-center py-2 px-4 border border-transparent rounded-md shadow-sm text-sm font-medium text-white bg-blue-600 hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500"
                >
                  Upload More Files
                </Link>
                
                <div className="flex space-x-3">
                  <Link
                    href="/users"
                    className="flex-1 flex justify-center py-2 px-4 border border-gray-300 rounded-md shadow-sm text-sm font-medium text-gray-700 bg-white hover:bg-gray-50 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500"
                  >
                    View Users
                  </Link>
                  <Link
                    href="/"
                    className="flex-1 flex justify-center py-2 px-4 border border-gray-300 rounded-md shadow-sm text-sm font-medium text-gray-700 bg-white hover:bg-gray-50 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500"
                  >
                    Home
                  </Link>
                </div>
              </div>

              {/* Auth Info */}
              {auth && (
                <div className="mt-8 pt-6 border-t border-gray-200">
                  <p className="text-sm text-gray-500">
                    Logged in as: <span className="font-medium text-gray-900">{auth.user}</span>
                  </p>
                </div>
              )}

            </div>
          </div>
        </div>
      </div>
    </>
  );
}

export default withValidatedProps(UploadSuccessPagePropsSchema, UploadSuccess);