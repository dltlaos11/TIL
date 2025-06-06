# TIL: 퍼사드 패턴 vs 프론트컨트롤러 패턴

## 📅 학습 날짜

2025년 6월 1일

## 🤔 궁금했던 점

복잡한 API 호출을 퍼사드로 단순화하는 것이 스프링 프레임워크의 FrontController와 비슷한 것 같은데 실제로 같은 패턴인가?

## 💡 핵심 깨달음

**서로 다른 차원의 패턴이다!** 둘 다 "복잡성을 숨기고 단순한 진입점 제공"이라는 공통점이 있지만, 해결하는 문제와 적용 레벨이 완전히 다르다.

## 📚 학습 내용

### 퍼사드 패턴 (Facade Pattern)

- **목적**: 복잡한 서브시스템을 단순한 인터페이스로 래핑
- **범위**: 클래스/모듈 레벨
- **해결 문제**: API 복잡성 은닉

```java
// 인터페이스를 통한 느슨한 결합 (더 나은 설계)
public class OrderFacade {
    private final UserService userService;
    private final InventoryService inventoryService;
    private final PaymentService paymentService;

    // 의존성 주입으로 테스트 용이성과 확장성 확보
    public OrderFacade(UserService userService,
                      InventoryService inventoryService,
                      PaymentService paymentService) {
        this.userService = userService;
        this.inventoryService = inventoryService;
        this.paymentService = paymentService;
    }

    public boolean placeOrder(String userId, String itemId, int quantity, double amount) {
        return userService.validate(userId) &&
               inventoryService.reserve(itemId, quantity) &&
               paymentService.process(userId, amount);
    }
}
```

### 프론트컨트롤러 패턴 (Front Controller Pattern)

- **목적**: 모든 요청을 중앙에서 받아 적절한 핸들러로 라우팅
- **범위**: 애플리케이션 레벨
- **해결 문제**: 웹 요청 처리의 중앙집중화

```java
// 모든 HTTP 요청의 단일 진입점
public class FrontControllerServlet extends HttpServlet {
    protected void service(HttpServletRequest request, HttpServletResponse response) {
        // 1. 요청 분석
        // 2. 인증/권한 확인 (공통 처리)
        // 3. 적절한 핸들러 찾기
        // 4. 핸들러에게 요청 위임
        // 5. 응답 후처리
    }
}
```

## 🆚 핵심 차이점

| 구분          | 퍼사드 패턴                   | 프론트컨트롤러 패턴              |
| ------------- | ----------------------------- | -------------------------------- |
| **목적**      | API 단순화                    | 요청 라우팅                      |
| **범위**      | 클래스/모듈 레벨              | 애플리케이션 레벨                |
| **처리 방식** | 여러 API 조합 → 하나의 메서드 | 요청 분석 → 적절한 핸들러로 분배 |
| **적용 예시** | `orderFacade.placeOrder()`    | `DispatcherServlet`              |

## 🔗 실제 조합 사례

**둘 다 함께 사용하는 경우가 많다:**

```java
@RestController
public class OrderController {  // ← 프론트컨트롤러가 이 컨트롤러로 라우팅

    @PostMapping("/orders")
    public ResponseEntity createOrder(@RequestBody OrderRequest request) {
        // 퍼사드 사용 ↓
        boolean result = orderFacade.placeOrder(
            request.getUserId(),
            request.getItemId(),
            request.getQuantity(),
            request.getAmount()
        );
        return ResponseEntity.ok(result);
    }
}
```

## 🌟 오늘의 핵심 인사이트

1. **SSR/CSR은 디자인 패턴을 구분 짓는 요소가 아니다**

   - SSR/CSR: 렌더링 방식 (언제, 어디서)
   - MVC/MVVM: 코드 구조화 방식 (어떻게)
   - 서로 독립적으로 선택 가능

2. **퍼사드의 `placeOrder` 메서드는 실제로 매우 복잡하다**

   - 6단계 순차 처리
   - 트랜잭션 관리 (실패 시 롤백)
   - 에러 처리 일원화
   - 클라이언트는 단순히 "주문하기"만 호출

3. **프론트컨트롤러의 핵심은 중앙집중식 처리**

   - 모든 요청의 단일 진입점
   - 공통 기능 (인증, 로깅, 에러처리) 한 곳에서 처리
   - URL 패턴에 따른 라우팅

4. **퍼사드 패턴에서도 SOLID 원칙이 중요하다**
   - 구체 클래스보다 인터페이스에 의존
   - 의존성 주입으로 테스트 용이성 확보
   - 퍼사드 패턴 ≠ 나쁜 설계, 올바른 구현이 중요

## 🎯 내일 더 알아보고 싶은 것

- Command 패턴과 프론트컨트롤러의 관계
- 마이크로서비스에서의 API Gateway vs 퍼사드 패턴
- Spring WebFlux에서의 라우팅 방식 차이점

## 📝 메모

- 패턴의 이름이 비슷하다고 같은 목적은 아니다
- 실제 프로젝트에서는 여러 패턴을 조합해서 사용한다
- "복잡성 숨기기"라는 공통점에 속지 말고 **해결하는 문제의 레벨**을 구분하자
- **퍼사드 패턴 != 의존성 하드코딩**, 인터페이스 기반 설계로 SOLID 원칙 준수 가능
