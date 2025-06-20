# useRef를 useState로 구현하기 - TIL

## 🎯 핵심 개념

**useRef**의 본질을 이해하면 `useState`로 구현할 수 있다!

- `useRef`는 값을 저장하되 **리렌더링을 트리거하지 않는** Hook
- 핵심은 **객체 참조는 유지하되, 내부 속성만 변경**하는 것

## 📚 useState 기본 동작 이해

### useState가 반환하는 것

```javascript
// useState는 배열을 반환한다
const result = useState(0);
console.log(result); // [0, setState함수]

// 구조분해할당으로 받는 것
const [state, setState] = useState(0);
// state = 0 (배열의 첫 번째 요소)
// setState = 상태변경함수 (배열의 두 번째 요소)

// 두 번째 요소를 사용하지 않으면 생략 가능
const [state] = useState(0);
// state = 0
```

### useState의 객체 상태

```javascript
function ObjectStateExample() {
  const [obj, setObj] = useState({ current: 0 });

  console.log("obj:", obj); // { current: 0 }
  console.log("typeof obj:", typeof obj); // "object"

  return (
    <div>
      <p>현재 값: {obj.current}</p>
      <button
        onClick={() => {
          // 방법 1: 객체 내부 속성 직접 변경 (리렌더링 없음)
          obj.current += 1;
          console.log("값 변경됨:", obj.current);
          // 화면에는 반영되지 않음!
        }}
      >
        직접 변경 (리렌더링 없음)
      </button>

      <button
        onClick={() => {
          // 방법 2: 새로운 객체로 교체 (리렌더링 발생)
          setObj({ current: obj.current + 1 });
          // 화면에 반영됨!
        }}
      >
        setState로 변경 (리렌더링 발생)
      </button>
    </div>
  );
}
```

## 🔥 React 리렌더링 트리거 메커니즘

### 핵심 원리: 객체 참조 비교

React는 `Object.is()`를 사용해 **참조가 같은지** 비교한다:

```javascript
// React 내부 로직 (단순화)
function internalSetState(newState) {
  if (Object.is(currentState, newState)) {
    // 같은 참조 → 리렌더링 안함
    console.log("같은 참조, 리렌더링 안함");
    return;
  }

  // 다른 참조 → 리렌더링 스케줄링
  console.log("다른 참조, 리렌더링 스케줄링");
  scheduleRerender();
}
```

### 참조 vs 값 비교 예시

```javascript
function ReferenceVsValueExample() {
  const [obj, setObj] = useState({ current: 0 });

  const handleDirectChange = () => {
    // 메모리상의 값은 변경되지만 참조는 동일
    obj.current = 999;
    console.log("메모리 값:", obj.current); // 999

    // 같은 참조로 setState → 리렌더링 안됨
    setObj(obj);
    console.log("Object.is(obj, obj):", Object.is(obj, obj)); // true
  };

  const handleNewObjectChange = () => {
    // 새로운 객체 생성 → 다른 참조
    const newObj = { current: obj.current + 1 };
    setObj(newObj);
    console.log("Object.is(obj, newObj):", Object.is(obj, newObj)); // false
  };

  return (
    <div>
      <p>obj.current: {obj.current}</p>
      <button onClick={handleDirectChange}>
        직접 변경 후 같은 객체로 setState
      </button>
      <button onClick={handleNewObjectChange}>새로운 객체로 setState</button>
    </div>
  );
}
```

## 🔧 초기화 함수 (Initializer Function) 이해하기

### 초기화 함수란?

useState에 **함수를 전달**하면, 그 함수는 **첫 번째 렌더링에서만 실행**됩니다:

```javascript
// 방법 1: 직접 값 전달 (매 렌더링마다 평가됨)
const [state] = useState({ current: 0 });

// 방법 2: 초기화 함수 사용 (첫 렌더링에서만 실행)
const [state] = useState(() => ({ current: 0 }));
//                     ^^^^^^^^^^^^^^^^^^^^^^^^
//                     이것이 초기화 함수!
```

### 실행 시점 비교

```javascript
function InitializationDemo() {
  console.log("컴포넌트 함수 실행");

  // ❌ 매 렌더링마다 실행
  const [normalState] = useState(expensiveCalculation());
  console.log("일반 방식: 매번 계산 실행");

  // ✅ 첫 렌더링에서만 실행
  const [lazyState] = useState(() => {
    console.log("초기화 함수: 첫 렌더링에서만 실행");
    return expensiveCalculation();
  });

  function expensiveCalculation() {
    console.log("무거운 계산 중...");
    return { value: Math.random() };
  }

  const [count, setCount] = useState(0);

  return (
    <div>
      <p>일반 state: {normalState.value}</p>
      <p>초기화 함수 state: {lazyState.value}</p>
      <button onClick={() => setCount((prev) => prev + 1)}>
        리렌더링 ({count}) - 콘솔 확인!
      </button>
    </div>
  );
}
```

