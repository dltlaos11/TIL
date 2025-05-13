# 함수형 프로그래밍

## 액션과 계산 데이터

> 함수형 프로그래밍에서는 액션, 계산, 데이터라는 세 가지 핵심 개념이 있으며, 이들 간의 관계와 선호도가 함수형 프로그래밍의 철학을 형성.
>
> - 카피-온-라이트(copy-on-write)는 데이터 변경 시 원본 데이터를 수정하지 않고 변경된 새 복사본을 생성하는 기법으로, 불변성(immutability)을 지원한다. 이는 `쓰기 작업을 읽기 작업`으로 변환하는 과정이라고 볼 수 있다.

> 데이터, 계산, 액션의 계층 구조:
>
> - 데이터(Data): 가장 단순하고 이해하기 쉬우며, 수학적 특성을 가짐
> - 계산(Calculation): 입력에서 출력으로의 순수 변환
> - 액션(Action): 부수 효과를 가질 수 있는 연산

> 선호도 계층:
>
> - 데이터 > 계산 > 액션 (데이터를 가장 선호)
> - 불변 데이터 구조는 추론하기 쉽고 병렬 처리에 안전함
> - 계산은 순수 함수로 구성되어 테스트와 추론이 용이함
> - s액션은 필요할 때만 제한적으로 사용

> 불변성의 중요성:
>
> - 불변 데이터를 통해 쓰기 작업을 읽기 작업으로 변환
> - 부수 효과를 최소화하여 프로그램의 예측 가능성 향상
> - 병렬 처리와 동시성 문제를 단순화

```js
// 쓰기 작업: 원본 데이터 직접 수정 (명령형 스타일)
function writeOperation(user) {
  user.age = user.age + 1; // 직접 수정 - 부수 효과 발생
  return user;
}

// 카피-온-라이트: 쓰기를 읽기로 변환 (함수형 스타일)
function copyOnWriteOperation(user) {
  // 원본을 읽기만 하고, 새 객체를 생성하여 반환
  return { ...user, age: user.age + 1 };
}

// 예시
const user = { name: "홍길동", age: 30 };

// 쓰기 작업 (원본 수정됨)
const updatedImperatively = writeOperation(user);
console.log("쓰기 작업 후 원본:", user); // { name: "홍길동", age: 31 } - 원본이 변경됨

// 원본 다시 초기화
const user2 = { name: "홍길동", age: 30 };

// 읽기 작업으로 변환 (원본 보존)
const updatedFunctionally = copyOnWriteOperation(user2);
console.log("카피-온-라이트 후 원본:", user2); // { name: "홍길동", age: 30 } - 원본 유지
console.log("카피-온-라이트 후 새 객체:", updatedFunctionally); // { name: "홍길동", age: 31 }
```

### 신뢰할 수 없는 코드를 쓰면서 불변성 지키기

> 외부에서 온 데이터나 공유 데이터가 예상치 못하게 변경되는 것을 방지하기 위한 기법

#### 방어적 복사의 개념

> 방어적 복사란 데이터의 무결성을 보호하기 위해 원본 데이터를 복사하여 독립적인 사본을 만들고, 이 사본으로 작업하는 기법입니다. 이렇게 하면 원본 데이터가 외부에서 변경되더라도 내부 로직은 영향을 받지 않습니다.

##### 실제 예시

###### 1. 생성자에서의 방어적 복사

```javascript
class UserProfile {
  constructor(userData) {
    // 외부에서 전달받은 데이터를 방어적으로 복사
    this.userData = JSON.parse(JSON.stringify(userData));
  }

  getUserData() {
    // 내부 데이터를 반환할 때도 복사본 반환
    return JSON.parse(JSON.stringify(this.userData));
  }
}

// 사용 예시
const originalData = { name: "김철수", settings: { theme: "dark" } };
const profile = new UserProfile(originalData);

// 원본 데이터가 변경되어도 UserProfile 내부 데이터는 안전
originalData.name = "이영희";
originalData.settings.theme = "light";

console.log(profile.getUserData()); // { name: '김철수', settings: { theme: 'dark' } }
```

###### 2. 리액트에서 props 처리

