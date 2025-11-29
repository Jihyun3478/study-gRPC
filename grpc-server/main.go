package main

import (
	"context"
	"fmt"
	"log"
	"net"
	"sync"
	"time"

	pb "github.com/Jihyun3478/study-grpc/proto"
	"google.golang.org/grpc"
	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/status"
	"google.golang.org/grpc/reflection"
)

type server struct {
	pb.UnimplementedUserServiceServer
	mu sync.RWMutex
	users map[string]*pb.User
	idCounter int
}

func newServer() *server {
	return &server{
		users: make(map[string]*pb.User),
	}
}

func (server *server) CreateUser(ctx context.Context, request *pb.CreateUserRequest) (*pb.User, error) {
	// 1. Lock 획득
	server.mu.Lock()
	defer server.mu.Unlock()

	// 2. ID 생성
	server.idCounter++
	id := fmt.Sprintf("user%d", server.idCounter)

	// 3. User 객체 생성
	user := &pb.User{
		Id: id,
		Name: request.Name,
		Email: request.Email,
		CreatedAt: time.Now().Unix(),
	}

	// 4. map에 저장
	server.users[id] = user

	// 5. 반환
	return user, nil
}

func (server *server) GetUser(ctx context.Context, request *pb.GetUserRequest) (*pb.User, error) {
	// 1. 읽기 Lock
	server.mu.RLock()
	defer server.mu.RUnlock()

	// 2. map에서 조회
	user, exists := server.users[request.Id]

	// 3. 없으면 에러 반환
	if !exists {
		return nil, status.Errorf(codes.NotFound, "user not found: %s", request.Id)
	}

	// 4. 있으면 반환
	return user, nil
}

func (server *server) ListUsers(ctx context.Context, request *pb.ListUsersReqeust) (*pb.ListUsersResponse, error) {
	// 1. 읽기 Lock
	server.mu.RLock()
	defer server.mu.RUnlock()

	// 2. 빈 slice 생성
	users := make([]*pb.User, 0)
	count := 0

	// 3. map 순회
	for _, user := range server.users {
		if count >= int(request.Limit) {
			break
		}
		users = append(users, user)
		count++
	}

	// 4. Response 생성 후 반환
	return &pb.ListUsersResponse{
		Users: users,
	}, nil
}

func main() {
	// 1. TCP 리스너 생성 (포트 50051)
	listener, err := net.Listen("tcp", ":50052")
	if err != nil {
		log.Fatalf("failed to listen: %v", err)
	}

	// 2. gRPC 서버 생성
	server := grpc.NewServer()

	// 3. UserService 등록
	pb.RegisterUserServiceServer(server, newServer())
	reflection.Register(server)
	log.Printf("gRPC server listening at %v", listener.Addr())

	// 4. 서버 시작
	if err := server.Serve(listener); err != nil {
		// 5. 에러 로깅
		log.Fatalf("failed to serve: %v", err)
	}
}
