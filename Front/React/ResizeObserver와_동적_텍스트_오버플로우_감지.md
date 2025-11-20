# ResizeObserver와 동적 텍스트 오버플로우 감지

## 📝 React에서 정적 조건 대신 실제 화면 오버플로우를 감지하는 방법

### 1. scrollWidth > clientWidth로 실제 오버플로우 감지

```javascript
// ❌ 기존: 정적 조건
const shouldShowTooltip = subject && subject.length > 80;

// ✅ 개선: 실제 화면 기준
const isOverflowing = element.scrollWidth > element.clientWidth + 2;
```

**핵심**: 문자 길이가 아닌 실제 렌더링된 크기로 판단해야 정확하다.

### 2. ResizeObserver로 동적 크기 변화 감지

```javascript
const resizeObserver = new ResizeObserver(checkOverflow);
resizeObserver.observe(element);
```

- 창 크기 조절, 동적 콘텐츠 변화 등을 자동 감지
- `window.resize`보다 효율적이고 정확함

### 3. React Hook으로 재사용 가능한 로직 구현

```javascript
const useTextOverflow = (text) => {
  const ref = useRef(null);
  const [isOverflowing, setIsOverflowing] = useState(false);

  const checkOverflow = useCallback(() => {
    if (ref.current) {
      setIsOverflowing(ref.current.scrollWidth > ref.current.clientWidth + 2);
    }
  }, []);

  useEffect(() => {
    const timer = setTimeout(checkOverflow, 10); // 초기 체크
    const resizeObserver = new ResizeObserver(checkOverflow); // 지속 감시

    if (ref.current) {
      resizeObserver.observe(ref.current);
    }

    return () => {
      clearTimeout(timer);
      resizeObserver.disconnect();
    };
  }, [checkOverflow]);

  return [ref, isOverflowing];
};
```

## 🔍 깊이 파본 개념들

### Web API Interface 이해

- ResizeObserver는 TypeScript Interface가 아닌 **Web API Interface**
- 생성자에서 콜백 함수를 받는 것이 Observer 패턴의 표준
- 브라우저가 제공하는 실제 구현체

### 실행 시점과 생명주기

```javascript
useEffect(() => {
  // 0ms: 함수들을 "등록"만 함 (실행 안 됨)
  const timer = setTimeout(checkOverflow, 10);
  const observer = new ResizeObserver(checkOverflow);

  // 10ms 후: 첫 번째 실행
  // 크기 변화 시: 추가 실행들
}, []);
```

## ⚡ 성능 최적화 포인트

### 1. 불필요한 래퍼 함수 제거

```javascript
// ❌ 비효율적
new ResizeObserver(() => checkOverflow());

// ✅ 효율적
new ResizeObserver(checkOverflow);
```

### 2. +2px 여유분으로 브라우저 차이 보정

```javascript
element.scrollWidth > element.clientWidth + 2;
```

### 3. 10ms 지연으로 DOM 렌더링 완료 보장

```javascript
setTimeout(checkOverflow, 10); // 0ms보다 안정적
```

## 🛠️ 실무 적용 방법

### 클래스 컴포넌트에서 Hook 사용

```javascript
// 함수형 컴포넌트로 분리
const SubjectCell = ({ subject, record }) => {
  const [textRef, shouldShowTooltip] = useTextOverflow(subject);
  return /* JSX */;
};

// 클래스 컴포넌트에서 사용
render: (subject, record) => <SubjectCell subject={subject} record={record} />;
```

## 🤔 헷갈렸던 부분들

### "ResizeObserver 인자에 함수 등록이 가능한가?"

- 가능하며 필수! Web API 공식 스펙

## 🎯 핵심 깨달음

**정적 조건보다 동적 조건이 사용자 경험에 더 정확하다**

- 브라우저별 폰트 렌더링 차이
- 사용자의 확대/축소 설정
- 동적으로 변하는 컨테이너 크기

이런 변수들 때문에 `length > 80` 같은 정적 조건은 부정확할 수밖에 없다.

## 📚 추가로 공부할 것

- [ ] IntersectionObserver, MutationObserver 등 다른 Observer API들
- [ ] ResizeObserver의 contentBoxSize vs borderBoxSize 차이
- [ ] 브라우저 렌더링 파이프라인과 최적화 기법

## 🔗 참고 자료

- [MDN ResizeObserver](https://developer.mozilla.org/en-US/docs/Web/API/ResizeObserver)
- [ResizeObserver 브라우저 지원 현황](https://caniuse.com/resizeobserver)

---

**Today's Key Learning**: 사용자 경험을 위해서는 코드가 실제 화면을 "보고" 판단해야 한다! 🎯
