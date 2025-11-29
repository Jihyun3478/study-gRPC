#!/bin/bash

echo "=========================================="
echo "REST Server Test"
echo "=========================================="
echo ""

# 서버 실행 확인
if ! nc -z localhost 8080 2>/dev/null; then
    echo "Error: REST server is not running!"
    echo "Please run 'go run rest-server/main.go' in another terminal first."
    exit 1
fi

echo "REST server connection verified"
echo ""

# 1. 사용자 생성
echo "1. POST /users - Create User"
echo "---"
curl -X POST http://localhost:8080/users \
  -H "Content-Type: application/json" \
  -d '{
    "name": "test",
    "email": "test@gmail.com"
  }' | jq '.'

echo ""
echo ""

# 2. 사용자 조회
echo "2. GET /users/:id - Get User"
echo "---"
curl http://localhost:8080/users/user1 | jq '.'

echo ""
echo ""

# 3. 여러 사용자 생성
echo "3. Create Multiple Users"
echo "---"
echo "Creating user 2:"
curl -X POST http://localhost:8080/users \
  -H "Content-Type: application/json" \
  -d '{"name":"test1","email":"test1@gmail.com"}' | jq '.'

echo ""
echo "Creating user 3:"
curl -X POST http://localhost:8080/users \
  -H "Content-Type: application/json" \
  -d '{"name":"test2","email":"test2@gmail.com"}' | jq '.'

echo ""
echo ""

# 4. 사용자 목록 조회
echo "4. GET /users?limit=10 - List Users"
echo "---"
curl "http://localhost:8080/users?limit=10" | jq '.'

echo ""
echo ""

# 5. 존재하지 않는 사용자 조회 (404 테스트)
echo "5. GET /users/:id - User Not Found (404 Test)"
echo "---"
curl http://localhost:8080/users/user999 | jq '.'

echo ""
echo ""
echo "=========================================="
echo "REST Test Completed"
echo "=========================================="