```javascript
function DataProcessor({ sourceData }) {
  // props로 받은 데이터를 방어적으로 복사해서 사용
  const [workingData, setWorkingData] = useState(() => {
    return JSON.parse(JSON.stringify(sourceData));
  });

  // 이제 workingData는 부모 컴포넌트의 sourceData 변경에 영향받지 않음
  function processData() {
    // 안전하게 데이터 처리 가능
    const processed = { ...workingData, processed: true };
    setWorkingData(processed);
  }

  return (
    <div>
      <button onClick={processData}>처리하기</button>
      <pre>{JSON.stringify(workingData, null, 2)}</pre>
    </div>
  );
}
```

###### 3. 공유 상태에서의 방어적 복사

```javascript
function useSharedDataManager() {
  const [sharedData, setSharedData] = useState({
    users: [
      { id: 1, name: "김철수" },
      { id: 2, name: "박영희" },
    ],
  });

  function getUsers() {
    // 외부로 데이터를 제공할 때 방어적 복사
    return [...sharedData.users];
  }

  function updateUser(id, newData) {
    // 업데이트 시에도 방어적 복사
    const usersCopy = [...sharedData.users];
    const index = usersCopy.findIndex((user) => user.id === id);

    if (index !== -1) {
      // 개별 객체도 복사
      usersCopy[index] = { ...usersCopy[index], ...newData };
      setSharedData({ ...sharedData, users: usersCopy });
    }
  }

  return { getUsers, updateUser };
}

// 사용 예시
function App() {
  const { getUsers, updateUser } = useSharedDataManager();

  function handleEdit() {
    const users = getUsers(); // 복사본을 받음
    users[0].name = "변경된 이름"; // 이 변경은 원본에 영향 없음

    // 공식적인 업데이트 방법 사용
    updateUser(1, { name: "올바르게 변경된 이름" });
  }

  // ...
}
```

###### 4. 외부 API 데이터 처리

```javascript
async function fetchUserData() {
  const response = await fetch("/api/users");
  const data = await response.json();

  // API 응답 데이터를 방어적으로 복사하여 저장
  return JSON.parse(JSON.stringify(data));
}

function UserManagement() {
  const [users, setUsers] = useState([]);

  useEffect(() => {
    async function loadData() {
      const userData = await fetchUserData();
      setUsers(userData);
    }
    loadData();
  }, []);

  // users 배열은 이제 외부 API 응답 변경에 영향받지 않는 "안전지대"에 있음
  // ...
}
```

#### 방어적 복사가 필요한 이유

1. **예측 불가능한 변경 방지**: 외부에서 데이터가 변경되어도 내부 로직은 안정적으로 동작
2. **사이드 이펙트 방지**: 한 곳의 변경이 다른 곳에 영향을 미치는 것을 방지
3. **불변성 보장**: 특히 리액트와 같은 프레임워크에서 불변성은 성능 최적화와 예측 가능한 상태 관리에 중요

방어적 복사는 특히 공유 데이터나 외부에서 온 데이터를 다룰 때 유용하며, 안전한 "자기 영역"을 만들어 독립적으로 데이터를 관리할 수 있게 해줍니다.

#### 함수형 프로그래밍의 계층형 설계 4가지 패턴

##### 1. 직접 설계 (Direct Implementation)

**핵심 개념**: 간단하고 직접적인 방식으로 문제를 해결합니다.

```javascript
// 직접 설계: 단어 수 계산 함수
function countWords(text) {
  return text.split(/\s+/).filter((word) => word.length > 0).length;
}

// 직접 설계: 문장 수 계산 함수
function countSentences(text) {
  return text.split(/[.!?]+/).filter((sentence) => sentence.trim().length > 0)
    .length;
}
```

**특징**:

- 함수가 하나의 명확한 목적을 가집니다
- 단순하고 이해하기 쉬운 구현입니다
- 특별한 추상화 없이 문제를 직접 해결합니다
- 코드의 의도가 명확히 드러납니다

##### 2. 추상화벽 (Abstraction Barrier)

**핵심 개념**: 내부 구현과 외부 인터페이스를 분리하여 캡슐화합니다.

```javascript
// 내부 구현 (추상화벽 아래)
const _textProcessor = {
  // 내부 데이터와 함수
  _text: "",
  _splitIntoWords: (text) =>
    text.split(/\s+/).filter((word) => word.length > 0),
  // ... 다른 내부 함수들 ...
};

// 추상화벽 (외부로 노출되는 API)
const TextAnalyzer = {
  loadText: (text) => {
    _textProcessor._text = text;
    return TextAnalyzer;
  },
  getWordCount: () =>
    _textProcessor._splitIntoWords(_textProcessor._text).length,
  // ... 다른 공개 API 함수들 ...
};
```

