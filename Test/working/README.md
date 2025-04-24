# 테스트 코드 적용기

- [테스트 코드 적용기](#테스트-코드-적용기)
  - [React 컴포넌트 테스트의 핵심 원리와, 모킹을 통한 Props 검증](#react-컴포넌트-테스트의-핵심-원리와-모킹을-통한-props-검증)
  - [모듈 모킹의 중요한 특성](#모듈-모킹의-중요한-특성)
  - [이번 테스트의 핵심 원리](#이번-테스트의-핵심-원리)
    - [1. 컴포넌트 격리](#1-컴포넌트-격리)
    - [2. 데이터 흐름 검증](#2-데이터-흐름-검증)
    - [3. 조건부 렌더링 검증](#3-조건부-렌더링-검증)
  - [핵심 이점 및 활용법](#핵심-이점-및-활용법)
    - [Props 검증의 간편함](#props-검증의-간편함)
    - [더 발전된 테스트 방법](#더-발전된-테스트-방법)
    - [이벤트 핸들러 테스트 개선](#이벤트-핸들러-테스트-개선)
  - [실무적 추천사항](#실무적-추천사항)
  - [React 테스트 코드 작성 시 제약사항과 도구 선택](#react-테스트-코드-작성-시-제약사항과-도구-선택)
  - [Jest 모킹 환경의 제약사항](#jest-모킹-환경의-제약사항)
    - [왜 이런 제약이 있을까?](#왜-이런-제약이-있을까)
    - [해결 방법](#해결-방법)
  - [테스트 도구 선택: 유닛 vs 통합](#테스트-도구-선택-유닛-vs-통합)
    - [유닛 테스트 (Jest + React Testing Library)](#유닛-테스트-jest--react-testing-library)
    - [통합 테스트 (Cypress)](#통합-테스트-cypress)
  - [효과적인 테스트 전략](#효과적인-테스트-전략)
  - [jest.spyOn()을 활용한 모킹 전략](#jestspyon을-활용한-모킹-전략)
    - [jest.spyOn()의 장점](#jestspyon의-장점)
    - [사용 사례](#사용-사례)
  - [jest.mock(), jest.fn(), jest.spyOn()의 선택 가이드](#jestmock-jestfn-jestspyon의-선택-가이드)
    - [1. jest.mock() - 모듈 전체 모킹](#1-jestmock---모듈-전체-모킹)
    - [2. jest.fn() - 개별 함수 모킹](#2-jestfn---개별-함수-모킹)
    - [3. jest.spyOn() - 기존 객체의 메서드 감시](#3-jestspyon---기존-객체의-메서드-감시)
  - [실제 적용 사례](#실제-적용-사례)
    - [jest.mock()](#jestmock)
    - [jest.fn()](#jestfn)
    - [jest.spyOn()](#jestspyon)
  - [결론](#결론)

## React 컴포넌트 테스트의 핵심 원리와, 모킹을 통한 Props 검증

## 모듈 모킹의 중요한 특성

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

## 이번 테스트의 핵심 원리

### 1. 컴포넌트 격리

테스트 코드에서는 `HdrAutomationLogAllView` 컴포넌트를 완전히 격리했습니다. 모든 외부 의존성(레이아웃, UI 컴포넌트, 상태 관리 등)을 간단한 모킹으로 대체했습니다. 이렇게 하면:

- 외부 의존성의 복잡성을 제거
- 테스트 환경에서 불필요한 렌더링 최소화
- 테스트 속도 향상

### 2. 데이터 흐름 검증

뷰모델을 통한 데이터 흐름을 테스트했습니다:

```javascript
const viewModel = createMockViewModel({
  dataIsEmpty: false, // or true
  getHdrAutomationLogs: jest.fn(() => [{ id: 1 }]),
});
```

이렇게 뷰모델의 상태와 반환값을 조작함으로써, 컴포넌트가 다양한 데이터 상황에서 올바르게 반응하는지 검증할 수 있습니다.

### 3. 조건부 렌더링 검증

데이터 유무에 따른 UI 변화를 검증했습니다:

```javascript
// 데이터가 있을 때
expect(screen.getByTestId("mock-table")).toBeInTheDocument();

// 데이터가 없을 때
expect(screen.getByTestId("mock-empty")).toBeInTheDocument();
expect(screen.queryByTestId("mock-table")).not.toBeInTheDocument();
```

## 핵심 이점 및 활용법

### Props 검증의 간편함

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

### 더 발전된 테스트 방법

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

### 이벤트 핸들러 테스트 개선

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

## 실무적 추천사항

1. **선택적 모킹**: 필요한 컴포넌트만 모킹하고, 복잡한 로직이 없는 단순 UI 컴포넌트는 실제 구현을 사용해도 좋습니다.

2. **모킹 단순화**: 모킹된 컴포넌트는 필요한 최소한의 기능만 구현합니다.

3. **data-testid 활용**: 모킹된 컴포넌트에 `data-testid` 속성을 추가하여 테스트에서 쉽게 선택할 수 있게 합니다.

4. **props 검증 자동화**: 중요한 props에 대해서는 자동화된 검증 로직을 모킹 함수에 추가합니다.

이러한 원리와 기법을 활용하면, 외부 의존성이 많은 복잡한 React 컴포넌트도 효과적으로 테스트할 수 있습니다.

> viewModel과 view컴포넌트의 역할을 분리해, 각 코드의 테스트 코드를 따로 작성해보았다.

---

## React 테스트 코드 작성 시 제약사항과 도구 선택

오늘 React 컴포넌트 테스트 코드를 작성하면서 Jest의 모킹 환경에서 발생하는 특정 제약사항과 이를 해결하는 방법에 대해 배웠다. 또한 유닛 테스트와 통합 테스트에 적합한 도구 선택에 대해서도 고민해보았다.

## Jest 모킹 환경의 제약사항

Jest의 `jest.mock()` 함수는 특별한 방식으로 작동하는데, 이 함수 내부에서는 다음과 같은 외부 스코프 객체들에 접근할 수 없다:

- `React` 객체 (React.Children.map, React.cloneElement 등)
- `document` 객체 (document.querySelector 등)
- `window` 객체 (window.localStorage 등)

```javascript
// 이런 코드는 오류 발생
jest.mock("컴포넌트경로", () => ({
  MyComponent: () => {
    // 오류: React에 접근 불가
    return React.createElement("div", null, "Hello");
  },
}));

// 이것도 오류 발생
jest.mock("컴포넌트경로", () => ({
  MyComponent: () => {
    // 오류: window에 접근 불가
    if (window.innerWidth > 500) {
      return <div>Large screen</div>;
    }
    return <div>Small screen</div>;
  },
}));
```

### 왜 이런 제약이 있을까?

Jest는 모듈 모킹 코드를 파일의 최상단으로 호이스팅(hoisting)하고, 격리된 환경에서 실행한다. 이 때 외부 스코프 변수나 객체에 접근하는 것은 안전하지 않다고 판단하기 때문에 제한을 둔다. 이는 테스트의 안정성과 예측 가능성을 높이기 위한 설계적 결정이다.

### 해결 방법

1. **단순한 JSX 반환**

   ```javascript
   jest.mock("컴포넌트경로", () => ({
     MyComponent: (props) => <div>{props.children}</div>,
   }));
   ```

2. **require 사용 (필요한 경우)**

   ```javascript
   jest.mock("컴포넌트경로", () => {
     const React = require("react");
     return {
       MyComponent: (props) => React.createElement("div", null, props.children),
     };
   });
   ```

3. **모킹을 최소화하고, 실제 컴포넌트 사용 고려**

## 테스트 도구 선택: 유닛 vs 통합

### 유닛 테스트 (Jest + React Testing Library)

유닛 테스트는 개별 컴포넌트와 함수를 격리된 환경에서 테스트하는 데 적합하다.

**장점:**

- 빠른 실행 속도
- 격리된 테스트로 명확한 실패 원인 파악
- 개발 중 빠른 피드백 루프

**적합한 사용 사례:**

- 개별 컴포넌트의 렌더링
- 조건부 UI 확인
- 이벤트 핸들러 작동 확인
- 상태 관리 로직 검증

### 통합 테스트 (Cypress)

통합 테스트는 여러 컴포넌트 간의 상호작용과 전체 페이지 흐름을 테스트하는 데 적합하다.

**장점:**

- 실제 브라우저 환경에서 테스트
- 사용자 관점의 테스트
- 시각적 피드백과 디버깅

**적합한 사용 사례:**

- 페이지 간 이동
- 폼 제출 및 데이터 흐름
- API 통합
- 브라우저 이벤트 및 실제 환경 테스트

## 효과적인 테스트 전략

가장 효과적인 접근법은 두 도구를 적절히 조합하는 것이다:

1. **Jest + RTL**로 컴포넌트 유닛 테스트 (80%)

   - 비즈니스 로직
   - 상태 변화
   - 조건부 렌더링

2. **Cypress**로 중요한 사용자 흐름 테스트 (20%)
   - 로그인/회원가입
   - 결제 프로세스
   - 주요 기능 플로우

## jest.spyOn()을 활용한 모킹 전략

`jest.mock()` 외에도 `jest.spyOn()`은 테스트에서 자주 사용되는 중요한 모킹 방법이다.

```javascript
// window 객체의 메서드를 스파이하고 모킹
const alertSpy = jest.spyOn(window, "alert").mockImplementation(() => {});

// React 컴포넌트나 훅의 메서드를 스파이
const useSpy = jest.spyOn(React, "useState");

// 컴포넌트 인스턴스의 메서드를 스파이
const methodSpy = jest.spyOn(component.instance(), "handleClick");

// API 모듈의 함수를 스파이
const fetchSpy = jest
  .spyOn(apiModule, "fetchData")
  .mockResolvedValue({ data: "mocked" });
```

### jest.spyOn()의 장점

1. **원본 구현 유지**: 기본적으로 원래 구현을 유지하면서 호출만 추적한다.
2. **유연한 모킹**: `mockImplementation()`, `mockReturnValue()` 등으로 필요할 때만 동작을 변경할 수 있다.
3. **쉬운 복원**: `mockRestore()`로 원래 구현을 간단히 복원할 수 있다.
4. **외부 스코프 제약 없음**: `jest.mock()`과 달리 일반 테스트 코드 내에서 사용하므로 외부 스코프 변수 접근 제약이 없다.

### 사용 사례

- **이벤트 핸들러 테스트**: 컴포넌트의 이벤트 핸들러가 호출되는지 확인
- **사이드 이펙트 검증**: 특정 함수 호출 시 다른 함수가 호출되는지 확인
- **API 호출 모킹**: 네트워크 요청을 가로채고 모의 응답 반환
- **타이머 함수 제어**: setTimeout, setInterval 등을 모킹하여 시간 의존적 코드 테스트

## jest.mock(), jest.fn(), jest.spyOn()의 선택 가이드

React 테스트에서는 세 가지 방식의 모킹 도구를 상황에 맞게 선택해야 한다:

### 1. jest.mock() - 모듈 전체 모킹

**사용 시기:**

- 외부 모듈이나 컴포넌트 전체를 대체해야 할 때
- 의존성 그래프를 단순화하고 싶을 때
- 특정 모듈의 여러 내보내기를 한 번에 모킹할 때

**예시:**

```javascript
jest.mock("react-router-dom", () => ({
  ...jest.requireActual("react-router-dom"),
  useNavigate: () => mockNavigate,
}));

jest.mock("../../components", () => ({
  Button: (props) => (
    <button data-testid="mock-button">{props.children}</button>
  ),
}));
```

**주의사항:**

- 모듈 팩토리 내에서는 React, window, document 등 외부 스코프 변수 접근 불가
- 모든 파일에서 일관되게 적용됨

### 2. jest.fn() - 개별 함수 모킹

**사용 시기:**

- 단순한 함수나 콜백을 모킹할 때
- ViewModel이나 props로 전달되는 함수를 모킹할 때
- 특정 함수의 반환값을 제어해야 할 때

**예시:**

```javascript
const mockHandleClick = jest.fn();
render(<Button onClick={mockHandleClick} />);

// 호출 여부 검증
fireEvent.click(screen.getByRole("button"));
expect(mockHandleClick).toHaveBeenCalled();

// 반환값 설정
const mockGetData = jest.fn().mockReturnValue(["item1", "item2"]);
```

**특징:**

- 가장 단순하고 직관적인 모킹 방법
- 테스트 중에 동작을 변경하기 쉬움
- 호출 여부, 인자, 횟수 등을 쉽게 검증 가능

### 3. jest.spyOn() - 기존 객체의 메서드 감시

**사용 시기:**

- 기존 객체의 메서드 호출을 추적하고 싶을 때
- 원본 구현을 유지하면서 호출을 모니터링할 때
- 일시적으로만 메서드 동작을 변경하고 싶을 때
- 브라우저 API나 전역 객체의 메서드를 모킹할 때

**예시:**

```javascript
// API 호출 모킹
const fetchSpy = jest.spyOn(global, "fetch").mockResolvedValue({
  json: jest.fn().mockResolvedValue({ data: "mocked" }),
});

// 컴포넌트 메서드 감시
const methodSpy = jest.spyOn(component, "handleSubmit");
fireEvent.submit(form);
expect(methodSpy).toHaveBeenCalled();

// 테스트 종료 후 복원
fetchSpy.mockRestore();
```

**특징:**

- jest.mock()과 달리 외부 스코프 변수에 접근 가능
- 원본 구현을 유지하거나 필요에 따라 오버라이드 가능
- mockRestore()로 원래 구현으로 쉽게 되돌릴 수 있음

## 실제 적용 사례

### jest.mock()

```javascript
// UI 컴포넌트 라이브러리 모킹
jest.mock("@mui/material", () => ({
  Button: (props) => <button data-testid="mui-button">{props.children}</button>,
  TextField: (props) => (
    <input
      data-testid="mui-input"
      value={props.value}
      onChange={props.onChange}
    />
  ),
}));
```

### jest.fn()

```javascript
// ViewModel 함수 모킹
const mockViewModel = {
  fetchData: jest.fn(),
  updateItem: jest.fn(),
  isLoading: jest.fn(() => false),
};

// 콜백 함수 검증
const onChangeMock = jest.fn();
render(<Input onChange={onChangeMock} />);
fireEvent.change(screen.getByRole("textbox"), {
  target: { value: "new value" },
});
expect(onChangeMock).toHaveBeenCalledWith("new value");
```

### jest.spyOn()

```javascript
// window.matchMedia 모킹 (브라우저 API)
beforeAll(() => {
  jest.spyOn(window, "matchMedia").mockImplementation((query) => ({
    matches: false,
    media: query,
    onchange: null,
    addEventListener: jest.fn(),
    removeEventListener: jest.fn(),
  }));
});

// API 요청 모킹
const apiSpy = jest.spyOn(apiService, "getUsers").mockResolvedValue([
  { id: 1, name: "User 1" },
  { id: 2, name: "User 2" },
]);

// 테스트 후 복원
afterAll(() => {
  apiSpy.mockRestore();
});
```

## 결론

테스트 코드 작성 시 각 모킹 도구(jest.mock(), jest.fn(), jest.spyOn())의 특성과 제약사항을 이해하고 적절하게 조합하여 사용하는 것이 중요하다. 테스트의 목적과 대상 컴포넌트의 특성을 고려하여 가장 적합한 모킹 전략을 선택해야 한다.

테스트 코드도 결국 코드이므로, 복잡성을 관리하고 명확한 의도를 가진 코드를 작성하는 것이 유지보수에 도움이 된다. 특히 모킹은 필요한 최소한으로 유지하고, 테스트의 목적에 초점을 맞추는 것이 좋다.
