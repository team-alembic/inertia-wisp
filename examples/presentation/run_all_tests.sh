#!/bin/bash
set -e

echo "================================"
echo "Running Backend Tests (Gleam)"
echo "================================"
cd backend
gleam test --target erlang
cd ..

echo ""
echo "================================"
echo "Running Frontend Tests (TypeScript)"
echo "================================"
cd frontend
npm test
cd ..

echo ""
echo "================================"
echo "✅ All Tests Passed!"
echo "================================"