**특징**:

- 내부 구현(`_textProcessor`)은 외부에서 접근할 수 없습니다
- 외부에는 잘 정의된 API(`TextAnalyzer`)만 노출됩니다
- 내부 구현이 변경되어도 API가 유지되면 외부 코드는 영향받지 않습니다
- 데이터와 그 데이터를 조작하는 함수가 함께 캡슐화됩니다

##### 3. 작은 인터페이스 (Minimal Interface)

**핵심 개념**: 최소한의 핵심 연산만 제공하고, 나머지는 이를 조합해 구현합니다.

```javascript
// 최소한의 핵심 인터페이스
const TextStream = {
  // 단 두 개의 핵심 연산만 제공
  empty: () => "",
  append: (text1, text2) => text1 + text2,
  // 기본 판별 함수
  isEmpty: (text) => text.length === 0,
  length: (text) => text.length,
};

// 확장 기능은 핵심 인터페이스만 사용하여 구현
const TextStreamOps = {
  fromArray: (lines) =>
    lines.reduce(
      (acc, line) => TextStream.append(acc, TextStream.append(line, "\n")),
      TextStream.empty()
    ),
  // ... 다른 확장 함수들 ...
};
```

**특징**:

- 핵심 연산은 매우 적게 유지합니다(`empty`, `append`)
- 복잡한 기능은 모두 이 핵심 연산을 조합하여 구현합니다
- 새로운 기능 추가가 용이합니다
- 핵심 연산만 올바르게 구현하면 모든 확장 기능이 정확하게 작동합니다

##### 4. 편리한 계층 (Convenience Layer)

**핵심 개념**: 기본 기능 위에 자주 사용되는 고수준 기능을 추가합니다.

```javascript
// 기본 텍스트 처리 함수들 (핵심 계층)
const TextCore = {
  splitIntoWords: (text) => text.split(/\s+/).filter((word) => word.length > 0),
  // ... 다른 기본 함수들 ...
};

// 편리한 계층 - 자주 사용되는 고수준 함수들
const TextUtils = {
  getWordCount: (text) => TextCore.splitIntoWords(text).length,
  getLongestWord: (text) => {
    const words = TextCore.splitIntoWords(text);
    return words.reduce(
      (longest, word) => (word.length > longest.length ? word : longest),
      ""
    );
  },
  // ... 다른 편리한 함수들 ...
};
```

**특징**:

- 기본 함수(`TextCore`)를 재사용해 더 복잡하고 편리한 함수(`TextUtils`)를 제공합니다
- 사용자는 필요에 따라 적절한 추상화 수준을 선택할 수 있습니다
- 자주 사용되는 패턴이 재사용 가능한 함수로 구현됩니다
- 여러 기본 함수를 조합한 고수준 기능을 제공합니다

## 일급 추상

### 함수 본문을 콜백으로 바꾸기와 클로저의 관계

> 함수 본문을 콜백으로 바꾸는 리팩터링과 클로저의 관계를 이해하기 위한 예시를 정리해 보자

#### 기본 개념 설명

클로저(Closure)는 함수가 자신이 생성된 환경(렉시컬 환경)을 기억하고, 해당 환경의 변수들에 접근할 수 있는 능력을 말합니다. JavaScript에서 함수를 다른 함수의 인자로 전달할 때 클로저가 자주 활용됩니다.

#### 예시 1: 기본적인 함수 본문을 콜백으로 바꾸기

**변경 전:**

```javascript
function processUser() {
  try {
    const user = { id: 123, name: "John" };
    console.log("처리 중인 사용자:", user.name);
    // 사용자 데이터 처리 로직
  } catch (e) {
    console.error("에러 발생:", e);
  }
}

processUser();
```

**변경 후:**

```javascript
function withErrorHandling(callback) {
  try {
    callback();
  } catch (e) {
    console.error("에러 발생:", e);
  }
}

const user = { id: 123, name: "John" };
withErrorHandling(function () {
  console.log("처리 중인 사용자:", user.name);
  // 사용자 데이터 처리 로직
});
```

이 변경에서 클로저의 역할:

