# MVC 구조 디자인 패턴과 서비스 분리 전략

## 📝 오늘 배운 것

백엔드 MVC 구조에서 사용되는 디자인 패턴들과 큰 서비스 파일을 효율적으로 관리하는 방법

## 🏗️ MVC 계층별 주요 패턴

### Controller 계층

- **Front Controller Pattern**: 모든 요청을 중앙 컨트롤러가 받아 라우팅 (Spring DispatcherServlet)
- **Command Pattern**: HTTP 요청을 Command 객체로 캡슐화하여 독립적 처리
- **Strategy Pattern**: 요청 처리 방식을 동적으로 선택 (인증, 응답 형식 등)

### Model 계층

- **Repository Pattern**: 데이터 접근 로직 캡슐화, 비즈니스 로직과 데이터 저장소 분리
- **Factory Pattern**: 복잡한 객체 생성 담당
- **Builder Pattern**: 복잡한 객체를 단계적으로 생성 (선택적 필드 처리)

### Service 계층

- **Facade Pattern**: 복잡한 서브시스템을 단순한 인터페이스로 제공
- **Template Method Pattern**: 알고리즘 골격 정의, 세부 구현은 서브클래스에 위임
- **Observer Pattern**: 상태 변화를 다른 객체들에게 알림 (이벤트 기반)

## 🔧 Service 파일 분리 전략

거대한 Service 파일을 관리하기 어려울 때 사용할 수 있는 패턴들:

### 1. Command Pattern

각 작업을 독립적인 Command 클래스로 분리

- **장점**: 완전한 독립성, 테스트 용이, 실행 취소 구현 가능
- **단점**: 클래스 수 증가
- **적합**: 복잡한 비즈니스 로직, 실행 취소 필요한 경우

### 2. Strategy Pattern

CRUD 작업을 독립적인 Strategy로 구현

- **장점**: 읽기/쓰기 로직 분리, 확장성 좋음
- **단점**: 여러 클래스 필요
- **적합**: 중간 규모 프로젝트

### 3. CQRS Pattern

읽기와 쓰기 작업 완전 분리

- **장점**: 최고의 확장성, 성능 최적화 가능
- **단점**: 구조 복잡
- **적합**: 대규모 시스템

### 4. 파일 분리 방식 (가장 실용적)

```typescript
// 파일별 분리
user.query.service.ts; // 조회 로직
user.command.service.ts; // 생성/수정/삭제 로직
user.service.ts; // 메인 서비스
```

## 📊 프로젝트 규모별 권장 패턴

| 규모       | 권장 패턴        | 특징                  |
| ---------- | ---------------- | --------------------- |
| **소규모** | 파일 분리        | 간단하고 직관적       |
| **중규모** | Strategy Pattern | 적당한 복잡도, 확장성 |
| **대규모** | CQRS + DDD       | 최고의 확장성과 성능  |

## 💡 핵심 인사이트

1. **점진적 개발**: 파일 분리로 시작해서 프로젝트 성장에 따라 복잡한 패턴 도입
2. **패턴 목적 이해**: 각 패턴의 목적과 적용 시점을 정확히 파악
3. **적절한 조합**: 프로젝트 요구사항에 맞게 패턴들을 조합하여 사용

## 🎯 다음 학습 계획

- [ ] TypeScript로 각 패턴 직접 구현해보기
- [ ] 실제 프로젝트에 파일 분리 패턴 적용
- [ ] CQRS 패턴의 Event Sourcing과의 결합 학습
- [ ] 쿠키 vs 세션 스토리지 비교 정리 (추가 학습 필요)

---

**Tags**: `#MVC` `#DesignPatterns` `#TypeScript` `#ServiceArchitecture` `#BackendDevelopment`
