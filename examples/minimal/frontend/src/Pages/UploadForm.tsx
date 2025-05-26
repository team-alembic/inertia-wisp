import React, { useState, Fragment } from 'react';
import { Head, useForm, Link } from '@inertiajs/react';
import { Dialog, Transition } from '@headlessui/react';
import { UploadFormPageProps, UploadFormPagePropsSchema, withValidatedProps } from '../schemas';

interface FormData {
  files: FileList | null;
  _token: string;
}

function UploadForm({ 
  auth, 
  csrf_token, 
  max_files, 
  max_size_mb, 
  allowed_types = [],
  errors = {} 
}: UploadFormPageProps) {
  const [selectedFiles, setSelectedFiles] = useState<File[]>([]);
  const [dragActive, setDragActive] = useState(false);
  const [showSuccess, setShowSuccess] = useState(false);

  const { data, setData, post, processing, reset } = useForm<FormData>({
    files: null,
    _token: csrf_token
  });

  const handleFileSelect = (files: FileList | null) => {
    if (!files) return;

    const newFileArray = Array.from(files);
    const combinedFiles = [...selectedFiles, ...newFileArray];
    
    // Validate total file count
    if (combinedFiles.length > max_files) {
      alert(`Maximum ${max_files} files allowed. You currently have ${selectedFiles.length} files selected.`);
      return;
    }

    // Validate file sizes for new files only
    const oversizedFiles = newFileArray.filter(file => 
      file.size > max_size_mb * 1024 * 1024
    );
    if (oversizedFiles.length > 0) {
      alert(`Files must be smaller than ${max_size_mb}MB`);
      return;
    }

    // Validate file types for new files only if specified
    if (allowed_types.length > 0) {
      const invalidFiles = newFileArray.filter(file => 
        !allowed_types.includes(file.type)
      );
      if (invalidFiles.length > 0) {
        alert(`Invalid file type. Allowed types: ${allowed_types.join(', ')}`);
        return;
      }
    }

    // Create new FileList with all files
    const dt = new DataTransfer();
    combinedFiles.forEach(file => dt.items.add(file));
    
    setSelectedFiles(combinedFiles);
    setData('files', dt.files);
  };

  const handleDrag = (e: React.DragEvent) => {
    e.preventDefault();
    e.stopPropagation();
    if (e.type === "dragenter" || e.type === "dragover") {
      setDragActive(true);
    } else if (e.type === "dragleave") {
      setDragActive(false);
    }
  };

  const handleDrop = (e: React.DragEvent) => {
    e.preventDefault();
    e.stopPropagation();
    setDragActive(false);
    
    if (e.dataTransfer.files && e.dataTransfer.files[0]) {
      handleFileSelect(e.dataTransfer.files);
    }
  };

  const removeFile = (index: number) => {
    const newFiles = selectedFiles.filter((_, i) => i !== index);
    setSelectedFiles(newFiles);
    
    // Create new FileList
    const dt = new DataTransfer();
    newFiles.forEach(file => dt.items.add(file));
    setData('files', dt.files);
  };

  const submit = (e: React.FormEvent) => {
    e.preventDefault();
    
    if (!data.files || data.files.length === 0) {
      alert('Please select files to upload');
      return;
    }

    const formData = new FormData();
    formData.append('_token', data._token);
    
    for (let i = 0; i < data.files.length; i++) {
      const file = data.files[i];
      if (file) {
        formData.append(`file_${i}`, file);
      }
    }

    post('/upload', {
      data: formData,
      forceFormData: true,
      onSuccess: () => {
        reset();
        setSelectedFiles([]);
        setShowSuccess(true);
      }
    });
  };

  const formatFileSize = (bytes: number): string => {
    if (bytes === 0) return '0 Bytes';
    const k = 1024;
    const sizes = ['Bytes', 'KB', 'MB', 'GB'];
    const i = Math.floor(Math.log(bytes) / Math.log(k));
    return parseFloat((bytes / Math.pow(k, i)).toFixed(2)) + ' ' + sizes[i];
  };

  return (
    <>
      <Head title="Upload Files" />
      
      <div className="min-h-screen bg-gradient-to-br from-indigo-50 via-white to-cyan-50">
        <div className="mx-auto max-w-2xl px-4 py-16 sm:px-6 sm:py-24 lg:max-w-7xl lg:px-8">
          
          {/* Header */}
          <div className="text-center mb-12">
            <div className="mx-auto h-16 w-16 rounded-full bg-gradient-to-r from-indigo-500 to-purple-600 flex items-center justify-center mb-6">
              <svg className="h-8 w-8 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M7 16a4 4 0 01-.88-7.903A5 5 0 1115.9 6L16 6a5 5 0 011 9.9M15 13l-3-3m0 0l-3 3m3-3v12" />
              </svg>
            </div>
            <h1 className="text-4xl font-bold tracking-tight text-gray-900 sm:text-5xl">
              Upload Files
            </h1>
            <p className="mt-4 text-lg text-gray-600">
              Upload up to {max_files} files, max {max_size_mb}MB each
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

          <div className="mx-auto max-w-xl">
            
            {/* Main Card */}
            <div className="bg-white shadow-xl ring-1 ring-gray-900/5 rounded-2xl overflow-hidden">
              
              {/* Errors */}
              {Object.keys(errors).length > 0 && (
                <div className="bg-red-50 border-l-4 border-red-400 p-4 m-6 rounded-md">
                  <div className="flex">
                    <div className="flex-shrink-0">
                      <svg className="h-5 w-5 text-red-400" viewBox="0 0 20 20" fill="currentColor">
                        <path fillRule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zM8.707 7.293a1 1 0 00-1.414 1.414L8.586 10l-1.293 1.293a1 1 0 101.414 1.414L10 11.414l1.293 1.293a1 1 0 001.414-1.414L11.414 10l1.293-1.293a1 1 0 00-1.414-1.414L10 8.586 8.707 7.293z" clipRule="evenodd" />
                      </svg>
                    </div>
                    <div className="ml-3">
                      <h3 className="text-sm font-medium text-red-800">Upload errors:</h3>
                      <div className="mt-2 text-sm text-red-700">
                        <ul className="list-disc pl-5 space-y-1">
                          {Object.entries(errors).map(([field, message]) => (
                            <li key={field}>
                              <strong>{field}:</strong> {message}
                            </li>
                          ))}
                        </ul>
                      </div>
                    </div>
                  </div>
                </div>
              )}

              <div className="p-6">
                
                {/* Upload Form */}
                <form onSubmit={submit} className="space-y-6">
                  
                  {/* File Drop Zone */}
                  <div className="relative">
                    <div
                      className={`upload-zone ${dragActive ? 'upload-zone--active' : 'upload-zone--inactive'}`}
                      onDragEnter={handleDrag}
                      onDragLeave={handleDrag}
                      onDragOver={handleDrag}
                      onDrop={handleDrop}
                    >
                      <input
                        type="file"
                        multiple
                        accept={allowed_types.join(',')}
                        onChange={(e) => handleFileSelect(e.target.files)}
                        className="absolute inset-0 w-full h-full opacity-0 cursor-pointer"
                      />
                      
                      <div className="mx-auto h-16 w-16 rounded-full bg-gradient-to-r from-indigo-500 to-purple-600 flex items-center justify-center mb-4">
                        <svg className="h-8 w-8 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                          <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 6v6m0 0v6m0-6h6m-6 0H6" />
                        </svg>
                      </div>
                      
                      <div className="space-y-2">
                        <p className="text-lg font-semibold text-gray-900">
                          Drop files here, or <span className="text-indigo-600">browse</span>
                        </p>
                        <p className="text-sm text-gray-500">
                          {allowed_types.length > 0 
                            ? `Supported: ${allowed_types.join(', ')}`
                            : 'All file types supported'
                          }
                        </p>
                      </div>
                    </div>
                  </div>

                  {/* Selected Files */}
                  {selectedFiles.length > 0 && (
                    <div>
                      <div className="flex items-center justify-between mb-4">
                        <h3 className="text-lg font-semibold text-gray-900">
                          Selected Files
                        </h3>
                        <span className="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-indigo-100 text-indigo-800">
                          {selectedFiles.length} / {max_files}
                        </span>
                      </div>
                      
                      <div className="space-y-3">
                        {selectedFiles.map((file, index) => (
                          <div key={index} className="file-item">
                            <div className="flex-shrink-0">
                              <div className="h-10 w-10 rounded-lg bg-indigo-100 flex items-center justify-center">
                                <svg className="h-5 w-5 text-indigo-600" fill="currentColor" viewBox="0 0 20 20">
                                  <path fillRule="evenodd" d="M4 4a2 2 0 012-2h4.586A2 2 0 0112 2.586L15.414 6A2 2 0 0116 7.414V16a2 2 0 01-2 2H6a2 2 0 01-2-2V4z" clipRule="evenodd" />
                                </svg>
                              </div>
                            </div>
                            <div className="flex-1 min-w-0">
                              <p className="text-sm font-medium text-gray-900 truncate">
                                {file.name}
                              </p>
                              <p className="text-sm text-gray-500">
                                {formatFileSize(file.size)} • {file.type || 'Unknown type'}
                              </p>
                            </div>
                            <button
                              type="button"
                              onClick={() => removeFile(index)}
                              className="flex-shrink-0 p-1 rounded-full text-gray-400 hover:text-red-500 hover:bg-red-50 transition-colors duration-200"
                            >
                              <svg className="h-5 w-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M6 18L18 6M6 6l12 12" />
                              </svg>
                            </button>
                          </div>
                        ))}
                      </div>
                    </div>
                  )}

                  {/* Upload Button */}
                  <button
                    type="submit"
                    disabled={processing || selectedFiles.length === 0}
                    className={`btn-primary ${processing || selectedFiles.length === 0 ? 'btn-primary--disabled' : 'btn-primary--enabled'}`}
                  >
                    {processing ? (
                      <>
                        <svg className="animate-spin -ml-1 mr-3 h-5 w-5 text-white" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
                          <circle className="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" strokeWidth="4"></circle>
                          <path className="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
                        </svg>
                        Uploading...
                      </>
                    ) : (
                      <>
                        <svg className="mr-2 h-5 w-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                          <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M7 16a4 4 0 01-.88-7.903A5 5 0 1115.9 6L16 6a5 5 0 011 9.9M15 13l-3-3m0 0l-3 3m3-3v12" />
                        </svg>
                        Upload {selectedFiles.length > 0 ? selectedFiles.length : ''} File{selectedFiles.length !== 1 ? 's' : ''}
                      </>
                    )}
                  </button>

                  {/* Upload Info */}
                  <div className="text-center">
                    <p className="text-sm text-gray-500">
                      Maximum {max_files} files • {max_size_mb}MB per file
                    </p>
                    {processing && (
                      <p className="mt-2 text-sm text-indigo-600 font-medium">
                        Please wait while files are being uploaded...
                      </p>
                    )}
                  </div>

                </form>

              </div>

              {/* Auth Info */}
              {auth && (
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

      {/* Success Modal */}
      <Transition appear show={showSuccess} as={Fragment}>
        <Dialog as="div" className="relative z-10" onClose={() => setShowSuccess(false)}>
          <Transition.Child
            as={Fragment}
            enter="ease-out duration-300"
            enterFrom="opacity-0"
            enterTo="opacity-100"
            leave="ease-in duration-200"
            leaveFrom="opacity-100"
            leaveTo="opacity-0"
          >
            <div className="fixed inset-0 bg-black bg-opacity-25" />
          </Transition.Child>

          <div className="fixed inset-0 overflow-y-auto">
            <div className="flex min-h-full items-center justify-center p-4 text-center">
              <Transition.Child
                as={Fragment}
                enter="ease-out duration-300"
                enterFrom="opacity-0 scale-95"
                enterTo="opacity-100 scale-100"
                leave="ease-in duration-200"
                leaveFrom="opacity-100 scale-100"
                leaveTo="opacity-0 scale-95"
              >
                <Dialog.Panel className="w-full max-w-md transform overflow-hidden rounded-2xl bg-white p-6 text-left align-middle shadow-xl transition-all">
                  <div className="text-center">
                    <div className="mx-auto flex h-12 w-12 items-center justify-center rounded-full bg-green-100 mb-4">
                      <svg className="h-6 w-6 text-green-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M5 13l4 4L19 7" />
                      </svg>
                    </div>
                    <Dialog.Title as="h3" className="text-lg font-medium leading-6 text-gray-900 mb-2">
                      Upload Successful!
                    </Dialog.Title>
                    <p className="text-sm text-gray-500 mb-6">
                      Your files have been uploaded successfully.
                    </p>
                    <button
                      type="button"
                      className="inline-flex justify-center rounded-md border border-transparent bg-green-100 px-4 py-2 text-sm font-medium text-green-900 hover:bg-green-200 focus:outline-none focus-visible:ring-2 focus-visible:ring-green-500 focus-visible:ring-offset-2 transition-colors duration-200"
                      onClick={() => setShowSuccess(false)}
                    >
                      Got it, thanks!
                    </button>
                  </div>
                </Dialog.Panel>
              </Transition.Child>
            </div>
          </div>
        </Dialog>
      </Transition>
    </>
  );
}

export default withValidatedProps(UploadFormPagePropsSchema, UploadForm);