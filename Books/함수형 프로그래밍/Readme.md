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
