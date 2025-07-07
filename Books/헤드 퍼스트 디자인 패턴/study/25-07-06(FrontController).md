# Spring Framework와 디자인 패턴 TIL

## 1. FrontController 패턴과 DispatcherServlet

### FrontController 패턴이란?

**FrontController는 디자인 패턴**이며, 현대 웹 프레임워크에서는 **사실상 표준**이 되었습니다.

- **중앙 집중식 요청 처리**: 모든 클라이언트 요청을 하나의 컨트롤러가 받아서 적절한 핸들러에게 위임
- **관심사의 분리**: 공통 처리 로직(인증, 로깅 등)과 비즈니스 로직을 분리
- **설정이 아닌 패턴**: 반복되는 문제를 해결하는 아키텍처 설계 방법

### 과거 vs 현재

#### 과거 (개별 서블릿 방식)

### DispatcherServlet = FrontController 패턴의 Spring Framework 구현체

```java
// 각 기능마다 개별 서블릿 - 현재는 거의 사용하지 않음
public class LoginServlet extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response) {
    // 공통 로직을 각 서블릿마다 중복 작성
    authenticateUser(request);
    logRequest(request);
    // 로그인 로직
    }
}

public class UserServlet extends HttpServlet {
    protected void doGet(HttpServletRequest request, HttpServletResponse response) {
    // 또 다시 공통 로직 중복
    authenticateUser(request);
    logRequest(request);
    // 사용자 조회 로직
    }
}
```

#### 현재 (FrontController 기반 - 표준)

```java
// 하나의 진입점으로 모든 요청 처리
@RestController
public class UserController {
    @GetMapping("/users")
    public List<User> getUsers() { ... }

    @PostMapping("/users")
    public User createUser(@RequestBody User user) { ... }
}
// 모든 요청이 DispatcherServlet(FrontController)을 거쳐감
```

### FrontController 패턴이 현대 웹 개발의 표준인 이유

#### 1. 모든 주요 웹 프레임워크가 채택

```java
// Java 생태계
// Spring MVC: DispatcherServlet -> @Controller
// Struts: ActionServlet -> Action
// JSF: FacesServlet -> ManagedBean

// 다른 언어 프레임워크들도 동일
// Django (Python): 중앙 URL 라우팅
// Express.js (Node.js): app.use() 미들웨어
// ASP.NET Core (C#): Controller 기반 라우팅
```

#### 2. RESTful API의 대중화

```java
// REST API는 체계적인 URL 패턴 처리가 필요
// /api/users         GET    - 사용자 목록
// /api/users         POST   - 사용자 생성
// /api/users/{id}    GET    - 특정 사용자
// /api/users/{id}    PUT    - 사용자 수정

@RestController
@RequestMapping("/api/users")
public class UserController {
    @GetMapping
    public List<User> getUsers() { ... }

    @GetMapping("/{id}")
    public User getUser(@PathVariable Long id) { ... }
}
```

#### 3. 공통 관심사의 효율적 처리

```java
// FrontController에서 한 번에 처리 (현재 방식)
public class SecurityFilter implements Filter {
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain) {
        authenticateUser(request);   // 모든 요청에 대해 한 번만 구현
        authorizeRequest(request);
        logRequest(request);
        chain.doFilter(request, response);
    }
}

// 만약 개별 서블릿이라면 매번 중복 코드 작성 필요
```

#### 4. SPA (Single Page Application) 지원

```java
// 모든 프론트엔드 라우팅을 지원
@Controller
public class SpaController {
    @RequestMapping(value = "/{path:^(?!api).*}/**", method = RequestMethod.GET)
    public String forward() {
        return "forward:/index.html";  // React, Vue 등의 SPA로 포워딩
    }
}
```

**결론**: FrontController를 **사용하지 않는 것**이 오히려 특별한 경우입니다.

