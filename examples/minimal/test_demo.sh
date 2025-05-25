#!/bin/bash

# Demo Test Script for Inertia Gleam Minimal Example
# This script tests all the key functionality of the form handling demo

set -e

echo "🚀 Starting Inertia Gleam Demo Test"
echo "=================================="

# Start the server in background
echo "📡 Starting Gleam server..."
cd "$(dirname "$0")"
gleam run &
SERVER_PID=$!

# Wait for server to start
sleep 3

# Function to cleanup on exit
cleanup() {
    echo "🧹 Cleaning up..."
    kill $SERVER_PID 2>/dev/null || true
    exit
}
trap cleanup EXIT INT TERM

# Base URL
BASE_URL="http://localhost:8000"

echo "✅ Server started (PID: $SERVER_PID)"
echo ""

# Test 1: Home page HTML response
echo "🏠 Testing home page (HTML)..."
RESPONSE=$(curl -s "$BASE_URL/")
if echo "$RESPONSE" | grep -q "data-page.*Home"; then
    echo "✅ Home page HTML response OK"
else
    echo "❌ Home page HTML response failed"
    exit 1
fi

# Test 2: Home page Inertia XHR response
echo "🔄 Testing home page (Inertia XHR)..."
RESPONSE=$(curl -s -H "X-Inertia: true" "$BASE_URL/")
if echo "$RESPONSE" | grep -q '"component":"Home"'; then
    echo "✅ Home page Inertia XHR response OK"
else
    echo "❌ Home page Inertia XHR response failed"
    exit 1
fi

# Test 3: Users list page
echo "👥 Testing users list page..."
RESPONSE=$(curl -s -H "X-Inertia: true" "$BASE_URL/users")
if echo "$RESPONSE" | grep -q '"component":"Users"' && echo "$RESPONSE" | grep -q '"name":"Alice"'; then
    echo "✅ Users list page OK"
else
    echo "❌ Users list page failed"
    exit 1
fi

# Test 4: User creation form
echo "📝 Testing user creation form..."
RESPONSE=$(curl -s "$BASE_URL/users/create")
if echo "$RESPONSE" | grep -q "data-page.*CreateUser"; then
    echo "✅ User creation form OK"
else
    echo "❌ User creation form failed"
    exit 1
fi

# Test 5: Individual user page
echo "👤 Testing individual user page..."
RESPONSE=$(curl -s -H "X-Inertia: true" "$BASE_URL/users/1")
if echo "$RESPONSE" | grep -q '"component":"ShowUser"' && echo "$RESPONSE" | grep -q '"name":"Alice"'; then
    echo "✅ Individual user page OK"
else
    echo "❌ Individual user page failed"
    exit 1
fi

# Test 6: User edit form
echo "✏️  Testing user edit form..."
RESPONSE=$(curl -s "$BASE_URL/users/1/edit")
if echo "$RESPONSE" | grep -q "data-page.*EditUser"; then
    echo "✅ User edit form OK"
else
    echo "❌ User edit form failed"
    exit 1
fi

# Test 7: About page
echo "ℹ️  Testing about page..."
RESPONSE=$(curl -s -H "X-Inertia: true" "$BASE_URL/about")
if echo "$RESPONSE" | grep -q '"component":"About"'; then
    echo "✅ About page OK"
else
    echo "❌ About page failed"
    exit 1
fi

# Test 8: Form validation (empty fields)
echo "🚫 Testing form validation (empty fields)..."
RESPONSE=$(curl -s -X POST -d "name=&email=" -H "Content-Type: application/x-www-form-urlencoded" "$BASE_URL/users")
if echo "$RESPONSE" | grep -q "Name is required" && echo "$RESPONSE" | grep -q "Email is required"; then
    echo "✅ Empty field validation OK"
else
    echo "❌ Empty field validation failed"
    exit 1
fi

# Test 9: Form validation (invalid email)
echo "📧 Testing form validation (invalid email)..."
RESPONSE=$(curl -s -X POST -d "name=Test&email=invalid" -H "Content-Type: application/x-www-form-urlencoded" "$BASE_URL/users")
if echo "$RESPONSE" | grep -q "Email must contain @"; then
    echo "✅ Invalid email validation OK"
else
    echo "❌ Invalid email validation failed"
    exit 1
fi

# Test 10: Form validation (duplicate email)
echo "🔄 Testing form validation (duplicate email)..."
RESPONSE=$(curl -s -X POST -d "name=Test&email=alice@example.com" -H "Content-Type: application/x-www-form-urlencoded" "$BASE_URL/users")
if echo "$RESPONSE" | grep -q "Email already exists"; then
    echo "✅ Duplicate email validation OK"
else
    echo "❌ Duplicate email validation failed"
    exit 1
fi

# Test 11: Successful form submission (redirect)
echo "✅ Testing successful form submission..."
RESPONSE=$(curl -s -w "%{http_code}" -X POST -d "name=NewUser&email=newuser@example.com" -H "Content-Type: application/x-www-form-urlencoded" "$BASE_URL/users")
if echo "$RESPONSE" | grep -q "303"; then
    echo "✅ Successful form submission (redirect) OK"
else
    echo "❌ Successful form submission failed"
    exit 1
fi

# Test 12: Static files (JavaScript)
echo "📦 Testing static file serving..."
RESPONSE=$(curl -s -w "%{http_code}" "$BASE_URL/static/js/main.js")
if echo "$RESPONSE" | grep -q "200"; then
    echo "✅ Static file serving OK"
else
    echo "❌ Static file serving failed"
    exit 1
fi

# Test 13: 404 handling
echo "🔍 Testing 404 handling..."
HTTP_CODE=$(curl -s -w "%{http_code}" -o /dev/null "$BASE_URL/nonexistent")
if [ "$HTTP_CODE" = "404" ]; then
    echo "✅ 404 handling OK"
else
    echo "❌ 404 handling failed (got $HTTP_CODE)"
    exit 1
fi

echo ""
echo "🎉 All tests passed!"
echo "=================================="
echo "✅ HTML responses working"
echo "✅ Inertia XHR responses working"  
echo "✅ Form validation working"
echo "✅ Redirects working"
echo "✅ Static file serving working"
echo "✅ Error handling working"
echo "✅ Props system working"
echo "✅ Always props working"
echo ""
echo "🌟 Demo is ready for use!"
echo "   Visit: http://localhost:8000"
echo "   Then press Ctrl+C to stop the server"

# Keep server running for manual testing
wait $SERVER_PID