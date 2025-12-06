# gRPC vs REST API 성능 비교 학습
gRPC를 학습한 후, Rest를 사용한 경우와 성능 비교를 진행했습니다.

## 프로젝트 개요
- **목적**: gRPC와 REST API의 차이점 학습 및 비교
- **언어**: Go 1.25.4
- **기술 스택**: gRPC, Protocol Buffers, Gin

---

## 프로젝트 구조
```
.
├── proto/              # Protocol Buffers 정의
├── grpc-server/        # gRPC 서버
├── rest-server/        # REST API 서버
└── scripts/            # 테스트 스크립트
```

---

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

---

## API 명세
### gRPC API
- `CreateUser(CreateUserRequest) returns (User)`
- `GetUser(GetUserRequest) returns (User)`
- `ListUsers(ListUsersRequest) returns (ListUsersResponse)`

### REST API
- `POST /users` - 사용자 생성
- `GET /users/:id` - 사용자 조회
- `GET /users?limit=10` - 사용자 목록 조회

---

## 성능 비교 결과

### 테스트 환경
- **도구**: ghz (gRPC), wrk (REST)
- **조건**: 30초, 50 concurrent connections
- **환경**: 로컬 테스트, in-memory 저장소

### 성능 비교
| 엔드포인트 | REST 처리량 | gRPC 처리량 | REST 응답 | gRPC 응답 |
|-----------|------------|------------|----------|----------|
| CreateUser | 49,243 req/s | 42,798 req/s | 1.29ms | **0.77ms** |
| GetUser | 49,896 req/s | 39,643 req/s | 1.23ms | **0.84ms** |
| ListUsers(10) | 49,455 req/s | 34,036 req/s | 1.26ms | **1.06ms** |
| ListUsers(100) | 28,259 req/s | 13,165 req/s | 2.56ms | 3.18ms |
| ListUsers(1000) | 8,021 req/s | 1,993 req/s | 9.35ms | 22.40ms |

### 주요 결과

#### 소량 데이터: gRPC 우위
- **응답시간 40~60% 빠름**
- HTTP/2 프레임 처리, Protobuf 파싱 속도

#### 대량 데이터: 환경 영향
- 로컬 테스트에서는 REST가 높은 처리량
- 실제 네트워크 환경에서는 gRPC가 유리
  - Protobuf 압축: 67% 크기 감소
  - [KT Cloud 테스트](https://tech.ktcloud.com/253): gRPC가 2배 빠른 응답

### 결론
**gRPC를 사용해야 하는 경우**: 낮은 지연시간, 마이크로서비스 내부 통신, 스트리밍  
**REST를 사용해야 하는 경우**: 외부 API, 간단한 CRUD, 디버깅 용이성

> 벤치마크는 환경에 의존한다. 기술 선택은 실제 운영 환경과 요구사항을 고려해야 한다.

---

## 참고 자료
- [gRPC-Go 공식 문서](https://grpc.io/docs/languages/go/)
- [Protocol Buffers](https://protobuf.dev/)
- [REST에서 gRPC로: 차세대 API 통신 방식 도입기](https://tech.ktcloud.com/253)
- [gRPC의 내부 구조 파헤치기: HTTP/2, Protobuf 그리고 스트리밍](https://tech.ktcloud.com/253)
- [gRPC의 내부 구조 파헤치기: Channel & Stub](https://tech.ktcloud.com/253)
- [gRPC로 시작하는 API 개발: 첫 번째 서버와 클라이언트 구현](https://tech.ktcloud.com/253)