```java
// FrontController 패턴의 개념
public class FrontController extends HttpServlet {
    private Map<String, Handler> handlerMap = new HashMap<>();

    public void service(HttpServletRequest request, HttpServletResponse response) {
        String uri = request.getRequestURI();
        Handler handler = handlerMap.get(uri);  // 핸들러 선택
        handler.handleRequest(request, response);  // 위임
    }
}

// Spring의 DispatcherServlet (실제 구현)
public class DispatcherServlet extends FrameworkServlet {
    protected void doDispatch(HttpServletRequest request, HttpServletResponse response) {
        // 1. HandlerMapping을 통해 Handler 찾기
        HandlerExecutionChain mappedHandler = getHandler(request);

        // 2. HandlerAdapter 찾기
        HandlerAdapter ha = getHandlerAdapter(mappedHandler.getHandler());

        // 3. Handler 실행
        ModelAndView mv = ha.handle(request, response, mappedHandler.getHandler());

        // 4. ViewResolver를 통해 View 렌더링
        processDispatchResult(request, response, mappedHandler, mv);
    }
}
```

### 관계 정리

- **FrontController**: 디자인 패턴 (개념) - 현대 웹 개발의 표준
- **DispatcherServlet**: FrontController 패턴의 Spring Framework 구현체 (실제 코드)
- **Spring Framework vs Spring Boot**:
  - Spring Framework: 기본 기능들 (IoC, DI, MVC 등)
  - Spring Boot: Spring Framework를 더 쉽게 사용할 수 있게 해주는 **설정 자동화 도구**
  - 둘 다 같은 DispatcherServlet을 사용하지만, Boot는 자동 설정을 제공

```
Spring Ecosystem
├── Spring Framework (Core) - DispatcherServlet 포함
│   ├── Spring Core (IoC Container)
│   ├── Spring MVC
│   ├── Spring Data Access
│   └── Spring Web
├── Spring Boot (Spring Framework 사용 + 자동 설정)
├── Spring Security
├── Spring Data
└── Spring Cloud
```

## 2. 전략 패턴 (Strategy Pattern)

### 전략 패턴의 핵심: 컨텍스트가 런타임에 전략을 교체

**컨텍스트(Context)**: 전략을 소유하고 교체하는 주체 (런타임 인스턴스)

```java
// 컨텍스트: 전략을 소유하고 교체하는 주체
public class PaymentProcessor {  // 이것이 컨텍스트 (런타임 인스턴스)
    private PaymentStrategy currentStrategy;  // 현재 전략을 보유

    // 런타임에 전략을 교체하는 메서드
    public void changePaymentMethod(String type) {
        switch(type) {
            case "CARD":
                this.currentStrategy = new CardPaymentStrategy();  // 전략 교체
                break;
            case "CASH":
                this.currentStrategy = new CashPaymentStrategy();  // 전략 교체
                break;
        }
    }

    // 컨텍스트가 현재 전략에게 작업을 위임
    public void processPayment(double amount) {
        currentStrategy.pay(amount);  // 전략 실행
    }
}

// 사용 예시: 컨텍스트가 런타임에 전략을 교체
PaymentProcessor processor = new PaymentProcessor();  // 컨텍스트 인스턴스
processor.changePaymentMethod("CARD");  // 컨텍스트가 전략 교체
processor.processPayment(100.0);        // 카드 결제 실행
```

### Spring에서의 전략 패턴

#### 전략패턴에 해당하는 경우

```java
// ViewResolver 전략
public interface ViewResolver {
    View resolveViewName(String viewName, Locale locale);
}

// HandlerMapping 전략
public interface HandlerMapping {
    HandlerExecutionChain getHandler(HttpServletRequest request);
}

// 런타임에 파일 타입에 따라 전략 선택
@Component
public class FileProcessorContext {  // 컨텍스트
    private final Map<String, FileParser> parsers;

    public void processFile(String filename) {
        String extension = getExtension(filename);
        FileParser strategy = parsers.get(extension);  // 컨텍스트가 전략 선택
        strategy.parse(filename);  // 선택된 전략 실행
    }
}
```

