#!/bin/bash

echo "=========================================="
echo "gRPC Performance Benchmark"
echo "=========================================="
echo ""

if ! nc -z localhost 50052 2>/dev/null; then
    echo "Error: gRPC server is not running!"
    exit 1
fi

echo "gRPC server connection verified"
echo ""

if ! command -v ghz &> /dev/null; then
    echo "Installing ghz..."
    go install github.com/bojand/ghz/cmd/ghz@latest
fi

echo "Preparing test data..."
for i in {1..1000}; do
    grpcurl -plaintext -d "{\"name\":\"user$i\",\"email\":\"user$i@test.com\"}" \
        localhost:50052 user.UserService/CreateUser > /dev/null 2>&1
done
echo "1000 users created"
echo ""

echo "Running performance tests..."
echo ""

# 1. CreateUser - 시간 기반 (30초)
echo "1. CreateUser - 30s duration, 50 concurrent"
echo "---"
ghz --insecure \
  --proto proto/user.proto \
  --call user.UserService.CreateUser \
  -d '{"name":"test","email":"test@example.com"}' \
  -z 30s \
  -c 50 \
  localhost:50052

echo ""
echo ""

# 2. GetUser - 시간 기반 (30초)
echo "2. GetUser - 30s duration, 50 concurrent"
echo "---"
ghz --insecure \
  --proto proto/user.proto \
  --call user.UserService.GetUser \
  -d '{"id":"user1"}' \
  -z 30s \
  -c 50 \
  localhost:50052

echo ""
echo ""

# 3. ListUsers (10건) - 시간 기반 (30초)
echo "3. ListUsers(10) - 30s duration, 50 concurrent"
echo "---"
ghz --insecure \
  --proto proto/user.proto \
  --call user.UserService.ListUsers \
  -d '{"limit":10}' \
  -z 30s \
  -c 50 \
  localhost:50052

echo ""
echo ""

# 4. ListUsers (100건) - 시간 기반 (30초)
echo "4. ListUsers(100) - 30s duration, 50 concurrent"
echo "---"
ghz --insecure \
  --proto proto/user.proto \
  --call user.UserService.ListUsers \
  -d '{"limit":100}' \
  -z 30s \
  -c 50 \
  localhost:50052

echo ""
echo ""

# 5. ListUsers (1000건) - 시간 기반 (30초)
echo "5. ListUsers(1000) - 30s duration, 50 concurrent"
echo "---"
ghz --insecure \
  --proto proto/user.proto \
  --call user.UserService.ListUsers \
  -d '{"limit":1000}' \
  -z 30s \
  -c 50 \
  localhost:50052

echo ""
echo ""
echo "=========================================="
echo "gRPC Benchmark Completed"
echo "=========================================="
