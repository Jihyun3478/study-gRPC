#!/bin/bash

echo "=========================================="
echo "gRPC Server Test"
echo "=========================================="
echo ""

# 서버 실행 확인
if ! nc -z localhost 50052 2>/dev/null; then
    echo "Error: gRPC server is not running!"
    echo "Please run 'go run grpc-server/main.go' in another terminal first."
    exit 1
fi

echo "gRPC server connection verified"
echo ""

# 1. 사용자 생성
echo "1. CreateUser Test"
echo "---"
grpcurl -plaintext -d '{
  "name": "test",
  "email": "test@gmail.com"
}' localhost:50052 user.UserService/CreateUser

echo ""
echo ""

# 2. 사용자 조회
echo "2. GetUser Test"
echo "---"
grpcurl -plaintext -d '{
  "id": "user1"
}' localhost:50052 user.UserService/GetUser
# ↑ user_1 → user1 수정

echo ""
echo ""

# 3. 여러 사용자 생성
echo "3. Create Multiple Users"
echo "---"
echo "Creating user 2:"
grpcurl -plaintext -d '{"name":"test1","email":"test1@gmail.com"}' \
  localhost:50052 user.UserService/CreateUser

echo ""
echo "Creating user 3:"
grpcurl -plaintext -d '{"name":"test2","email":"test2@gmail.com"}' \
  localhost:50052 user.UserService/CreateUser

echo ""
echo ""

# 4. 사용자 목록 조회
echo "4. ListUsers Test (limit=10)"
echo "---"
grpcurl -plaintext -d '{
  "limit": 10
}' localhost:50052 user.UserService/ListUsers

echo ""
echo ""
echo "=========================================="
echo "gRPC Test Completed"
echo "=========================================="