#### 전략패턴이 아닌 경우 (단순 의존성 주입)

```java
@Service
public class UserService {
    private final UserRepository userRepository;  // 의존성 주입
    // 런타임에 알고리즘을 선택하는 것이 아니라, 단순 구현체 주입
}
```

### 전략패턴 판단 기준

1. **런타임에 알고리즘 선택**: ✓ 전략패턴
2. **컨텍스트가 전략을 교체**: ✓ 전략패턴
3. **단순 구현체 주입**: ✗ 의존성 주입 패턴

## 3. Null 체크와 Assert

### Assert의 특징

- **개발 시에만 실행**: `-ea` 옵션으로 활성화/비활성화 가능
- **프로덕션에서는 제거**: 성능 오버헤드 없음
- **개발자의 가정을 명시**: 코드의 의도를 명확하게 표현

```java
public class OrderService {

    // 일반적인 null 체크 (항상 실행)
    public void processOrder(Order order) {
        Objects.requireNonNull(order, "Order cannot be null");
        // 매번 null 체크 실행 (약간의 성능 오버헤드)
    }

    // Assert 사용 (개발시에만 실행)
    public void processOrderWithAssert(Order order) {
        assert order != null : "Order cannot be null";
        // 프로덕션에서는 이 체크가 완전히 제거됨 (성능 이점)
    }
}
```

### Assert 사용 시기

```java
// 1. 내부 메서드에서 전제 조건 확인
private void internalCalculation(double value) {
    assert value > 0 : "Value must be positive";
    // 내부 로직
}

// 2. 불변 조건 확인
public void withdraw(double amount) {
    balance -= amount;
    assert balance >= 0 : "Balance cannot be negative";
}

// 3. 복잡한 알고리즘의 중간 결과 검증
public void complexAlgorithm() {
    int result = step1();
    assert result > 0 : "Step1 result should be positive";
}
```

### 일반적인 null 체크 사용 시기

```java
// 1. 공개 API
public void publicMethod(String input) {
    Objects.requireNonNull(input, "Input cannot be null");
}

// 2. 프로덕션에서 반드시 체크해야 하는 경우
public void criticalOperation(User user) {
    if (user == null) {
        throw new IllegalArgumentException("User is required");
    }
}
```

## 4. Spring Container

### Spring Container = 객체의 생명주기를 관리하는 프레임워크 내부 시스템

```java
// 개발자가 직접 객체를 관리하는 방식 (일반적인 Java)
public void doSomething() {
    // 개발자가 직접 객체 생성
    UserRepository userRepository = new UserRepository();
    EmailService emailService = new EmailService();
    UserService userService = new UserService(userRepository, emailService);

    userService.createUser("John");

    // 개발자가 직접 정리
    userRepository = null;
}

// Spring Container가 객체를 관리하는 방식
@Service
public class UserService {
    @Autowired
    private UserRepository userRepository;  // Container가 주입

    @Autowired
    private EmailService emailService;      // Container가 주입

    // 개발자는 비즈니스 로직에만 집중
    public void createUser(String name) {
        // Container가 관리하는 객체들을 사용
    }
}
```

### Container가 하는 일

#### 1. 객체 생성 (Instantiation)

- `@Component`, `@Service`, `@Repository` 등이 붙은 클래스들을 스캔
- `@Bean` 메서드들을 실행하여 객체 생성

#### 2. 의존성 주입 (Dependency Injection)

- `@Autowired`, `@Qualifier`, `@Value` 등을 통해 필요한 객체들을 자동 연결

#### 3. 생명주기 관리 (Lifecycle Management)

```java
@Component
public class DatabaseConnection {

    @PostConstruct  // Container가 객체 생성 후 호출
    public void init() {
        System.out.println("데이터베이스 연결 초기화");
    }

    @PreDestroy  // Container가 객체 소멸 전 호출
    public void cleanup() {
        System.out.println("데이터베이스 연결 정리");
    }
}
```

