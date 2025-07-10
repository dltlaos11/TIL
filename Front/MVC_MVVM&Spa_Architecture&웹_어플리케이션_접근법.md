# MVC vs MVVM, SPA 아키텍처, React vs Vue 비교, 리치 vs 씬 클라이언트(웹 어플리케이션 접근법)

## 1. MVC vs MVVM 차이점

### MVC (Model-View-Controller)

- **Controller**: View를 직접 조작하는 **수동 업데이트** 방식
- View와 Controller 간 **강한 결합**
- Controller가 View의 구체적인 메서드를 호출

```java
// MVC - Controller가 View를 직접 조작
public class DuckController {
    private DuckModel model;
    private DuckView view;

    public void makeQuack() {
        model.quack();
        view.refreshQuackCount();    // 수동 호출
        view.updateStatus("퀥!");    // 수동 호출
    }
}
```

### MVVM (Model-View-ViewModel)

- **ViewModel**: View와 **데이터 바인딩**으로 자동 연결
- View와 ViewModel 간 **느슨한 결합**
- ViewModel은 View를 전혀 모름

```javascript
// MVVM - 자동 바인딩
class DuckViewModel {
  constructor() {
    this.quackCount = observable(0);
    this.status = observable("");
  }

  makeQuack() {
    this.model.quack();
    this.quackCount.setValue(this.quackCount.getValue() + 1); // View 자동 업데이트
    this.status.setValue("퀥!"); // View 자동 업데이트
  }
}
```

### 핵심 차이점

- **테스트 용이성**: MVVM이 View 없이도 완전한 테스트 가능
- **결합도**: MVVM이 더 느슨한 결합 제공
- **유지보수성**: MVVM이 관심사 분리가 더 명확

## 2. MVVM이 SPA에 적합한 이유

### 전통적인 웹 vs SPA의 차이

#### 전통적인 웹 (MPA + SSR)

```javascript
// 전체 페이지 새로고침 방식
function addTodo() {
    fetch('/todos', { method: 'POST', ... })
        .then(() => window.location.reload()); // 전체 페이지 새로고침
}
```

#### SPA (Single Page Application)

```javascript
// 부분적인 UI 업데이트
function addTodo() {
  this.todos.push(newTodo); // 자동으로 관련 UI만 업데이트
}
```

### SPA에서 MVVM이 해결하는 문제들

#### 1. 실시간 UI 업데이트의 복잡성

```javascript
// MVC로 SPA 구현 시 - 매우 번거로움
class TodoController {
  addTodo(text) {
    this.model.addTodo(text);

    // 수동으로 모든 UI 업데이트 필요
    this.view.updateTodoList();
    this.view.updateTodoCount();
    this.view.updateProgress();
    this.view.updateFilterButtons();
    this.view.clearInput();
    // ... 더 많은 UI 업데이트들
  }
}

// MVVM으로 SPA 구현 - 자동 반응형 업데이트
export default {
  data() {
    return {
      todos: [],
      newTodoText: "",
    };
  },

  computed: {
    completedCount() {
      return this.todos.filter((todo) => todo.completed).length;
    },
    progress() {
      return this.todos.length
        ? (this.completedCount / this.todos.length) * 100
        : 0;
    },
  },

  methods: {
    addTodo() {
      this.todos.push({ text: this.newTodoText, completed: false });
      this.newTodoText = ""; // 자동으로 UI 클리어됨
      // 모든 관련 UI가 자동으로 업데이트!
    },
  },
};
```

#### 2. 단방향 데이터 바인딩 기반의 반응형 업데이트

- **React, Vue 모두 단방향 데이터 바인딩** 지원
- Data → View 방향으로만 자동 바인딩
- 양방향은 별도 구현 필요

```javascript
// React - 단방향 바인딩
const [count, setCount] = useState(0);
<div>{count}</div> // Data → View

// Vue - 단방향 바인딩
data() { return { count: 0 }; }
<div>{{ count }}</div> // Data → View

// 양방향은 수동 구현
<input
    value={text}
    onChange={(e) => setText(e.target.value)}
/>
```

##### AngularJS vs 현대 프레임워크의 차이점

**AngularJS - 양방향 데이터 바인딩**:

```javascript
// AngularJS는 진정한 양방향 바인딩 지원
function TodoController($scope) {
  $scope.name = "홍길동";
  // View에서 input 변경 → 자동으로 $scope.name 업데이트
  // $scope.name 변경 → 자동으로 View 업데이트
}
```

```html
<!-- 완전 자동 양방향 바인딩 -->
<input ng-model="name" />
<!-- 입력하면 $scope.name 자동 변경 -->
<p>Hello, {{name}}!</p>
<!-- $scope.name 변경되면 자동 표시 -->
```

**AngularJS의 패턴 분류**:

