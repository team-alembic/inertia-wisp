import React, { useState } from 'react';
import { Head, useForm, Link } from '@inertiajs/react';
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
      
      <div style={{
        minHeight: '100vh',
        background: 'linear-gradient(135deg, #667eea 0%, #764ba2 100%)',
        padding: '2rem 1rem',
        fontFamily: '-apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Helvetica Neue", Arial, sans-serif'
      }}>
        <div style={{
          maxWidth: '600px',
          margin: '0 auto',
          background: 'white',
          borderRadius: '20px',
          boxShadow: '0 25px 50px -12px rgba(0, 0, 0, 0.25)',
          overflow: 'hidden'
        }}>
          
          {/* Header */}
          <div style={{
            background: 'linear-gradient(135deg, #667eea 0%, #764ba2 100%)',
            padding: '2rem',
            color: 'white'
          }}>
            <div style={{ display: 'flex', alignItems: 'center', marginBottom: '1rem' }}>
              <div style={{
                width: '60px',
                height: '60px',
                background: 'rgba(255, 255, 255, 0.2)',
                borderRadius: '15px',
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'center',
                fontSize: '24px',
                marginRight: '1rem'
              }}>
                📁
              </div>
              <div>
                <h1 style={{ 
                  margin: '0',
                  fontSize: '28px',
                  fontWeight: '700',
                  lineHeight: '1.2'
                }}>
                  Upload Files
                </h1>
                <p style={{ 
                  margin: '0.5rem 0 0 0',
                  fontSize: '16px',
                  opacity: '0.9'
                }}>
                  Upload up to {max_files} files, max {max_size_mb}MB each
                </p>
              </div>
            </div>

            <Link 
              href="/" 
              style={{
                color: 'white',
                textDecoration: 'none',
                fontSize: '14px',
                fontWeight: '500',
                display: 'inline-flex',
                alignItems: 'center',
                padding: '0.5rem 1rem',
                background: 'rgba(255, 255, 255, 0.1)',
                borderRadius: '10px',
                transition: 'all 0.2s'
              }}
              onMouseOver={(e) => {
                e.currentTarget.style.background = 'rgba(255, 255, 255, 0.2)';
              }}
              onMouseOut={(e) => {
                e.currentTarget.style.background = 'rgba(255, 255, 255, 0.1)';
              }}
            >
              ← Back to Home
            </Link>
          </div>

          <div style={{ padding: '2rem' }}>

            {/* Errors */}
            {Object.keys(errors).length > 0 && (
              <div style={{
                background: '#fee2e2',
                border: '1px solid #fecaca',
                borderRadius: '12px',
                padding: '1rem',
                marginBottom: '2rem'
              }}>
                <h3 style={{
                  color: '#dc2626',
                  fontSize: '16px',
                  fontWeight: '600',
                  margin: '0 0 0.5rem 0'
                }}>
                  Upload errors:
                </h3>
                <ul style={{ 
                  margin: '0',
                  paddingLeft: '1.5rem',
                  color: '#dc2626'
                }}>
                  {Object.entries(errors).map(([field, message]) => (
                    <li key={field} style={{ marginBottom: '0.25rem' }}>
                      <strong>{field}:</strong> {message}
                    </li>
                  ))}
                </ul>
              </div>
            )}

            {/* Upload Form */}
            <form onSubmit={submit}>
              
              {/* File Drop Zone */}
              <div
                style={{
                  border: `2px dashed ${dragActive ? '#667eea' : '#d1d5db'}`,
                  borderRadius: '15px',
                  padding: '3rem 2rem',
                  textAlign: 'center',
                  background: dragActive ? '#f8faff' : '#f9fafb',
                  transition: 'all 0.3s ease',
                  position: 'relative',
                  cursor: 'pointer'
                }}
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
                  style={{
                    position: 'absolute',
                    top: '0',
                    left: '0',
                    width: '100%',
                    height: '100%',
                    opacity: '0',
                    cursor: 'pointer'
                  }}
                />
                
                <div style={{
                  width: '80px',
                  height: '80px',
                  margin: '0 auto 1.5rem',
                  background: 'linear-gradient(135deg, #667eea 0%, #764ba2 100%)',
                  borderRadius: '20px',
                  display: 'flex',
                  alignItems: 'center',
                  justifyContent: 'center',
                  color: 'white',
                  fontSize: '32px'
                }}>
                  📤
                </div>
                
                <h3 style={{
                  fontSize: '20px',
                  fontWeight: '600',
                  color: '#374151',
                  margin: '0 0 0.5rem 0'
                }}>
                  Drop files here, or <span style={{ color: '#667eea' }}>browse</span>
                </h3>
                <p style={{
                  fontSize: '14px',
                  color: '#6b7280',
                  margin: '0'
                }}>
                  {allowed_types.length > 0 
                    ? `Supported: ${allowed_types.join(', ')}`
                    : 'All file types supported'
                  }
                </p>
              </div>

              {/* Selected Files */}
              {selectedFiles.length > 0 && (
                <div style={{ marginTop: '2rem' }}>
                  <h3 style={{
                    fontSize: '18px',
                    fontWeight: '600',
                    color: '#374151',
                    margin: '0 0 1rem 0',
                    display: 'flex',
                    alignItems: 'center'
                  }}>
                    <span style={{
                      background: '#667eea',
                      color: 'white',
                      width: '24px',
                      height: '24px',
                      borderRadius: '12px',
                      display: 'flex',
                      alignItems: 'center',
                      justifyContent: 'center',
                      fontSize: '12px',
                      fontWeight: '700',
                      marginRight: '0.5rem'
                    }}>
                      {selectedFiles.length}
                    </span>
                    Selected Files ({selectedFiles.length}/{max_files})
                  </h3>
                  
                  <div style={{ display: 'flex', flexDirection: 'column', gap: '0.75rem' }}>
                    {selectedFiles.map((file, index) => (
                      <div key={index} style={{
                        display: 'flex',
                        alignItems: 'center',
                        justifyContent: 'space-between',
                        padding: '1rem',
                        background: '#f8faff',
                        border: '1px solid #e5e7eb',
                        borderRadius: '12px'
                      }}>
                        <div style={{ display: 'flex', alignItems: 'center', flex: '1' }}>
                          <div style={{
                            width: '40px',
                            height: '40px',
                            background: '#667eea',
                            borderRadius: '10px',
                            display: 'flex',
                            alignItems: 'center',
                            justifyContent: 'center',
                            marginRight: '1rem',
                            color: 'white',
                            fontSize: '16px'
                          }}>
                            📄
                          </div>
                          <div style={{ flex: '1', minWidth: '0' }}>
                            <p style={{
                              fontWeight: '600',
                              color: '#374151',
                              margin: '0 0 0.25rem 0',
                              overflow: 'hidden',
                              textOverflow: 'ellipsis',
                              whiteSpace: 'nowrap'
                            }}>
                              {file.name}
                            </p>
                            <p style={{
                              fontSize: '12px',
                              color: '#6b7280',
                              margin: '0'
                            }}>
                              {formatFileSize(file.size)} • {file.type || 'Unknown type'}
                            </p>
                          </div>
                        </div>
                        <button
                          type="button"
                          onClick={() => removeFile(index)}
                          style={{
                            width: '32px',
                            height: '32px',
                            borderRadius: '8px',
                            border: 'none',
                            background: '#fee2e2',
                            color: '#dc2626',
                            cursor: 'pointer',
                            display: 'flex',
                            alignItems: 'center',
                            justifyContent: 'center',
                            fontSize: '16px',
                            transition: 'all 0.2s'
                          }}
                          onMouseOver={(e) => {
                            e.currentTarget.style.background = '#fecaca';
                          }}
                          onMouseOut={(e) => {
                            e.currentTarget.style.background = '#fee2e2';
                          }}
                        >
                          ×
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
                style={{
                  width: '100%',
                  padding: '1rem 2rem',
                  marginTop: '2rem',
                  border: 'none',
                  borderRadius: '12px',
                  background: processing || selectedFiles.length === 0 
                    ? '#9ca3af' 
                    : 'linear-gradient(135deg, #667eea 0%, #764ba2 100%)',
                  color: 'white',
                  fontSize: '16px',
                  fontWeight: '600',
                  cursor: processing || selectedFiles.length === 0 ? 'not-allowed' : 'pointer',
                  display: 'flex',
                  alignItems: 'center',
                  justifyContent: 'center',
                  transition: 'all 0.3s ease',
                  boxShadow: processing || selectedFiles.length === 0 
                    ? 'none' 
                    : '0 4px 15px rgba(102, 126, 234, 0.4)'
                }}
                onMouseOver={(e) => {
                  if (!processing && selectedFiles.length > 0) {
                    e.currentTarget.style.transform = 'translateY(-2px)';
                    e.currentTarget.style.boxShadow = '0 8px 25px rgba(102, 126, 234, 0.6)';
                  }
                }}
                onMouseOut={(e) => {
                  if (!processing && selectedFiles.length > 0) {
                    e.currentTarget.style.transform = 'translateY(0)';
                    e.currentTarget.style.boxShadow = '0 4px 15px rgba(102, 126, 234, 0.4)';
                  }
                }}
              >
                {processing ? (
                  <>
                    <div style={{
                      width: '20px',
                      height: '20px',
                      border: '2px solid transparent',
                      borderTop: '2px solid white',
                      borderRadius: '50%',
                      animation: 'spin 1s linear infinite',
                      marginRight: '0.5rem'
                    }}></div>
                    Uploading...
                  </>
                ) : (
                  <>
                    <span style={{ marginRight: '0.5rem' }}>📤</span>
                    Upload {selectedFiles.length > 0 ? selectedFiles.length : ''} File{selectedFiles.length !== 1 ? 's' : ''}
                  </>
                )}
              </button>

              {/* Upload Info */}
              <div style={{
                textAlign: 'center',
                marginTop: '1rem',
                fontSize: '14px',
                color: '#6b7280'
              }}>
                <p style={{ margin: '0' }}>
                  Maximum {max_files} files • {max_size_mb}MB per file
                </p>
                {processing && (
                  <p style={{ 
                    margin: '0.5rem 0 0 0',
                    color: '#667eea',
                    fontWeight: '500'
                  }}>
                    Please wait while files are being uploaded...
                  </p>
                )}
              </div>

            </form>

            {/* Auth Info */}
            {auth && (
              <div style={{
                marginTop: '2rem',
                paddingTop: '2rem',
                borderTop: '1px solid #e5e7eb',
                textAlign: 'center'
              }}>
                <div style={{
                  display: 'inline-flex',
                  alignItems: 'center',
                  padding: '0.5rem 1rem',
                  background: '#f0fdf4',
                  border: '1px solid #bbf7d0',
                  borderRadius: '8px'
                }}>
                  <div style={{
                    width: '8px',
                    height: '8px',
                    background: '#22c55e',
                    borderRadius: '50%',
                    marginRight: '0.5rem'
                  }}></div>
                  <span style={{
                    fontSize: '14px',
                    color: '#374151'
                  }}>
                    Logged in as: <strong>{auth.user}</strong>
                  </span>
                </div>
              </div>
            )}

          </div>
        </div>
      </div>

      <style>{`
        @keyframes spin {
          0% { transform: rotate(0deg); }
          100% { transform: rotate(360deg); }
        }
      `}</style>
    </>
  );
}

export default withValidatedProps(UploadFormPagePropsSchema, UploadForm);