### 언제 초기화 함수를 사용하나?

```javascript
// 1. 복잡한 계산
const [state] = useState(() => heavyCalculation());

// 2. localStorage 접근
const [userData] = useState(() => {
  const saved = localStorage.getItem("user");
  return saved ? JSON.parse(saved) : {};
});

// 3. 객체/배열 생성 (메모리 최적화)
const [ref] = useState(() => ({ current: 0 }));

// 4. 현재 시간 등 매번 다른 값
const [timestamp] = useState(() => Date.now());
```

## 🛠️ useRef를 useState로 구현하기

### 기본 구현 (문제가 있는 버전)

```javascript
function useRefWithState(initialValue) {
  // ❌ 문제: 매 렌더링마다 새 객체 생성
  const [ref] = useState({ current: initialValue });
  // 메모리 낭비 + 예상과 다른 동작 가능

  return ref;
}
```

### 올바른 구현 (초기화 함수 사용)

```javascript
function useRefOptimized(initialValue) {
  // ✅ 올바름: 첫 렌더링에서만 객체 생성
  const [ref] = useState(() => ({ current: initialValue }));
  return ref;
}

// 사용 예시
function MyComponent() {
  const myRef = useRefOptimized(0);

  const handleClick = () => {
    // useRef처럼 사용
    myRef.current += 1;
    console.log("현재 값:", myRef.current);
    // 리렌더링 발생하지 않음!
  };

  return <button onClick={handleClick}>클릭</button>;
}
```

### 완전한 useRef 구현

```javascript
function useRefImplementation(initialValue) {
  const [refContainer] = useState(() => {
    console.log("ref 객체 생성 (한 번만)");
    return { current: initialValue };
  });
  return refContainer;
}

// 함수형 초기값 지원
function useRefWithFunction(initialValue) {
  const [ref] = useState(() => ({
    current: typeof initialValue === "function" ? initialValue() : initialValue,
  }));
  return ref;
}
```

## 🎯 useRef의 본질: 객체 생성과 속성 변경의 분리

### 핵심 메커니즘

useRef의 동작을 단계별로 분해하면:

1. **첫 렌더링**: 초기화 함수로 객체 한 번만 생성
2. **이후 렌더링**: 같은 객체 참조 유지
3. **값 변경**: 객체의 `current` 속성만 변경
4. **React 관점**: 객체 참조가 동일하므로 변경 감지 안됨
5. **결과**: 리렌더링 발생하지 않음

```javascript
function RefEssenceDemo() {
  // 실제 useRef
  const realRef = useRef(0);

  // useState로 구현한 useRef
  const [customRef] = useState(() => ({ current: 0 }));

  const [renderCount, setRenderCount] = useState(0);

  console.log("=== 렌더링 ===");
  console.log("realRef 객체:", realRef);
  console.log("customRef 객체:", customRef);
  console.log("두 객체가 같은가?", realRef === customRef); // false
  console.log("하지만 동작은 동일!");

  return (
    <div>
      <h3>렌더링 횟수: {renderCount}</h3>
      <p>realRef.current: {realRef.current}</p>
      <p>customRef.current: {customRef.current}</p>

      <button
        onClick={() => {
          // 핵심: 객체는 그대로, current 속성만 변경
          realRef.current += 1;
          customRef.current += 1;
          console.log("속성만 변경됨, 객체는 동일");
        }}
      >
        ref 값들 증가 (리렌더링 없음)
      </button>

      <button onClick={() => setRenderCount((prev) => prev + 1)}>
        강제 리렌더링
      </button>
    </div>
  );
}
```

### 메모리 관점에서 보는 동작

```javascript
function MemoryPerspective() {
  const [ref] = useState(() => {
    const obj = { current: 0 };
    console.log("객체 생성, 메모리 주소:", obj);
    return obj;
  });

  const showMemoryState = () => {
    console.log("=== 메모리 상태 ===");
    console.log("객체 참조:", ref); // 항상 동일
    console.log("current 값:", ref.current); // 변경됨
    console.log("객체는 동일, 속성만 변경됨");
  };

  return (
    <div>
      <p>ref.current: {ref.current}</p>

      <button
        onClick={() => {
          const oldValue = ref.current;
          ref.current += 1; // 같은 객체의 속성만 변경

          console.log(`${oldValue} → ${ref.current}`);
          console.log("객체 참조는 동일:", ref);
          showMemoryState();
        }}
      >
        ref 값 증가 (객체는 동일)
      </button>
    </div>
  );
}
```

