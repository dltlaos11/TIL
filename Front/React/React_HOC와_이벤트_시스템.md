# React HOC와 이벤트 시스템 정리

## 📋 목차

1. [forwardRef의 역할과 필요성](#1-forwardref의-역할과-필요성)
2. [onChange 강제 트리거 패턴](#2-onchange-강제-트리거-패턴)
3. [React Event System 심층 이해](#3-react-event-system-심층-이해)
4. [Event Pooling과 React 버전별 차이](#4-event-pooling과-react-버전별-차이)
5. [Portal과 이벤트 전파의 관계](#5-portal과-이벤트-전파의-관계)
6. [실전 인사이트와 베스트 프랙티스](#6-실전-인사이트와-베스트-프랙티스)

---

## 1. forwardRef의 역할과 필요성

### React의 ref 규칙

#### ❌ 함수 컴포넌트: ref 불가

```javascript
function Input(props) {
  return <input {...props} />;
}

<Input ref={inputRef} />; // Warning! Function components cannot be given refs
```

**이유**: 함수 컴포넌트는 인스턴스가 없어서 ref.current에 뭘 할당할지 모름

#### ✅ forwardRef: ref 전달 가능

```javascript
const Input = React.forwardRef((props, ref) => {
  return <input {...props} ref={ref} />
})

<Input ref={inputRef} />  // ✅ 정상 작동
inputRef.current.focus()  // ✅ DOM 접근 가능
```

### HOC에서 forwardRef의 필요성

#### forwardRef 없이

```javascript
const withAutoTrim = (Component) => {
  return (props) => {
    // 일반 함수
    return <Component {...props} onBlur={handleBlur} />;
  };
};

// 사용 시
<Input ref={inputRef} />;
// ❌ ref가 래퍼 컴포넌트에서 멈춤
// ❌ inputRef.current = null
```

#### forwardRef 사용

```javascript
const withAutoTrim = (Component) => {
  return React.forwardRef((props, ref) => {
    return <Component {...props} ref={ref} onBlur={handleBlur} />;
  });
};

// 사용 시
<Input ref={inputRef} />;
// ✅ ref가 실제 Input DOM으로 전달
// ✅ inputRef.current = <input> 엘리먼트
```

### ref 전달 흐름

```javascript
사용자 코드:
<Input ref={inputRef} />
     ↓
WithDirection HOC
     ↓
withAutoTrim HOC (forwardRef로 ref를 별도 인자로 받음)
React.forwardRef((props, ref) => {  // ref = inputRef (props와 분리)
     ↓
<StyledInput ref={ref} />  // ref 명시적 전달
     ↓
styled-components (자동 전달)
     ↓
AntInput (내부적으로 <input>에 연결)
     ↓
<input ref={inputRef} />  // 최종 DOM
     ↓
결과: inputRef.current = <input> DOM 엘리먼트 ✅
```

**핵심**:

- ref는 **일반 props에 포함되지 않음** (특수 prop)
- forwardRef는 ref를 **두 번째 인자로 명시적으로 전달**받음
- HOC 체인에서 ref를 잃어버리지 않고 최종 DOM까지 전달

### 현재 프로젝트 (React 16.13.1)의 구현

```javascript
const withAutoTrim = (Component) => {
  return React.forwardRef((props, ref) => {
    const handleBlur = (e) => {
      if (props.onBlur) {
        props.onBlur(e);
      }

      if (e.target.value && typeof e.target.value === "string") {
        const trimmedValue = e.target.value.trim();
        if (trimmedValue !== e.target.value) {
          if (props.onChange) {
            const syntheticEvent = {
              ...e,
              target: {
                ...e.target,
                value: trimmedValue,
              },
            };
            props.onChange(syntheticEvent);
          }
        }
      }
    };

    return <Component {...props} ref={ref} onBlur={handleBlur} />;
  });
};
```

### forwardRef를 사용하는 이유

**forwardRef는 HOC에서 필수는 아니지만, 베스트 프랙티스**

**이유**:

1. ✅ **미래 호환성**: 누군가 ref를 사용할 수 있음
2. ✅ **Ant Design 호환**: 내부적으로 ref 사용 가능
3. ✅ **라이브러리 표준**: UI 컴포넌트는 ref 지원이 원칙
4. ✅ **성능 오버헤드 없음**: forwardRef는 거의 비용 없음

### 💡 React 19 참고사항

React 19부터는 ref가 일반 prop처럼 동작하여 forwardRef가 불필요합니다:

```javascript
// React 19+
function Input({ ref, ...props }) {
  return <input {...props} ref={ref} />;
}
```

하지만 **현재 프로젝트는 React 16.13.1**이므로 forwardRef를 계속 사용해야 합니다. React 19로 업그레이드하더라도 기존 forwardRef 코드는 계속 작동합니다(호환성 유지).

---

## 2. onChange 강제 트리거 패턴

### Ant Design Form의 동작 원리

```javascript
// 사용자 코드 (아무것도 전달 안 함)
<FormItem name="businessName">
  <Input />
</FormItem>

// 실제로 FormItem이 Input에 주입하는 것
<Input
  value={form.getFieldValue('businessName')}  // ✅ FormItem이 주입
  onChange={(e) => {                          // ✅ FormItem이 주입
    form.setFieldValue('businessName', e.target.value)
  }}
  // onBlur는 기본적으로 주입 안 함
/>
```

### onChange를 "속이는" 기법

우리는 **trim된 값으로 onChange를 재호출**합니다:

```javascript
const handleBlur = (e) => {
  // 원본: "거래처명  "
  const trimmedValue = e.target.value.trim(); // "거래처명"

  // 새 이벤트 객체 생성 (값만 바꿈)
  const syntheticEvent = {
    ...e, // 기존 이벤트 속성 복사
    target: {
      ...e.target, // 기존 target 복사
      value: trimmedValue, // ✨ 값만 trim된 것으로 교체!
    },
  };

  // FormItem의 onChange 재호출
  props.onChange(syntheticEvent);

  // FormItem은 이렇게 받음:
  // onChange(e) {
  //   form.setFieldValue('businessName', e.target.value)
  //   // e.target.value = "거래처명" (trim됨!)
  // }
};
```

### 다른 방법과의 비교

```javascript
// ❌ 방법 1: DOM 직접 수정 (Form이 모름)
e.target.value = e.target.value.trim();
// Form 상태는 업데이트 안 됨!

// ❌ 방법 2: Form API 직접 호출 (form 인스턴스 필요)
form.setFieldValue("businessName", e.target.value.trim());
// form 인스턴스를 어떻게 가져오지? props에 없음!

// ✅ 방법 3: onChange 재호출 (우리의 방법)
const fakeEvent = { ...e, target: { ...e.target, value: trimmedValue } };
props.onChange(fakeEvent);
// FormItem이 알아서 form.setFieldValue 호출! ✅
```

### Props 전달 흐름

```javascript
// 사용자는 아무것도 전달 안 함
<Input />

// 하지만 HOC의 props에는:
props = {
  value: "거래처명  ",              // ✅ FormItem이 주입
  onChange: (e) => {...},          // ✅ FormItem이 주입
  // onBlur: undefined              // ❌ 없음
  // ref: undefined                 // ❌ 없음
}

// 우리가 추가하는 것:
return <Component
  {...props}              // value, onChange 전달
  ref={ref}               // undefined (문제없음)
  onBlur={handleBlur}     // ✨ 우리가 새로 추가!
/>
```

---

## 3. React Event System 심층 이해

### 네이티브 DOM vs React

#### 네이티브 DOM

```javascript
// blur: 버블링 안 됨 ❌
element.addEventListener("blur", handler);

// focusout: 버블링 됨 ✅
element.addEventListener("focusout", handler);
```

#### React

```javascript
// onBlur: 버블링 됨 ✅ (내부적으로 focusout 사용)
<div onBlur={handler}>
  <input />
</div>
// input blur 시 → 부모 div의 onBlur도 실행
```

- focusout = 버블링되는 blur(개념적으로는 blur지만)

### React 이벤트 위임 (Event Delegation)

#### React 16 이전

```javascript
// 모든 이벤트를 document에서 처리
document.addEventListener("focusout", (e) => {
  // React가 가상 DOM 트리를 따라 이벤트 전파
  dispatchEventForReactTree(e);
});
```

#### React 17+

```javascript
// 이벤트를 React 루트 컨테이너에서 처리
rootContainer.addEventListener("focusout", (e) => {
  // React 트리 기준으로 전파
  dispatchEventForReactTree(e);
});
```

### stopPropagation의 의미

```javascript
const handleBlur = (e) => {
  e.stopPropagation(); // React 트리에서 전파 차단
};

// ⚠️ 주의:
// - React SyntheticEvent 전파만 막음
// - DOM 트리 기준이 아니라 React 트리 기준!
// - Portal과 함께 사용 시 중요한 차이 발생
```

---

## 4. Event Pooling과 React 버전별 차이

### React 16 (프로젝트: 16.13.1)

#### Event Pooling 존재

```javascript
const handleBlur = (e) => {
  console.log(e.target.value); // ✅ "거래처명  " (동기: 정상)

  setTimeout(() => {
    console.log(e.target.value); // ❌ null (비동기: 풀링됨)
  }, 100);
};
```

**이유**: React가 이벤트 객체를 재사용하기 위해 핸들러 종료 후 필드를 null로 초기화

#### 해결 방법

```javascript
// 방법 1: 값 미리 추출
const value = e.target.value;
setTimeout(() => {
  console.log(value); // ✅ "거래처명  "
}, 100);

// 방법 2: e.persist() 사용
e.persist();
setTimeout(() => {
  console.log(e.target.value); // ✅ "거래처명  "
}, 100);

// 방법 3: 스프레드로 새 객체 생성
const event = { ...e, target: { ...e.target } };
setTimeout(() => {
  console.log(event.target.value); // ✅ "거래처명  "
}, 100);
```

### React 17+

#### Event Pooling 제거

```javascript
const handleBlur = (e) => {
  console.log(e.target.value); // ✅ "거래처명  "

  setTimeout(() => {
    console.log(e.target.value); // ✅ "거래처명  " (여전히 작동!)
  }, 100);

  // e.persist()  // ⚠️ Deprecated (불필요)
};
```

### 동기 코드에서는 React 16도 문제없음

```javascript
const handleBlur = (e) => {
  // ✅ 모든 작업이 동기적으로 완료됨
  const trimmedValue = e.target.value.trim(); // 즉시 실행

  const syntheticEvent = {
    ...e, // ✅ 즉시 스프레드 (handleBlur 실행 중)
    target: {
      ...e.target, // ✅ 즉시 스프레드 (handleBlur 실행 중)
      value: trimmedValue,
    },
  };
  // 새 객체 생성 완료 (Pooling 영향 없음)

  props.onChange(syntheticEvent); // ✅ 새 객체 전달

  // 비동기 작업 없음 → 문제 발생 안 함
};
```

### DevTools에서 이상하게 보이는 이유

```javascript
console.log(e, "e");
// 출력: SyntheticEvent {target: null}  ❌

console.log(e.target.value, "e.target.value");
// 출력: "거래처명  "  ✅
```

**원인**: Chrome DevTools의 Lazy Evaluation

```
T0: console.log(e) 실행 → 객체 참조만 저장 (나중에 펼침)
T1: handleBlur 종료
T2: React가 e.target = null로 초기화 (Pooling)
T3: 개발자가 콘솔에서 e 클릭 → null 표시 ❌

vs.

console.log(e.target.value) → 즉시 값 평가 → 정상 출력 ✅
```

---

## 5. Portal과 이벤트 전파의 관계

### Portal의 핵심 개념

> **Portal = DOM 위치만 바꾸고, React 트리는 그대로 유지**

### 두 개의 트리

```javascript
// React 트리 (논리 구조)
<App>
  <Layout>
    <Modal>  {/* React 부모-자식 관계 유지 */}
      <Button onClick={handleClick} />
    </Modal>
  </Layout>
</App>

// DOM 트리 (실제 렌더링)
<div id="root">
  <div class="layout"></div>
</div>
<div class="modal-root">  {/* Portal로 body에 렌더링 */}
  <button>클릭</button>
</div>
```

### Portal에서 이벤트가 동작하는 이유

```javascript
// 1. 브라우저가 DOM 이벤트 발생
button.click() → DOM 트리에서 버블링
     ↓
// 2. React 루트 컨테이너가 이벤트 감지
rootContainer.addEventListener('click', ...)
     ↓
// 3. React가 "자기 트리 기준"으로 재전파
React 트리: Button → Modal → Layout → App
     ↓
// 4. 결과
Layout의 onClick도 실행됨 ✅
```

**핵심**: DOM 위치와 관계없이 **React 트리 기준으로 이벤트가 전파**됨

### Ant Design Modal의 실제 동작

```javascript
// 사용자 코드
<Layout onBlur={handleLayoutBlur}>
  <Modal visible={true}>
    <Input onBlur={handleInputBlur} />
  </Modal>
</Layout>

// DOM 구조
<div id="root">
  <div class="layout"></div>  {/* Layout 렌더링 */}
</div>
<div class="ant-modal-root">  {/* Portal: body에 렌더링 */}
  <input />  {/* Input 렌더링 */}
</div>

// Input blur 발생 시:
// 1. handleInputBlur 실행 ✅
// 2. handleLayoutBlur 실행 ✅ (React 트리 기준 부모)
```

### stopPropagation과 Portal

```javascript
// Modal 안에서
<Input
  onBlur={(e) => {
    e.stopPropagation(); // React 트리에서 전파 차단
  }}
/>

// 결과:
// - Input의 onBlur만 실행
// - Layout의 onBlur는 실행 안 됨 (React 트리 기준)
// - DOM 위치는 상관없음!
```

### 왜 Modal은 Portal을 사용하는가?

```javascript
// ❌ Portal 없이 (일반 렌더링)
<div style={{ overflow: 'hidden', position: 'relative' }}>
  <Modal />  {/* overflow에 의해 잘림! */}
</div>

// ✅ Portal 사용
<div style={{ overflow: 'hidden' }}>
  {/* Modal은 body에 렌더링 → 잘림 없음 */}
  {createPortal(<Modal />, document.body)}
</div>
```

**이유**:

- z-index / stacking context 문제 회피
- overflow 잘림 방지
- 전체 화면 레이어에 적합

---

## 6. 실전 인사이트와 베스트 프랙티스

### 핵심 인사이트

#### 1. HOC는 "기능 추가"의 완벽한 패턴

```javascript
// 기존 코드 수정 없이
const Input = withAutoTrim(withValidation(withLogging(BaseInput)));

// 각 HOC가 독립적으로 기능 추가
// - withAutoTrim: blur 시 trim
// - withValidation: 유효성 검사
// - withLogging: 이벤트 로깅
```

#### 2. forwardRef는 "라이브러리 컴포넌트의 기본"

```javascript
// 라이브러리를 만든다면 항상 forwardRef 사용
const MyComponent = React.forwardRef((props, ref) => {
  // ref를 사용하지 않더라도 전달은 해줘야 함
  return <div {...props} ref={ref} />;
});
```

#### 3. onChange 재호출은 "Form과의 통신 수단"

```javascript
// Form 인스턴스 없이도 Form 상태 업데이트 가능
const fakeEvent = { ...e, target: { ...e.target, value: newValue } };
props.onChange(fakeEvent);
// → FormItem이 알아서 처리
```

#### 4. React 트리 ≠ DOM 트리 (Portal 때문)

```javascript
// 이벤트 전파는 React 트리 기준
// DOM 위치는 상관없음
// stopPropagation도 React 트리 기준
```

#### 5. Event Pooling은 "동기 코드에서는 무관"

```javascript
// 동기적으로 처리하면
// React 16에서도 Pooling 문제 없음
const value = e.target.value; // 즉시 추출
const newEvent = { ...e }; // 즉시 복사
```

### 베스트 프랙티스

#### ✅ DO

1. **HOC에는 항상 forwardRef 사용**

   ```javascript
   const withSomething = (Component) => {
     return React.forwardRef((props, ref) => {
       return <Component {...props} ref={ref} />;
     });
   };
   ```

2. **기존 이벤트 핸들러 유지**

   ```javascript
   const handleBlur = (e) => {
     if (props.onBlur) props.onBlur(e); // 기존 핸들러 먼저
     // 그 다음 우리 로직
   };
   ```

3. **동기적으로 이벤트 처리**

   ```javascript
   const handleEvent = (e) => {
     const value = e.target.value; // 즉시 추출
     // 모든 로직을 동기적으로
   };
   ```

4. **새 이벤트 객체는 스프레드로 생성**
   ```javascript
   const newEvent = {
     ...e,
     target: { ...e.target, value: newValue },
   };
   ```

#### ❌ DON'T

1. **이벤트 객체를 비동기로 사용**

   ```javascript
   setTimeout(() => {
     console.log(e.target.value); // ❌ React 16에서 null
   }, 100);
   ```

2. **HOC에서 ref 무시**

   ```javascript
   const withSomething = (Component) => {
     return (props) => {
       // ❌ ref 전달 안 됨
       return <Component {...props} />;
     };
   };
   ```

3. **Form 인스턴스에 직접 접근 시도**

   ```javascript
   form.setFieldValue(...)  // ❌ form을 어떻게 가져오지?
   // onChange 재호출로 해결!
   ```

4. **stopPropagation을 DOM 트리 기준으로 생각**
   ```javascript
   // ❌ Portal 안에서 stopPropagation하면
   // DOM 부모는 막히지 않지만
   // React 부모는 막힘!
   ```

---

## 🎯 최종 요약

### forwardRef의 핵심

> **HOC에서 ref를 하위 컴포넌트로 전달 = 완벽한 호환성 보장**

### onChange 재호출의 핵심

> **Form 인스턴스 없이도 Form 상태 업데이트 = 깔끔한 통신**

### React 이벤트의 핵심

> **React는 DOM 트리가 아닌 React 트리 기준으로 이벤트를 전파**

### Portal의 핵심

> **DOM 위치만 바꾸고 React 관계는 유지 = 이벤트도 React 트리 기준**

### Event Pooling의 핵심

> **동기 코드에서는 무관, 비동기에서만 주의 (React 17+는 걱정 없음)**

---

## 📚 참고 자료

- [React 17 Event Delegation Changes](https://reactjs.org/blog/2020/08/10/react-v17-rc.html#changes-to-event-delegation)
- [React Event Pooling (Deprecated in 17)](https://reactjs.org/docs/legacy-event-pooling.html)
- [React Portals](https://reactjs.org/docs/portals.html)
- [Forwarding Refs](https://reactjs.org/docs/forwarding-refs.html)
- [React 19 ref as prop](https://ko.react.dev/reference/react/forwardRef)