- **공식적으로는 "MVW" (Model-View-Whatever)**
- MVC라고 불리지만 실제로는 **MVVM에 더 가까움**
- 양방향 데이터 바인딩 = MVVM의 특징
- $scope = ViewModel 역할

```
AngularJS의 실제 구조:
View ↔ $scope (ViewModel) ↔ Service (Model)
     양방향 바인딩        의존성 주입
```

#### 3. 상태 관리의 복잡성 자동화

```javascript
// 복잡한 상태들이 자동으로 연쇄 업데이트
class ShoppingViewModel {
  constructor() {
    this.cart = observable([]);
    this.user = observable(null);
    this.filters = observable({ category: "all", priceRange: [0, 1000] });
  }

  // 계산된 속성들이 자동으로 연쇄 업데이트
  get filteredProducts() {
    return this.products.filter(/* 필터링 로직 */);
  }

  get cartTotal() {
    return this.cart.reduce((sum, item) => sum + item.price * item.quantity, 0);
  }
}
```

#### 4. 부드러운 사용자 경험

- **페이지 새로고침 없는** 즉각적인 인터랙션
- **부분 DOM 업데이트**로 효율적인 렌더링
- **실시간 반응성**으로 자연스러운 UI

## 3. React vs Vue 데이터 트리거 방식

### React: Virtual DOM + Fiber 방식

#### 작동 원리

```javascript
// React - 전체 컴포넌트 재렌더링 → Virtual DOM 비교
function TodoApp() {
  const [todos, setTodos] = useState([
    { id: 1, text: "공부하기", completed: false },
  ]);

  const toggleTodo = (id) => {
    setTodos(
      todos.map((todo) =>
        todo.id === id ? { ...todo, completed: !todo.completed } : todo
      )
    );
    // 🔄 setState 호출 → 전체 컴포넌트 재렌더링 → Virtual DOM 비교
  };
}
```

#### Fiber의 작업 분할

```javascript
// React Fiber - 시간을 나누어 처리
function workLoop(deadline) {
  while (nextUnitOfWork && deadline.timeRemaining() > 1) {
    nextUnitOfWork = performUnitOfWork(nextUnitOfWork);
  }

  if (nextUnitOfWork) {
    requestIdleCallback(workLoop); // 다음 프레임에서 계속
  }
}
```

#### ⚠️ 중요한 포인트: "재렌더링 ≠ DOM 업데이트"

```javascript
function ParentComponent() {
  const [count, setCount] = useState(0);

  // count가 변경되면 전체 컴포넌트 트리가 재렌더링되지만
  // Virtual DOM 비교로 실제 변경된 부분만 DOM 업데이트
  return (
    <div>
      <h1>{count}</h1> {/* 실제 DOM 업데이트 O */}
      <ChildComponent /> {/* 재렌더링 O, DOM 업데이트 X */}
    </div>
  );
}
```

### Vue: Proxy 기반 반응형 시스템

#### 작동 원리

```javascript
// Vue - 정확한 변경 감지 → 해당 컴포넌트만 업데이트
export default {
  data() {
    return {
      todos: reactive([{ id: 1, text: "공부하기", completed: false }]),
    };
  },

  methods: {
    toggleTodo(id) {
      const todo = this.todos.find((t) => t.id === id);
      todo.completed = !todo.completed;
      // 🎯 정확히 변경된 속성만 감지하여 해당 컴포넌트만 업데이트
    },
  },
};
```

#### Proxy의 정밀한 추적

```javascript
// Vue 3의 반응형 시스템
function reactive(obj) {
  return new Proxy(obj, {
    get(target, key, receiver) {
      track(target, key); // 의존성 수집
      return Reflect.get(target, key, receiver);
    },

    set(target, key, value, receiver) {
      const oldValue = target[key];
      const result = Reflect.set(target, key, value, receiver);

      if (oldValue !== value) {
        trigger(target, key); // 🎯 정확한 변경사항만 알림
      }

      return result;
    },
  });
}
```

### 성능 및 최적화 비교

#### React의 특징

**장점:**

- 예측 가능한 업데이트 흐름
- 시간 분할로 메인 스레드 블로킹 방지
- 복잡한 상태 변화도 안정적 처리

**단점:**

- 불필요한 재렌더링 발생 가능
- 메모이제이션 등 수동 최적화 필요

```javascript
// React - 수동 최적화 필요
const ChildC = React.memo(() => <div>변경되지 않는 컴포넌트</div>);
```

#### Vue의 특징

**장점:**

- 정밀한 업데이트로 높은 성능
- 자동 최적화 (수동 최적화 불필요)
- 직관적인 데이터 바인딩

**단점:**

- 복잡한 의존성 추적으로 디버깅 어려움
- 예상치 못한 반응형 동작 가능

```javascript
// Vue - 자동 최적화
<template>
  <div>
    <child-a :count="count" />  <!-- count 변경 시만 업데이트 -->
    <child-b :count="count" />  <!-- count 변경 시만 업데이트 -->
    <child-c />                 <!-- 자동으로 업데이트 안됨 -->
  </div>
</template>
```