- 콜백 함수는 외부 스코프의 `user` 변수를 캡처합니다.
- 실제 실행은 `withErrorHandling` 함수 내부에서 이루어지지만, 외부에서 정의된 `user` 데이터에 접근 가능합니다.

#### 예시 2: 다양한 컨텍스트에서 재사용

```javascript
function withLogging(callback) {
  console.log("함수 실행 시작");
  try {
    const result = callback();
    console.log("함수 실행 완료");
    return result;
  } catch (e) {
    console.error("함수 실행 중 오류:", e);
    throw e;
  }
}

// 사용자 관련 작업
const userData = { name: "Alice", email: "alice@example.com" };
withLogging(function () {
  console.log(`${userData.name}의 정보 처리 중`);
  return userData.email;
});

// 계산 관련 작업
const numbers = [1, 2, 3, 4, 5];
withLogging(function () {
  const sum = numbers.reduce((a, b) => a + b, 0);
  console.log(`합계: ${sum}`);
  return sum;
});
```

여기서 클로저의 역할:

- 첫 번째 콜백은 `userData` 변수를 캡처합니다.
- 두 번째 콜백은 `numbers` 배열을 캡처합니다.
- 각 콜백은 자신이 생성된 환경의 변수에 접근하면서 `withLogging` 함수의 기능을 활용합니다.

#### 예시 3: 지연 실행과 상태 캡처

```javascript
function createValidator(validationFn) {
  return function (data) {
    console.log("데이터 검증 시작");
    const isValid = validationFn(data);
    if (isValid) {
      console.log("검증 성공");
    } else {
      console.log("검증 실패");
    }
    return isValid;
  };
}

// 이메일 검증 규칙
const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
const validateEmail = createValidator(function (email) {
  return emailRegex.test(email);
});

// 비밀번호 검증 규칙
const passwordRules = { minLength: 8, requireSpecialChar: true };
const validatePassword = createValidator(function (password) {
  const hasSpecialChar = /[!@#$%^&*(),.?":{}|<>]/.test(password);
  return (
    password.length >= passwordRules.minLength &&
    (!passwordRules.requireSpecialChar || hasSpecialChar)
  );
});

// 사용 예
validateEmail("user@example.com"); // true
validatePassword("pass123"); // false (너무 짧음)
validatePassword("SecurePass123!"); // true
```

이 예시에서 클로저의 역할:

- `validateEmail` 함수는 `emailRegex`를 캡처하는 클로저를 사용합니다.
- `validatePassword` 함수는 `passwordRules`를 캡처하는 클로저를 사용합니다.
- 각 검증 함수는 생성될 때의 환경을 기억하고 있다가, 실제로 호출될 때 해당 환경의 변수들을 사용합니다.

### 함수 본문을 콜백으로 바꾸기의 이점

1. **지연 실행**: <b>`함수 정의와 실행을 분리하여 필요한 시점에 실행할 수 있습니다.`</b>
2. **컨텍스트 공유**: 외부 변수를 캡처하여 다른 함수에 전달할 수 있습니다.
3. **관심사 분리**: 공통 로직(로깅, 에러 처리 등)과 특정 비즈니스 로직을 분리할 수 있습니다.
4. **재사용성**: 동일한 패턴을 다양한 함수에 적용할 수 있습니다.

클로저를 활용한 함수 본문을 콜백으로 바꾸기 패턴은 함수형 프로그래밍의 강력한 도구로, 코드의 유연성과 재사용성을 크게 향상시킵니다.

### 함수형 프로그래밍과 콜백 리팩터링 연결

'함수형 프로그래밍' 책의 '본문을 콜백으로 리팩터링하기' 부분과 `wrapLogging` 함수는 매우 밀접한 관련이 있습니다.

#### 콜백으로 리팩터링하기의 핵심 개념

함수형 프로그래밍에서 '본문을 콜백으로 리팩터링하기'는 다음과 같은 과정을 의미합니다:

1. 함수의 본문에서 변경되는 부분과 고정되는 부분을 구분합니다.
2. 변경되는 부분을 콜백 함수로 추출합니다.
3. 고정되는 부분을 고차 함수(Higher-Order Function)로 만듭니다.
4. 이 고차 함수는 콜백을 인자로 받고 새로운 함수를 반환합니다.

#### wrapLogging과의 연결점

`wrapLogging` 함수는 이 패턴의 완벽한 예시입니다:

