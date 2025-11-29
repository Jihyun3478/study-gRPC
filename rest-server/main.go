package main

import (
	"fmt"
	"log"
	"net/http"
	"strconv"
	"sync"
	"time"

	"github.com/gin-gonic/gin"
)

type User struct {
	ID string `json:"id"`
	Name string `json:"name"`
	Email string `json:"email"`
	CreatedAt int64 `json:"created_at"`
}

type CreateUserRequest struct {
	Name string `json:"name" binding:"required"`
	Email string `json:"email" binding:"required"`
}

type ListUsersResponse struct {
	Users []User `json:"users"`
}

type userStore struct {
	mu sync.RWMutex
	users map[string]User
	idCounter int
}

func newUserStore() *userStore {
	return &userStore{
		users: make(map[string]User),
	}
}

func (store *userStore) createUser(name, email string) User {
	// 1. Lock 획득
	store.mu.Lock()
	defer store.mu.Unlock()

	// 2. ID 생성
	store.idCounter++
	id := fmt.Sprintf("user%d", store.idCounter)

	// 3. User 객체 생성
	user := User{
		ID: id,
		Name: name,
		Email: email,
		CreatedAt: time.Now().Unix(),
	}

	// 4. map에 저장
	store.users[id] = user

	// 5. 반환
	return user
}

func (store *userStore) getUser(id string) (User, bool) {
	// 1. 읽기 Lock
	store.mu.RLock()
	defer store.mu.RUnlock()

	// 2. map에서 조회
	user, exists := store.users[id]

	// 3. 존재 여부와 함께 반환
	return user, exists
}

func (store *userStore) listUsers(limit int) []User {
	// 1. 읽기 Lock
	store.mu.RLock()
	defer store.mu.RUnlock()

	// 2. 빈 slice 생성
	users := make([]User, 0)
	count := 0

	// 3. map 순회
	for _, user := range store.users {
		if count >= limit {
			break
		}
		users = append(users, user)
		count++
	}

	// 4. slice로 반환
	return users
}

func main() {
	store := newUserStore()
	r := gin.Default()

	r.POST("/users", func(context *gin.Context) {
		var request CreateUserRequest

		// 1. 요청 바인딩
		if err := context.ShouldBindJSON(&request); err != nil {
			context.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		}

		// 2. createUser 호출
		user := store.createUser(request.Name, request.Email)

		// 3. JSON 응답
		context.JSON(http.StatusOK, user)
	})

	r.GET("/users/:id", func(context *gin.Context) {
		// 1. ID 파라미터 추출
		id := context.Param("id")

		// 2. getUser 호출
		user, exists := store.getUser(id)

		// 3. 없으면 404
		if !exists {
			context.JSON(http.StatusNotFound, gin.H{"error": "user not found"})
			return
		}

		// 4. 있으면 JSON 응답
		context.JSON(http.StatusOK, user)
	})

	r.GET("/users", func(context *gin.Context) {
		// 1. limit 쿼리 파라미터 추출
		limitQuery := context.DefaultQuery("limit", "10")
		limit, err := strconv.Atoi(limitQuery)
		if err != nil {
			limit = 10
		}

		// 2. listUsers 호출
		users := store.listUsers(limit)

		// 3. JSON 응답
		context.JSON(http.StatusOK, ListUsersResponse{Users: users})
	})

	log.Printf("REST server starting on :8080")
	if err := r.Run(":8080"); err != nil {
		log.Fatalf("Failed to start server: %v", err)
	}
}
