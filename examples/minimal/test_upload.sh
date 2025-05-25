#!/bin/bash

# Test script for file upload functionality
# This script tests the upload endpoints with curl

echo "🧪 Testing Inertia Gleam File Upload Functionality"
echo "=================================================="

# Start server in background if not running
if ! curl -s http://localhost:8000 > /dev/null; then
    echo "Starting server..."
    cd "$(dirname "$0")"
    gleam run &
    SERVER_PID=$!
    echo "Server started with PID: $SERVER_PID"
    sleep 3
else
    echo "Server already running"
    SERVER_PID=""
fi

echo ""
echo "1. Testing upload form page (GET /upload)"
echo "----------------------------------------"
RESPONSE=$(curl -s -w "%{http_code}" -o /tmp/upload_form.html http://localhost:8000/upload)
if [ "$RESPONSE" = "200" ]; then
    echo "✅ Upload form loads successfully"
    # Check if the response contains the upload form
    if grep -q "Upload Files" /tmp/upload_form.html; then
        echo "✅ Upload form contains expected content"
    else
        echo "❌ Upload form missing expected content"
    fi
else
    echo "❌ Upload form failed to load (HTTP $RESPONSE)"
fi

echo ""
echo "2. Testing upload form with Inertia headers"
echo "-------------------------------------------"
INERTIA_RESPONSE=$(curl -s -w "%{http_code}" -H "X-Inertia: true" -H "Accept: application/json" -o /tmp/upload_inertia.json http://localhost:8000/upload)
if [ "$INERTIA_RESPONSE" = "200" ]; then
    echo "✅ Inertia upload form request successful"
    # Check if response is valid JSON with expected structure
    if command -v jq >/dev/null 2>&1; then
        COMPONENT=$(jq -r '.component' /tmp/upload_inertia.json 2>/dev/null)
        if [ "$COMPONENT" = "UploadForm" ]; then
            echo "✅ Inertia response has correct component"
            MAX_FILES=$(jq -r '.props.max_files' /tmp/upload_inertia.json 2>/dev/null)
            echo "   Max files: $MAX_FILES"
            MAX_SIZE=$(jq -r '.props.max_size_mb' /tmp/upload_inertia.json 2>/dev/null)
            echo "   Max size: ${MAX_SIZE}MB"
        else
            echo "❌ Inertia response has wrong component: $COMPONENT"
        fi
    else
        echo "⚠️  jq not available, skipping JSON validation"
    fi
else
    echo "❌ Inertia upload form request failed (HTTP $INERTIA_RESPONSE)"
fi

echo ""
echo "3. Testing file upload (POST /upload) - empty request"
echo "----------------------------------------------------"
# Test with empty multipart request (should fail)
UPLOAD_RESPONSE=$(curl -s -w "%{http_code}" -X POST -o /tmp/upload_result.txt http://localhost:8000/upload)
echo "Empty upload response: HTTP $UPLOAD_RESPONSE"
if [ "$UPLOAD_RESPONSE" = "400" ] || [ "$UPLOAD_RESPONSE" = "422" ]; then
    echo "✅ Empty upload correctly rejected"
else
    echo "⚠️  Unexpected response for empty upload"
fi

echo ""
echo "4. Testing upload progress endpoint"
echo "----------------------------------"
PROGRESS_RESPONSE=$(curl -s -w "%{http_code}" -H "Accept: application/json" -o /tmp/progress.json http://localhost:8000/upload/progress)
if [ "$PROGRESS_RESPONSE" = "200" ]; then
    echo "✅ Progress endpoint accessible"
    if command -v jq >/dev/null 2>&1; then
        STATUS=$(jq -r '.status' /tmp/progress.json 2>/dev/null)
        echo "   Progress status: $STATUS"
    fi
else
    echo "❌ Progress endpoint failed (HTTP $PROGRESS_RESPONSE)"
fi

echo ""
echo "5. Testing home page navigation"
echo "------------------------------"
HOME_RESPONSE=$(curl -s -w "%{http_code}" -o /tmp/home.html http://localhost:8000/)
if [ "$HOME_RESPONSE" = "200" ]; then
    echo "✅ Home page loads"
    if grep -q "File Upload Demo" /tmp/home.html; then
        echo "✅ Home page contains upload navigation link"
    else
        echo "❌ Home page missing upload navigation"
    fi
else
    echo "❌ Home page failed to load (HTTP $HOME_RESPONSE)"
fi

echo ""
echo "6. Testing with simulated multipart data"
echo "---------------------------------------"
# Create a simple test file
echo "Test file content for upload" > /tmp/test_upload.txt

# Test multipart upload (this will likely fail due to multipart parsing limitations)
MULTIPART_RESPONSE=$(curl -s -w "%{http_code}" -X POST \
    -F "file_0=@/tmp/test_upload.txt" \
    -F "_token=test_token" \
    -o /tmp/multipart_result.txt \
    http://localhost:8000/upload)

echo "Multipart upload response: HTTP $MULTIPART_RESPONSE"
if [ "$MULTIPART_RESPONSE" = "200" ] || [ "$MULTIPART_RESPONSE" = "303" ]; then
    echo "✅ Multipart upload processed (may redirect)"
elif [ "$MULTIPART_RESPONSE" = "400" ] || [ "$MULTIPART_RESPONSE" = "422" ]; then
    echo "⚠️  Multipart upload validation failed (expected for demo)"
else
    echo "❌ Unexpected multipart upload response"
fi

# Cleanup
rm -f /tmp/upload_form.html /tmp/upload_inertia.json /tmp/upload_result.txt
rm -f /tmp/progress.json /tmp/home.html /tmp/multipart_result.txt /tmp/test_upload.txt

echo ""
echo "🏁 Upload functionality test complete!"
echo ""
echo "Note: Full file upload testing requires a proper multipart parser"
echo "The current implementation provides the API structure but may need"
echo "additional multipart parsing implementation for production use."

# Stop server if we started it
if [ -n "$SERVER_PID" ]; then
    echo ""
    echo "Stopping test server (PID: $SERVER_PID)..."
    kill $SERVER_PID 2>/dev/null
fi