### React가 보는 관점

```javascript
function ReactPerspective() {
  const [ref, setRef] = useState(() => ({ current: 0 }));

  return (
    <div>
      <p>ref.current: {ref.current}</p>

      <button
        onClick={() => {
          // React: "ref 상태는 변경되지 않음"
          // 이유: Object.is(ref, ref) === true
          ref.current += 1;
          console.log("React: 같은 객체 참조 → 변경 감지 안됨");
          console.log("실제: current 속성은 변경됨");
        }}
      >
        속성만 변경 (React는 모름)
      </button>

      <button
        onClick={() => {
          // React: "ref 상태가 변경됨"
          // 이유: Object.is(oldRef, newRef) === false
          setRef({ current: ref.current + 1 });
          console.log("React: 새로운 객체 → 변경 감지됨");
        }}
      >
        새 객체로 교체 (React가 감지)
      </button>
    </div>
  );
}
```

### 비유로 이해하기

```javascript
// 🏠 집(객체)은 그대로, 내부 가구(속성)만 바꾸기
const house = { furniture: "old" }; // 집 건설 (첫 렌더링)
house.furniture = "new"; // 가구 교체 (속성 변경)
// React: "같은 집이네? 변경 없음" 😴

// vs 🏗️ 새 집으로 이사
const newHouse = { furniture: "new" }; // 새 집 건설
// React: "다른 집이네? 변경됨!" 🚨
```

### 초기화 함수의 중요성

```javascript
function ObjectCreationComparison() {
  console.log("컴포넌트 함수 실행 시작");

  // ❌ 매번 새 객체 생성 (메모리 낭비)
  const [badRef] = useState({ current: 0, id: Math.random() });
  console.log("badRef 새 객체 ID:", badRef.id);

  // ✅ 첫 렌더링에서만 객체 생성
  const [goodRef] = useState(() => {
    const obj = { current: 0, id: Math.random() };
    console.log("goodRef 객체 생성, ID:", obj.id);
    return obj;
  });

  const [count, setCount] = useState(0);

  return (
    <div>
      <p>badRef ID: {badRef.id} (매번 바뀜)</p>
      <p>goodRef ID: {goodRef.id} (고정됨)</p>

      <button onClick={() => setCount((prev) => prev + 1)}>
        리렌더링 (콘솔 확인)
      </button>
    </div>
  );
}
```

## 🧪 실제 동작 비교 테스트

```javascript
function ComparisonTest() {
  const [normalState, setNormalState] = useState(0);
  const [refState] = useState({ current: 0 });
  const realRef = useRef(0);
  const [renderCount, setRenderCount] = useState(0);

  console.log(`컴포넌트 렌더링 - 횟수: ${renderCount}`);

  return (
    <div>
      <h3>렌더링 횟수: {renderCount}</h3>
      <p>일반 state: {normalState}</p>
      <p>refState.current: {refState.current}</p>
      <p>realRef.current: {realRef.current}</p>

      <button
        onClick={() => {
          setNormalState((prev) => prev + 1);
          console.log("일반 state 변경 → 리렌더링 발생");
        }}
      >
        일반 state 증가 (리렌더링 O)
      </button>

      <button
        onClick={() => {
          refState.current += 1;
          console.log("refState.current:", refState.current);
          console.log("리렌더링 발생하지 않음");
        }}
      >
        refState 증가 (리렌더링 X)
      </button>

      <button
        onClick={() => {
          realRef.current += 1;
          console.log("realRef.current:", realRef.current);
          console.log("리렌더링 발생하지 않음");
        }}
      >
        realRef 증가 (리렌더링 X)
      </button>

      <button onClick={() => setRenderCount((prev) => prev + 1)}>
        강제 리렌더링 (값 확인용)
      </button>
    </div>
  );
}
```

## 💡 심화 이해: 메모리 vs 화면 업데이트

