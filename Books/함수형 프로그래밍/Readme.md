# 함수형 프로그램이

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
