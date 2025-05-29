# MobX + MVVM 패턴 구조 검토 및 개선 방향

## 1. MVVM 구조 적합성 평가

### 현재 구조

- **Model**: 데이터와 상태 관리 (`HdrAutomationLogModel`)
- **ViewModel**: Model을 감싸고, View에 필요한 데이터/로직 제공 (`HdrAutomationLogAllViewModel`)
- **View**: 실제 UI 렌더링 (`HdrAutomationLogAllView`)
- **Service Layer**: Apollo Client를 통한 GraphQL API 호출

### 장점

- View와 Model의 결합도가 낮아 유지보수 용이
- ViewModel에서 View에 필요한 데이터만 가공해서 전달 가능
- 테스트 용이성 확보
- **단방향 데이터 흐름**: View → ViewModel → Model → Service

## 2. Model에서 Observable 사용에 대한 검토

### 현재 방식

```javascript
class HdrAutomationLogModel {
  @observable hdrAutomationLogs = [];
  @observable pagination = {};
  @observable isLoading = false;
  @observable error = null;

  @action async fetchHdrAutomationLogs(pageable, filter) {
    // Service 호출을 통한 데이터 페칭
  }
}
```

### 장점

- **상태 중앙화**: 여러 ViewModel/컴포넌트에서 Model 공유 시 데이터 일관성 보장
- **MobX 활용**: Observable을 통한 자동 반응성 구현
- **실무 표준**: MobX 공식 예제 및 대규모 프로젝트에서 널리 사용되는 패턴

### 대안 (ViewModel에서 상태 관리)

```javascript
// Model: 순수 데이터/비즈니스 로직만
class HdrAutomationLogModel {
  async fetchHdrAutomationLogs(pageable, filter) {
    // Service 호출 및 데이터 반환만
    return await hdrAutomationLogService.fetch(pageable, filter);
  }
}

// ViewModel: 상태 관리 및 observable
class HdrAutomationLogAllViewModel {
  @observable hdrAutomationLogs = [];
  @observable isLoading = false;
  @observable error = null;

  constructor(model) {
    this.model = model;
  }

  @action async loadLogs(pageable, filter) {
    this.isLoading = true;
    try {
      const logs = await this.model.fetchHdrAutomationLogs(pageable, filter);
      this.hdrAutomationLogs = logs;
    } catch (e) {
      this.error = e;
    } finally {
      this.isLoading = false;
    }
  }
}
```

### 선택 기준

- **Model에 Observable**: 여러 ViewModel에서 공유하는 상태가 있을 때
- **ViewModel에 Observable**: Model이 순수 비즈니스 로직만 담당할 때, 상태 충돌 방지가 필요할 때

## 3. MobX vs Redux 모델 설계 비교

### MobX 모델 (현업에서 일반적)

```javascript
class UserModel {
  @observable user = {};
  @observable isLoading = false;
  @observable error = null;

  @action async fetchUser(id) {
    // 상태 + API 데이터를 함께 관리
  }
}
```

### Redux 모델

```javascript
// POJO만 store에 저장
const user = { id: 1, name: "홍길동" };
// 비동기 로직은 thunk/saga에서 별도 관리
```

### 핵심 차이점

- **MobX**: 상태 + API 데이터 관리 클래스가 표준
- **Redux**: POJO + 별도 미들웨어로 상태 관리 분리

## 4. TypeScript vs JavaScript 환경에서의 고려사항

### JavaScript 환경

- Interface 사용 불가 (타입 시스템 없음)
- 클래스 단독으로 모델 설계가 일반적
- 상속(extends)은 선택적 사용

### TypeScript 환경 (권장사항 추가)

```typescript
// 공통 인터페이스 정의
interface IBaseModel<T> {
  data: T[];
  isLoading: boolean;
  error: string | null;
  fetch(params?: any): Promise<void>;
  reset(): void;
}

// Generic을 활용한 재사용 가능한 모델
abstract class BaseListModel<T> implements IBaseModel<T> {
  @observable data: T[] = [];
  @observable isLoading = false;
  @observable error: string | null = null;

  @action reset() {
    this.data = [];
    this.error = null;
  }

  abstract fetch(params?: any): Promise<void>;
}

class HdrAutomationLogModel extends BaseListModel<HdrAutomationLog> {
  @action async fetch(params: FetchParams) {
    // 구현
  }
}
```

## 5. Next.js SSR 환경에서의 추가 고려사항

### 서버사이드 렌더링 대응

```javascript
// getInitialProps/getServerSideProps에서 Model에 데이터 주입
export async function getServerSideProps(context) {
  const model = new HdrAutomationLogModel();
  await model.fetchHdrAutomationLogs(initialParams);

  return {
    props: {
      initialData: toJS(model.hdrAutomationLogs), // MobX observable을 plain object로 변환
    },
  };
}
```

### 하이드레이션 이슈 방지

- 서버에서 받은 데이터를 클라이언트 Model에 올바르게 주입
- Observable 상태와 서버 데이터 간의 동기화 보장

## 6. 개선 방향 및 모범 사례

### 코드 품질 향상

1. **Model 크기 관리**: 너무 비대해지면 도메인별로 분리
2. **에러 처리 표준화**: 공통 에러 처리 로직 추상화
3. **테스트 용이성**: Mock 주입이 쉬운 구조 유지
4. **타입 안정성**: 가능하면 TypeScript 마이그레이션 고려

### 성능 최적화

```javascript
// computed를 활용한 파생 상태 관리
class HdrAutomationLogModel {
  @observable logs = [];
  @observable filter = {};

  @computed get filteredLogs() {
    return this.logs.filter(log =>
      // 필터링 로직
    );
  }
}
```

### 메모리 관리

```javascript
// 컴포넌트 언마운트 시 리액션 정리
class ViewModel {
  disposers = [];

  constructor() {
    this.disposers.push(reaction(() => this.model.data, this.handleDataChange));
  }

  dispose() {
    this.disposers.forEach((dispose) => dispose());
  }
}
```

## 결론

현재 구조는 **MobX + MVVM 패턴**에 매우 적합하며, 실무에서 널리 사용되는 표준적인 패턴입니다.

### 핵심 포인트

- Model에서 Observable 사용은 **현업 표준**
- fetch 함수가 Model에 있어도 **Service 분리**가 되어 있으면 적절
- JavaScript 환경에서는 **클래스 단독 설계**가 충분
- **팀 내 일관성**이 가장 중요한 기준

### 다음 단계 고려사항

- TypeScript 마이그레이션 시 인터페이스 설계
- 모델이 비대해질 경우 도메인별 분리
- 성능 최적화를 위한 computed, reaction 활용
