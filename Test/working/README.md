## 테스트 코드 적용기

### React 컴포넌트 테스트의 핵심 원리와, 모킹을 통한 Props 검증

#### 모듈 모킹의 중요한 특성

React 컴포넌트 테스트에서 가장 중요한 발견은 **Jest의 모듈 모킹이 props 전달을 그대로 유지한다**는 점입니다. 이는 테스트에 매우 강력한 도구가 됩니다.

```javascript
// 원본 코드
import { SomeComponent } from "some-library";
function MyComponent() {
  return <SomeComponent prop1="value1" prop2={123} />;
}

// 테스트 코드
jest.mock("some-library", () => ({
  SomeComponent: (props) => {
    // 여기서 props는 {prop1: "value1", prop2: 123}
    return <div data-testid="mock-component" />;
  },
}));
```

이 특성 덕분에 복잡한 외부 컴포넌트를 단순한 함수로 대체하면서도, 테스트 중인 컴포넌트가 올바른 props를 전달하는지 검증할 수 있습니다.

#### 이번 테스트의 핵심 원리

##### 1. 컴포넌트 격리

테스트 코드에서는 `HdrAutomationLogAllView` 컴포넌트를 완전히 격리했습니다. 모든 외부 의존성(레이아웃, UI 컴포넌트, 상태 관리 등)을 간단한 모킹으로 대체했습니다. 이렇게 하면:

- 외부 의존성의 복잡성을 제거
- 테스트 환경에서 불필요한 렌더링 최소화
- 테스트 속도 향상

##### 2. 데이터 흐름 검증

뷰모델을 통한 데이터 흐름을 테스트했습니다:

```javascript
const viewModel = createMockViewModel({
  dataIsEmpty: false, // or true
  getHdrAutomationLogs: jest.fn(() => [{ id: 1 }]),
});
```

이렇게 뷰모델의 상태와 반환값을 조작함으로써, 컴포넌트가 다양한 데이터 상황에서 올바르게 반응하는지 검증할 수 있습니다.

##### 3. 조건부 렌더링 검증

데이터 유무에 따른 UI 변화를 검증했습니다:

```javascript
// 데이터가 있을 때
expect(screen.getByTestId("mock-table")).toBeInTheDocument();

// 데이터가 없을 때
expect(screen.getByTestId("mock-empty")).toBeInTheDocument();
expect(screen.queryByTestId("mock-table")).not.toBeInTheDocument();
```

#### 핵심 이점 및 활용법

##### Props 검증의 간편함

```javascript
// 레이아웃에 console.log 추가
jest.mock("레이아웃경로", () => ({
  DefaultAdminPageHeaderLayout: function MockLayout(props) {
    console.log(props); // 전달된 모든 props 확인 가능
    return <div>...</div>;
  },
}));
```

이 방식으로 컴포넌트가 다른 컴포넌트에 어떤 props를 전달하는지 쉽게 검증할 수 있습니다.

##### 더 발전된 테스트 방법

모킹된 함수에 테스트 로직을 추가할 수 있습니다:

```javascript
jest.mock("some-component", () => {
  const MockComponent = (props) => {
    // props 값 검증
    if (typeof props.onSomeEvent !== "function") {
      console.error("onSomeEvent must be a function");
    }
    return <div>Mock</div>;
  };
  return { SomeComponent: MockComponent };
});
```

##### 이벤트 핸들러 테스트 개선

이벤트 핸들러를 모킹 컴포넌트 내에서 직접 호출할 수도 있습니다:

```javascript
jest.mock("ui-lib", () => ({
  Button: (props) => (
    <button
      data-testid="mock-button"
      onClick={() => props.onClick && props.onClick()}
    >
      {props.children}
    </button>
  ),
}));
```

#### 실무적 추천사항

1. **선택적 모킹**: 필요한 컴포넌트만 모킹하고, 복잡한 로직이 없는 단순 UI 컴포넌트는 실제 구현을 사용해도 좋습니다.

2. **모킹 단순화**: 모킹된 컴포넌트는 필요한 최소한의 기능만 구현합니다.

3. **data-testid 활용**: 모킹된 컴포넌트에 `data-testid` 속성을 추가하여 테스트에서 쉽게 선택할 수 있게 합니다.

4. **props 검증 자동화**: 중요한 props에 대해서는 자동화된 검증 로직을 모킹 함수에 추가합니다.

이러한 원리와 기법을 활용하면, 외부 의존성이 많은 복잡한 React 컴포넌트도 효과적으로 테스트할 수 있습니다.

> viewModel과 view컴포넌트의 역할을 분리해, 각 코드의 테스트 코드를 따로 작성해보았다.