### ApplicationContext = Spring Container의 구현체

```java
@SpringBootApplication
public class MyApplication {
    public static void main(String[] args) {
        // ApplicationContext가 Spring Container 역할
        ApplicationContext context = SpringApplication.run(MyApplication.class, args);

        // Container에서 Bean 가져오기
        UserService userService = context.getBean(UserService.class);
    }
}
```

## 5. Spring 어노테이션 정리

### @Bean의 의미

**@Bean = 메서드 레벨에서 객체 생성을 Spring에게 위임**

```java
@Configuration
public class AppConfig {

    @Bean  // 이 메서드가 반환하는 객체를 Spring Container가 관리
    public UserService userService() {
        return new UserService();  // 객체 생성 및 반환
    }

    @Bean
    public DataSource dataSource() {
        HikariDataSource dataSource = new HikariDataSource();
        dataSource.setUrl("jdbc:mysql://localhost:3306/mydb");
        return dataSource;  // 설정이 포함된 객체 반환
    }
}
```

### Bean 생성 관련 어노테이션

#### 클래스 레벨

```java
@Component  // 일반적인 Spring Bean
@Service    // 비즈니스 로직 계층
@Repository // 데이터 접근 계층
@Controller // 웹 컨트롤러 계층
@RestController // REST API 컨트롤러
```

#### 메서드 레벨

```java
@Bean  // 메서드가 반환하는 객체를 Bean으로 등록
```

### 의존성 주입 관련

```java
@Autowired  // 타입 기반 자동 주입
@Qualifier  // 특정 Bean 지정
@Value      // 프로퍼티 값 주입
@Resource   // 이름 기반 주입
```

### 어노테이션 사용 패턴

#### 자동 스캔 방식

```java
@Service  // Spring이 자동으로 찾아서 Bean으로 등록
public class MyService {
}
```

#### 수동 등록 방식

```java
@Configuration
public class AppConfig {
    @Bean
    public MyService myService() {
        return new MyService();  // 직접 생성해서 Bean으로 등록
    }
}
```

## 6. 핵심 정리

### Spring Framework의 설계 철학

1. **제어의 역전 (IoC)**: Container가 객체의 생명주기를 관리
2. **의존성 주입 (DI)**: 객체 간 결합도를 낮춤
3. **전략 패턴**: 다양한 구현체를 런타임에 선택 가능
4. **FrontController**: 중앙 집중식 요청 처리 (현대 웹 개발의 표준)

### 현대 웹 개발의 특징

- **FrontController 패턴**: 사실상 모든 웹 프레임워크의 기본 구조
- **Spring Boot**: Spring Framework의 설정을 자동화하는 도구
- **Container 관리**: 프레임워크가 객체 생명주기를 담당
- **디자인 패턴 활용**: 유연하고 확장 가능한 아키텍처 구현

### 개발자가 얻는 이점

- **비즈니스 로직에 집중**: 객체 관리와 공통 처리는 Framework가 담당
- **테스트 용이성**: Mock 객체 주입이 쉬움
- **유연성**: 설정만으로 구현체 교체 가능
- **확장성**: 새로운 기능 추가가 용이
- **표준화**: 업계 표준 패턴 사용으로 코드 가독성 향상

### 결론

Spring Framework는 다양한 디자인 패턴을 조합하여 **객체 지향적이고 유연한 애플리케이션 개발**을 가능하게 합니다. Container가 객체를 관리하고, 전략 패턴을 통해 다양한 구현체를 제공하며, FrontController를 통해 요청을 중앙에서 처리함으로써 개발자는 핵심 비즈니스 로직에만 집중할 수 있습니다. 특히 FrontController 패턴은 현대 웹 개발에서 표준이 되어, 사용하지 않는 것이 오히려 특별한 경우가 되었습니다.
