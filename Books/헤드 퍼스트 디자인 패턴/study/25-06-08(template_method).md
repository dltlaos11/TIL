# 템플릿 메서드 패턴과 Hook 개념 TIL

## 📚 오늘 학습한 내용

### 1. 템플릿 메서드 패턴과 React 라이프사이클의 연관성

**핵심 깨달음**: React의 라이프사이클이 템플릿 메서드 패턴과 매우 유사한 구조를 가지고 있다!

- **React 프레임워크**가 컴포넌트의 전체적인 생명주기 알고리즘을 정의
- **개발자**는 특정 시점(마운트, 업데이트, 언마운트)에서 실행될 구체적인 로직만 구현

```javascript
// 클래스 컴포넌트 예시
class MyComponent extends React.Component {
  componentDidMount() {
    // 마운트 시점
    // 개발자가 정의하는 구체적 로직
  }

  componentWillUnmount() {
    // 언마운트 시점
    // 개발자가 정의하는 구체적 로직
  }
}

// 함수형 컴포넌트 예시
function MyComponent() {
  useEffect(() => {
    // 마운트 시 실행
    return () => {
      // 언마운트 시 실행
    };
  }, []);
}
```

### 2. 템플릿 메서드 패턴의 다양한 구현 방식

**학습 포인트**: 템플릿 메서드는 상속뿐만 아니라 다양한 방식으로 구현 가능

#### 전통적 방식 (상속 기반)

```java
abstract class DataProcessor {
    public final void process() {  // 템플릿 메서드
        readData();
        processData();
        saveData();
    }

    protected abstract void readData();
    protected abstract void processData();
}
```

#### 현대적 방식 (콜백/인터페이스 기반)

```javascript
function useLifecycle(callbacks) {
  useEffect(() => {
    callbacks.onMount?.();
    return callbacks.onUnmount;
  }, []);
}
```

**핵심**: "큰 맥락(알고리즘의 골격)"을 프레임워크가 제어하는 것이 중요!

### 3. React: 라이브러리 vs 프레임워크

**흥미로운 발견**: React는 기술적으로는 라이브러리지만 실제로는 프레임워크적 특성을 보임

#### IoC (Inversion of Control) 관점

- React가 컴포넌트의 생명주기를 제어
- 개발자는 React가 정한 규칙과 타이밍을 따라야 함

#### DI (Dependency Injection) 관점

- Props를 통한 의존성 주입
- Context API를 통한 전역 의존성 주입
- Hooks를 통한 로직 주입

**결론**: React는 기술적으로는 라이브러리이지만, IoC 특성을 통해 프레임워크적 동작을 보임

### 4. 템플릿 메서드의 세분화 수준

**깨달음**: 관심사의 크기에 따라 다양한 레벨에서 적용 가능

- **큰 단위**: 애플리케이션 전체 라이프사이클
- **중간 단위**: 개별 컴포넌트 라이프사이클
- **작은 단위**: 특정 기능의 실행 흐름

```javascript
// 작은 단위 예시 - 데이터 fetching 패턴
const useApiCall = () => {
  setLoading(true); // 1. 로딩 시작
  fetchData() // 2. 데이터 요청
    .then(handleSuccess) // 3a. 성공 처리
    .catch(handleError) // 3b. 에러 처리
    .finally(() => setLoading(false)); // 4. 로딩 종료
};
```

### 5. Hook 개념의 광범위한 활용

**중요한 관찰**: "Hook"이라는 용어가 다양한 맥락에서 광범위하게 사용됨

- **React Hooks**: useState, useEffect, 커스텀 훅
- **Event Handlers**: onclick, onchange 등
- **Webhooks**: HTTP 콜백을 통한 이벤트 통지
- **Git Hooks**: 특정 Git 액션 시점에 실행되는 스크립트
- **OS Hooks**: 시스템 이벤트 감지 및 처리

**공통점**: 모두 "특정 시점에 사용자 정의 로직을 삽입할 수 있게 해주는 확장점" 역할

**Hook의 본질**: 원래 동작을 변경하지 않고도 새로운 기능을 추가할 수 있게 해주는 메커니즘

## 🤔 추가 탐구 필요한 부분

- Hook과 Observer 패턴의 구체적인 연관성 (React Hooks가 Observer 패턴 구현을 쉽게 만들어줌)
- 다른 프레임워크들(Vue, Angular, Spring 등)에서의 템플릿 메서드 패턴 적용 사례
- Hook과 다른 디자인 패턴(Strategy 등)과의 관계

## 💡 오늘의 핵심 인사이트

1. **템플릿 메서드 패턴**은 React 같은 현대 프레임워크의 핵심 아키텍처 원리
2. **제어의 역전(IoC)**이 프레임워크와 라이브러리를 구분하는 중요한 기준
3. **Hook**이라는 개념이 소프트웨어 개발 전반에서 확장성을 제공하는 핵심 메커니즘
4. 패턴의 **구현 방식**보다 **핵심 아이디어**가 더 중요함