```javascript
function MemoryVsUIExample() {
  const [obj, setObj] = useState({ current: 0 });
  const [forceUpdate, setForceUpdate] = useState(0);

  return (
    <div>
      <h3>메모리 vs UI 업데이트</h3>
      <p>화면에 표시되는 값: {obj.current}</p>
      <p>강제 업데이트 카운트: {forceUpdate}</p>

      <button
        onClick={() => {
          // 1단계: 메모리 값 변경
          obj.current += 1;
          console.log("메모리 값 변경됨:", obj.current);

          // 2단계: 하지만 화면은 업데이트 안됨
          console.log("화면에는 여전히 이전 값 표시");

          alert(`메모리 값: ${obj.current}, 화면 값: 이전값 그대로`);
        }}
      >
        메모리만 변경 (화면 업데이트 X)
      </button>

      <button
        onClick={() => {
          // 강제로 리렌더링하여 변경된 메모리 값 확인
          setForceUpdate((prev) => prev + 1);
          console.log("리렌더링 후 화면에 반영됨");
        }}
      >
        강제 리렌더링 (메모리 값 화면에 반영)
      </button>

      <button
        onClick={() => {
          // setState로 새 객체 전달 → 즉시 화면 업데이트
          setObj({ current: obj.current + 1 });
          console.log("새 객체로 교체 → 즉시 화면 업데이트");
        }}
      >
        새 객체로 교체 (즉시 화면 업데이트)
      </button>
    </div>
  );
}
```

## 🎯 실용적 활용 예시

### DOM 참조 용도

```javascript
function DOMRefExample() {
  const inputRef = useRefWithState(null);

  const focusInput = () => {
    if (inputRef.current) {
      inputRef.current.focus();
    }
  };

  return (
    <div>
      <input ref={inputRef} placeholder="포커스될 input" />
      <button onClick={focusInput}>포커스</button>
    </div>
  );
}
```

### 이전 값 저장 용도

```javascript
function PreviousValueExample() {
  const [count, setCount] = useState(0);
  const prevCountRef = useRefWithState(0);

  const updateCount = () => {
    prevCountRef.current = count; // 현재 값을 이전 값으로 저장
    setCount((prev) => prev + 1);
  };

  return (
    <div>
      <p>현재 값: {count}</p>
      <p>이전 값: {prevCountRef.current}</p>
      <button onClick={updateCount}>증가</button>
    </div>
  );
}
```

## 🔍 왜 이렇게 작동하는가?

### React의 설계 철학

1. **명시적 상태 관리**: 개발자가 `setState`를 호출할 때만 리렌더링
2. **성능 최적화**: 모든 메모리 변경을 감지하면 너무 무거움
3. **예측 가능성**: 언제 리렌더링이 발생하는지 예측 가능

### 핵심 포인트

```javascript
// 이것이 가능한 이유
const [ref] = useState({ current: 0 });

// 1. useState는 첫 렌더링에서만 초기값 설정
// 2. 이후 렌더링에서는 같은 객체 참조 유지
// 3. ref.current 변경은 객체 참조 변경이 아님
// 4. 따라서 React는 변경을 감지하지 못함
// 5. 결과: 리렌더링 발생하지 않음
```

## 📝 요약

### 핵심 개념들

1. **useState 반환값**: `[상태값, 상태변경함수]` 배열
2. **초기화 함수**: `() => value` 형태로 첫 렌더링에서만 실행
3. **리렌더링 트리거**: 객체 참조 변경 시에만 발생 (`Object.is()` 비교)
4. **useRef 구현 원리**:
   - 첫 렌더링에서만 객체 생성 (초기화 함수)
   - 객체 참조는 유지하되 내부 속성만 변경
   - React는 같은 참조이므로 변경 감지 못함

### 메모리 vs UI 동작

- **메모리 값 변경**: `obj.current = newValue` → 즉시 메모리에 반영
- **화면 업데이트**: `setState(newObject)` → React가 감지하여 리렌더링
- **useRef의 특징**: 메모리 변경 O, 화면 업데이트 X

### 실용적 활용

- **DOM 참조**: `<input ref={myRef} />`
- **이전 값 저장**: 리렌더링 없이 값 보관
- **타이머 ID 저장**: `setTimeout`, `setInterval` ID 보관
- **인스턴스 변수**: 클래스 컴포넌트의 인스턴스 변수와 유사

### 🎯 최종 정리

**useRef는 단순히 "리렌더링을 안 하는 useState"가 아니다!**

React의 **참조 기반 변경 감지 메커니즘**을 영리하게 활용한 패턴:

- **한 번 생성된 객체**의 **속성만 변경**하여
- **React의 변경 감지를 우회**하는 것

이를 이해하면 React의 동작 원리를 더 깊이 이해할 수 있고, 성능 최적화와 상태 관리에 대한 통찰을 얻을 수 있다! 🚀