## 5. Controller vs ViewModel 역할 비교

### 공통점: 둘 다 "조정자" 역할

```javascript
// 공통점: 애플리케이션 로직은 Model에 위임, 조정과 상태 관리에 집중

// MVC - Controller
class TodoController {
  addTodo(text) {
    this.model.addTodo(text); // 비즈니스 로직은 Model에
    this.view.refreshTodoList(); // View 조작만 담당
  }
}

// MVVM - ViewModel
class TodoViewModel {
  addTodo(text) {
    this.model.addTodo(text); // 비즈니스 로직은 Model에
    this.todos.push(this.model.getLastTodo()); // 상태만 동기화
  }
}
```

### 차이점: View와의 결합도

```javascript
// Controller - View를 직접 조작
class Controller {
  handleSubmit() {
    const result = this.model.process();
    this.view.showResult(result); // View 메서드 직접 호출
    this.view.hideLoading(); // View 구체적 동작 알고 있음
  }
}

// ViewModel - View를 모름
class ViewModel {
  constructor() {
    this.result = observable("");
    this.isLoading = observable(false);
  }

  handleSubmit() {
    this.isLoading.set(true);
    const result = this.model.process();
    this.result.set(result); // 상태만 변경, View는 자동 반응
    this.isLoading.set(false);
  }
}
```

## 6. 중재자 패턴 관점에서의 MVVM

### ✅ 올바른 MVVM 구조

```
View ↔ ViewModel ↔ Model
     (바인딩)    (동기화)
```

### 전통적인 MVC - 불완전한 중재자

```javascript
// View가 Model을 직접 참조 - 중재자 패턴 위반
class TodoView {
  constructor(model, controller) {
    this.model = model; // ❌ Model 직접 참조
    this.controller = controller;

    // Model 변경 직접 감지
    this.model.addEventListener("change", () => {
      this.render(); // ❌ Model과 직접 결합
    });
  }
}
```

### 완전한 MVVM - 완전한 중재자 패턴

```javascript
// Mediator를 통한 완전한 관심사 분리
class Mediator {
  constructor(model, viewModel) {
    this.model = model;
    this.viewModel = viewModel;
    this.setupSync();
  }

  setupSync() {
    // props 변화 → Model 동기화
    this.viewModel.on("propsChange", (newProps) => {
      this.model.updateFromProps(newProps);
      this.syncViewModelWithModel();
    });

    // Model 변화 → ViewModel 동기화
    this.model.on("change", () => {
      this.syncViewModelWithModel();
    });
  }
}

// View - Model을 전혀 모름
function TodoView({ viewModel }) {
  // ✅ ViewModel만 알고 있음, Model은 모름
  return (
    <div>
      {viewModel.todos.map((todo) => (
        <TodoItem key={todo.id} todo={todo} />
      ))}
    </div>
  );
}
```

## 7. 웹 애플리케이션 접근법 분류

### 전통적인 분류

```
웹 애플리케이션 접근법:
├── 씬 클라이언트 (Thin Client) = MPA + SSR
│   └── 서버에서 완성된 HTML 전송, 전체 페이지 새로고침
└── 리치 클라이언트 (Rich Client) = SPA + CSR
    └── 클라이언트에서 동적 렌더링, 부분 업데이트
```

### 현대적인 SSR - 하이브리드 접근법

```javascript
// Next.js - 서버와 클라이언트 하이브리드
export async function getServerSideProps() {
  // 서버에서 초기 데이터 렌더링
  return { props: { initialData } };
}

function Page({ initialData }) {
  const [data, setData] = useState(initialData);

  const fetchMore = async () => {
    // 새로고침 없이 서버에서 추가 데이터만 받아옴
    const newData = await fetch("/api/more-data");
    setData((prev) => [...prev, ...newData]);
  };

  return <div>...</div>; // 동적 상호작용 가능
}
```

**현대적인 SSR의 특징:**

- SSR + CSR 하이브리드
- 서버에서 초기 렌더링 + 클라이언트에서 동적 상호작용
- 새로고침 없이 필요한 부분만 서버에서 받아올 수 있음
- 전통적인 씬 클라이언트와는 다른 개념

## 정리

1. **MVVM**은 **데이터 바인딩**을 통한 자동 업데이트로 **SPA의 복잡한 상태 관리**를 효율적으로 해결
2. **React**는 Virtual DOM 비교 방식, **Vue**는 Proxy 기반 정밀 추적 방식 사용
3. **재렌더링과 DOM 업데이트는 다른 개념** - React에서 자주 오해되는 부분
4. **완전한 MVVM**은 중재자 패턴을 통해 View와 Model 간 완전한 분리 달성
5. **현대적 SSR**은 전통적인 씬 클라이언트와 달리 동적 상호작용이 가능한 하이브리드 방식
