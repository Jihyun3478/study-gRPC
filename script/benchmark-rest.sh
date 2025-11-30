#!/bin/bash

echo "=========================================="
echo "REST API Performance Benchmark"
echo "=========================================="
echo ""

# 서버 실행 확인
if ! nc -z localhost 8080 2>/dev/null; then
    echo "Error: REST server is not running!"
    exit 1
fi

echo "REST server connection verified"
echo ""

# 성능 테스트 도구 확인
if ! command -v wrk &> /dev/null; then
    echo "Installing wrk..."
    brew install wrk
fi

echo "Preparing test data..."
# 1000명 사용자 미리 생성
for i in {1..1000}; do
    curl -X POST http://localhost:8080/users \
        -H "Content-Type: application/json" \
        -d "{\"name\":\"user$i\",\"email\":\"user$i@test.com\"}" \
        > /dev/null 2>&1
done
echo "1000 users created"
echo ""

echo "Running performance tests..."
echo ""

# 1. CreateUser 성능 테스트
echo "1. POST /users - 30s duration, 50 connections"
echo "---"
wrk -t12 -c50 -d30s \
  -s script/wrk-post.lua \
  http://localhost:8080/users

echo ""
echo ""

# 2. GetUser 성능 테스트
echo "2. GET /users/:id - 30s duration, 50 connections"
echo "---"
wrk -t12 -c50 -d30s \
  http://localhost:8080/users/user1

echo ""
echo ""

# 3. ListUsers (10건) - 기존
echo "3. GET /users?limit=10 - 30s duration, 50 connections"
echo "---"
wrk -t12 -c50 -d30s \
  "http://localhost:8080/users?limit=10"

echo ""
echo ""

# 4. ListUsers (100건) - 중간
echo "4. GET /users?limit=100 - 30s duration, 50 connections"
echo "---"
wrk -t12 -c50 -d30s \
  "http://localhost:8080/users?limit=100"

echo ""
echo ""

# 5. ListUsers (1000건) - 대용량
echo "5. GET /users?limit=1000 - 30s duration, 50 connections"
echo "---"
wrk -t12 -c50 -d30s \
  "http://localhost:8080/users?limit=1000"

echo ""
echo ""
echo "=========================================="
echo "REST Benchmark Completed"
echo "=========================================="
