# gRPC vs REST API 성능 비교 학습
gRPC를 학습한 후, Rest를 사용한 경우와 성능 비교를 진행했습니다.

## 프로젝트 개요
- **목적**: gRPC와 REST API의 차이점 학습 및 비교
- **언어**: Go 1.25.4
- **기술 스택**: gRPC, Protocol Buffers, Gin

## 프로젝트 구조
```
.
├── proto/              # Protocol Buffers 정의
├── grpc-server/        # gRPC 서버
├── rest-server/        # REST API 서버
└── scripts/            # 테스트 스크립트
```

## 빠른 시작
### 1. 의존성 설치
```bash
go mod tidy
```

### 2. Protocol Buffers 코드 생성
```bash
protoc --go_out=. --go_opt=paths=source_relative \
    --go-grpc_out=. --go-grpc_opt=paths=source_relative \
    proto/user.proto
```

### 3. gRPC 서버 실행
```bash
go run grpc-server/main.go
```

### 4. REST 서버 실행 (다른 터미널)
```bash
go run rest-server/main.go
```

### 5. 테스트
```bash
# gRPC 테스트
chmod +x script/test-grpc.sh
./script/test-grpc.sh

# REST 테스트
chmod +x script/test-rest.sh
./script/test-rest.sh
```

## API 명세
### gRPC API
- `CreateUser(CreateUserRequest) returns (User)`
- `GetUser(GetUserRequest) returns (User)`
- `ListUsers(ListUsersRequest) returns (ListUsersResponse)`

### REST API
- `POST /users` - 사용자 생성
- `GET /users/:id` - 사용자 조회
- `GET /users?limit=10` - 사용자 목록 조회

## 참고 자료
- [gRPC-Go 공식 문서](https://grpc.io/docs/languages/go/)
- [Protocol Buffers](https://protobuf.dev/)
- [REST에서 gRPC로: 차세대 API 통신 방식 도입기](https://tech.ktcloud.com/253)
- [gRPC의 내부 구조 파헤치기: HTTP/2, Protobuf 그리고 스트리밍](https://tech.ktcloud.com/253)
- [gRPC의 내부 구조 파헤치기: Channel & Stub](https://tech.ktcloud.com/253)
- [gRPC로 시작하는 API 개발: 첫 번째 서버와 클라이언트 구현](https://tech.ktcloud.com/253)
