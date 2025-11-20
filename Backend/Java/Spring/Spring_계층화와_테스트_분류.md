## 📝 Spring 계층화와 테스트 분류

### **2. 🏗️ Spring 계층화 아키텍처**

**✅ 웹 계층 = Controller + 웹 관련 컴포넌트들**

```
┌─────────────────┐ ← @WebMvcTest (웹 계층만)
│  Presentation   │   Controller, Filter, Interceptor, Validator
│    (Web Layer)  │
├─────────────────┤
│    Business     │ ← @ExtendWith(MockitoExtension.class)
│  (Service Layer)│   순수 비즈니스 로직
├─────────────────┤
│   Persistence   │ ← @DataJpaTest (데이터 계층만)
│  (Data Layer)   │   Repository, JPA, Database
└─────────────────┘
```

**각 계층별 테스트:**

- **@WebMvcTest**: 웹 계층만 로딩, HTTP 요청/응답 테스트
- **@DataJpaTest**: 데이터 계층만 로딩, JPA 쿼리 테스트
- **@SpringBootTest**: 전체 통합 테스트

---

### **3. 🧪 테스트 분류 체계**

**✅ 단위/슬라이스/통합 테스트 구분이 핵심**

| 테스트 유형         | 어노테이션                            | Spring 컨텍스트 | 속도         | 용도      |
| ------------------- | ------------------------------------- | --------------- | ------------ | --------- |
| **단위 테스트**     | `@ExtendWith(MockitoExtension.class)` | ❌ 없음         | ⚡ 가장 빠름 | 순수 로직 |
| **슬라이스 테스트** | `@WebMvcTest`, `@DataJpaTest`         | 🔄 일부만       | ⚡ 빠름      | 특정 계층 |
| **통합 테스트**     | `@SpringBootTest`                     | ✅ 전체         | 🐌 느림      | E2E 검증  |

**단위 테스트 예시:**

```java
@ExtendWith(MockitoExtension.class) // 가장 많이 사용하는 조합
class UserServiceTest {
    @Mock private UserRepository userRepository;
    @InjectMocks private UserService userService; // 하나만 실제 객체
    // 나머지는 모두 Mock
}
```

---

### **4. 🎯 Spring 테스트 어노테이션 핵심**

**Web Layer 테스트:**

```java
@WebMvcTest(UserController.class)
@MockBean private UserService userService;
```

**Data Layer 테스트:**

```java
@DataJpaTest
@Autowired private TestEntityManager entityManager;
```

**Service Layer 테스트:**

```java
@ExtendWith(MockitoExtension.class)
@InjectMocks private UserService userService;
```

**Integration 테스트:**

```java
@SpringBootTest(webEnvironment = RANDOM_PORT)
@Autowired private TestRestTemplate restTemplate;
```

---

### **5. 🔍 @InjectMocks vs @Mock 동작 원리**

**✅ @InjectMocks는 하나의 실제 객체만 생성, 나머지는 Mock**

```java
@ExtendWith(MockitoExtension.class)
class OrderServiceTest {
    @Mock private OrderRepository orderRepository;    // 가짜 객체
    @Mock private PaymentService paymentService;      // 가짜 객체
    @Mock private EmailService emailService;          // 가짜 객체

    @InjectMocks private OrderService orderService;   // 실제 객체 (테스트 대상)

    // Mockito가 자동으로:
    // 1. Mock 객체들 생성
    // 2. OrderService 생성자에 Mock들 주입
    // 3. 실제 OrderService 인스턴스 생성
}
```

---

## 🚀 실무 적용 팁

### **테스트 피라미드 (70-20-10 비율)**

```
        🔺 Integration (10%)
       ──────────────────
      🔺🔺 Slice Tests (20%)
     ──────────────────────
    🔺🔺🔺 Unit Tests (70%)
   ──────────────────────────
```

### **언제 어떤 테스트를 사용할까?**

- **단위 테스트**: 복잡한 비즈니스 로직, 알고리즘
- **슬라이스 테스트**: Spring 특정 기능 (HTTP, JPA, JSON)
- **통합 테스트**: 중요한 비즈니스 시나리오, E2E 플로우

### **Mock vs Real 선택 기준**

- **@Mock**: 외부 의존성, 네트워크 호출, 복잡한 로직
- **@Spy**: 실제 객체지만 부분적으로 Mock 필요
- **실제 객체**: 단순한 데이터 클래스, 유틸리티