```js
function wrapLogging(f) {
  return function (a1, a2, a3, a4, a5) {
    try {
      return f(a1, a2, a3, a4, a5);
    } catch (err) {
      logToSnapErrors(err);
    }
  };
}
```

여기서:

1. **고정되는 부분**: 함수 실행 시 에러 핸들링과 로깅하는 구조
2. **변경되는 부분**: 실제 실행될 함수 `f`
3. **고차 함수**: `wrapLogging`은 함수를 인자로 받고 새 함수를 반환하는 고차 함수
4. **클로저**: 반환된 함수는 `f`를 클로저를 통해 기억

#### 실제 사용 예시

```js
// 원래 함수
function calculateTotal(items) {
  return items.reduce((sum, item) => sum + item.price, 0);
}

// 로깅을 추가한 함수
const calculateTotalWithLogging = wrapLogging(calculateTotal);

// 사용
try {
  const total = calculateTotalWithLogging(shoppingCart);
  console.log(`총액: ${total}`);
} catch (e) {
  console.error("에러 발생했으나 이미 로깅됨");
}
```

#### 함수형 프로그래밍의 이점

이 접근법은 다음과 같은 함수형 프로그래밍의 이점을 제공합니다:

1. **관심사 분리**: 비즈니스 로직(`f`)과 인프라 로직(에러 처리/로깅)이 분리됨
2. **재사용성**: `wrapLogging`은 어떤 함수에도 적용 가능
3. **합성 가능성**: 여러 래퍼 함수를 조합하여 새로운 기능 구현 가능
4. **불변성**: 원본 함수 `f`는 변경되지 않고 새 함수가 생성됨

이것은 함수형 프로그래밍에서 매우 중요한 '데코레이터 패턴'의 한 예시이며, 부수 효과를 제한하고 코드의 테스트 용이성과 유지보수성을 향상시키는 기법입니다.

#### 데코레이터 패턴이란?

데코레이터 패턴은 기존 객체나 함수의 동작을 수정하거나 확장하기 위해 래퍼(wrapper)를 사용하는 디자인 패턴입니다. 원본 객체나 함수를 변경하지 않고 새로운 기능을 추가할 수 있습니다.

#### wrapLogging이 데코레이터인 이유

> - 기존 함수를 변경하지 않음: 원본 함수 f를 수정하지 않고 새로운 함수를 생성합니다.
> - 동일한 인터페이스 유지: 반환된 함수는 원본 함수와 같은 매개변수를 받고 같은 결과를 반환합니다. (에러가 없을 경우)
> - 기능 확장: 에러 로깅이라는 새로운 기능을 추가합니다.
> - 투명한 사용: 호출하는 코드는 원본 함수 대신 장식된(decorated) 함수를 사용할 때 변경이 필요 없습니다.

> - 전통적인 객체지향 데코레이터 패턴은 클래스와 상속을 사용하지만, 함수형 프로그래밍에서는 `고차 함수(Higher-Order Functions)와 클로저`를 활용하여 같은 패턴을 구현합니다.

두 접근법 모두 핵심 아이디어는 동일합니다:

1. 기존 코드를 수정하지 않고 기능을 확장한다 (개방-폐쇄 원칙)
2. 동일한 인터페이스를 유지한다
3. 런타임에 동적으로 기능을 추가할 수 있다

따라서 wrapLogging은 함수형 프로그래밍 스타일로 구현된 디자인 패턴의 데코레이터 패턴

#### 함수형 프로그래밍에서의 데코레이터

함수형 프로그래밍에서 데코레이터는 특히 유용합니다:

```js
// 다양한 데코레이터 함수들
const wrapLogging =
  (f) =>
  (...args) => {
    /* 로깅 로직 */
  };
const wrapTiming =
  (f) =>
  (...args) => {
    /* 시간 측정 로직 */
  };
const wrapCaching =
  (f) =>
  (...args) => {
    /* 캐싱 로직 */
  };

// 여러 데코레이터 조합
const enhancedFunction = wrapCaching(wrapTiming(wrapLogging(originalFunction)));
```

이러한 함수 합성을 통해 기능을 레이어처럼 쌓아올릴 수 있습니다.
따라서 wrapLogging은 함수형 프로그래밍에서 사용되는 데코레이터 패턴의 정확한 예시입니다.
