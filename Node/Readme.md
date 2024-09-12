# Node.js

### 노드의 정의

> 공식 홈페이지의 설명

- `Node.js`는 크롬 `V8` 자바스크립트 엔진으로 빌드된 자바스크립트 런타임(실행기)
  - 과거에 브라우저에 `js(스크립트)`를 읽는데 `html`에 종속되어 있었다
  - 노드가 나옴으로 인해 `js`는 `html`이나 브라우저의 종속성에서 벗어남(`V8` 자바스크립트 엔진이 해석)
  - 물론 노드 이전에 `라이노(Rhino)` 등 여러가지가 있었다
    - But, 엔진 속도 문제로 실패
  - 빠른것이 장점 -> 빠른 js의 실행이 장점인 것
- ts 런타임은 `Deno`

> 노드는 서버?

- 서버의 역할도 수행할 수 있는 `js` 런타임
- 노드로 `js로 작성된 서버`를 실행 가능
- 서버 실행을 위해 필요한 `http/https/http2` 모듈을 제공
  - Node.js(런타임), V8(엔진)
  - jre(런타임), jdk(node와 비슷한 역할)

### 런타임

> 노드: js 런타임

- 런타임: 특정 언어로 만든 프로그램을 실행할 수 있게 해주는 가상 머신(크롬 `V8` 자바스크립트 엔진의 사용) 상태
- 노드: js로 만든 프로그램을 실행할 수 있게 해줌
- 다른 런타임으로는 웹 브라우저(크롬, 엣지, 사파리, 파이어폭스 등)가 있음

### 내부 구조

> 2008년 `V8` 엔진 출시, 2009년 노드 프로젝트 시작
> 노드는 `V8`과 `libuv`를 내부적으로 포함

- `V8` 엔진: 오픈 소스 자바스크립트 엔진 -> 속도 문제 개선
- `libuv`: 노드의 특성인 `이벤트 기반`, `Non-Blocking I/O 모델`을 구현한 라이브러리

  - `js`, `node`가 뜬 이유 `싱글 스레드`이면서 `비동기인 모델`이라서
  - 빠른 성능을 이끌어 낼 수 있다
  - Non-Blocking I/O 모델

    > > `논블로킹 I/O 모델`은 컴퓨터 프로그래밍에서 입력/출력 작업을 수행할 때, <mark>작업이 완료될 때까지 기다리지 않고 즉시 다음 작업을 수행할 수 있도록 하는 방식</mark>. 이는 특히 네트워크 서버나 고성능 애플리케이션에서 중요한 개념이다. 논블로킹 I/O 모델의 주요 특징과 장점은 다음과 같다:

    1. **즉각적인 응답성**: I/O 작업이 완료될 때까지 기다리지 않기 때문에 애플리케이션의 응답성이 높아진다. 사용자 경험을 개선하는 데 도움이 된다.

    2. **자원 효율성**: `블로킹 I/O 모델`에서는 하나의 작업이 완료될 때까지 다른 작업이 대기해야 하지만, 논블로킹 I/O 모델에서는 여러 작업을 `동시에` 처리할 수 있어 자원 사용이 효율적이다.

    3. **비동기 처리**: 논블로킹 I/O는 `비동기적`으로 작동하여, I/O 작업이 완료되면 콜백 함수나 이벤트를 통해 결과를 처리할 수 있다.

    4. **적용 사례**: 주로 Node.js와 같은 서버 사이드 자바스크립트 환경이나, Java의 NIO (New Input/Output) 라이브러리, Python의 asyncio 모듈 등에서 사용

    > > > 💡논블로킹 I/O 모델을 사용하면 고성능, 고가용성 애플리케이션을 개발하는 데 큰 도움이 된다. 그러나 코드의 복잡성이 증가할 수 있으므로 적절한 설계와 구현이 필요

- 내부는 `C`, `C++`로 이루어 짐(속도 땜)
  - C: 생산성이 안좋음, `low-level`의 언어, `GC`와 같은 것들을 알아서 해주는 것이 ❌
    ![image](https://github.com/user-attachments/assets/477329a1-3611-4c77-a1b4-7cbfc875ec77)

### 노드의 특성

<b>::이벤트 기반</b>

> 이벤트가 발생할 때 미리 저장해둔 작업을 수행하는 방식

- e.g.) 클릭, 네트워크 요청, 타이머 등
- 이벤트 리스너: 이벤트를 등록하는 함수
- 콜백 함수: 이벤트가 발생했을 때 실행될 함수
  ![image](https://github.com/user-attachments/assets/bf45db04-3dca-472f-9e01-941b7615659a)

<b>::논 블로킹</b>

> 오래 걸리는 함수를 백그라운드로 보내서 다음 코드가 먼저 실행되게 하고, 나중에 오래 걸리는 함수를 실행

> > 노드는 동기이면서 블로킹, 비동기면서 논 블로킹이다
> > 노드에서는 동기면서 논 블로킹인거랑 비동기면서 블로킹인 것은 없다고 보면 된다.

- `논 블로킹` 방식 하에서 일부 코드는 백그라운드에서 병렬로 실행됨
- 일부 코드: `I/O작업`(파일 시스템 접근, 네트워크 요청), 압축, 암호화 등
- 나머지 코드는 블로킹 방식으로 실행됨
- `I/O작업`이 많을 때 노드 활용성이 극대화
  <br/>
- 흔히들, 비동기이면서 논 블로킹일 때, 노드(프로그램)가 `동시에` 돌아간다고 오해를 한다. 노드에서 `동시`라는 것을 구현하기는 어렵다. `동시`에 돌아가는 것들이 일부 있다.
- `논 블로킹`이라고 무조건 랜덤하게 실행되는 것은 아니다. 동기(`실행 컨텍스트`(this, scpope))와 비동기(`이벤트 루프`)라는 규칙이 있다.

<b>::프로세스와 스레드 그 사이 어딘가..</b>

> 프로세스와 스레드

- 프로세스: 운영체제에서 할당하는 작업의 단위 or 실행중인 프로그램이라 배웠던거 같은데.. 프로세스 간 자원 공유는 ❌
- 스레드: 프로세스 내에서 실행되는 작업의 단위, 부모 프로세스 자원 공유
  c.f.) 참고로 실제 크롬은 각 창을 프로세스로 띄운다.

> > 노드 프로세스는 <mark>멀티 스레드</mark>이지만 직접 다룰 수 있는 스레드는 <mark>하나</mark>이기 때문에 싱글 스레드라고 표현
> > 노드는 주로 멀티 스레드 대신 멀티 프로세스 활용
> > 14버전부터 멀티 스레드 사용 가능

<b>::싱글 스레드</b>

> 싱글 스레드라 주어진 일을 하나밖에, 하나의 스크립트 밖에 처리하지 못함

> - 블로킹이 발생하는 경우 나머지 작업은 모두 대기해야 한다 -> 비효율의 극치라고 볼 수 있죠..
> - 하나의 스레드는 보통 cpu의 여러 코어 중 하나의 코어를 담당
> - 멀티 코어라면 컨텍스트 스위칭(`문맥 교환`🙌)을 통해 cpu 자원을 효율적으로 사용 가능
>   > - 단일 코어에서도 컨텍스트 스위칭을 통해 멀티 테스킹 or 멀티 스레딩이 가능
>   >   > - 단일 코어에서는 멀티스레딩이 컨텍스트 스위칭을 통해 이루어질 떄, CPU가 매우 빠르게 스레드 간 전환하여 각 스레드가 실행될 수 있도록 한다.
>   >   >   이로 인해 여러 스레드가 동시에 실행되는 것처럼 보이지만 실제로는 순차(`한 번에 하나의 스레드만 실행`)적으로 실행된다.
>   > - 멀티 코어에서는 멀티스레딩과 멀티태스킹은 각 코어가 독립적으로 작업을 실행하여 진정한 `병렬 처리`가 가능
>   > - 컨텍스트 스위칭 발생 과정(간단하게..)
>   >   1. 요청 발생 : 인터럽트(hardware) 또는 트랩에 의한 요청이 발생 (트랩은 소프트웨어 인터럽트)
>   >   2. PCB에 저장 : 운영체제는 현재 실행중인 프로세스(P0)의 정보를 PCB에 저장
>   >   3. CPU 할당 : 운영체제는 다음 프로세스(P1)의 정보를 PCB에서 가져와 CPU를 할당

> > 참고로 컨텍스트 스위칭 자체는 순서를 보장하지 않지만, 스케줄링 알고리즘과 동기화 메커니즘을 통해 작업의 실행 순서를 제어할 수 있다.

<b>::멀티 스레드 모델과의 비교</b>

> 싱글 스레드 모델은 에러를 처리하지 못하는 경우 멈춤

- 프로그래밍 난이도 easy, CPU, 메모리 자원 적게 사용

> > 멀티 스레드 모델은 에러 발생 시 새로운 스레드를 생성하여 극복

- 단, 새로운 스레드 생성이나 놀고 있는 스레드 처리에 비용 발생
- 프로그래밍 난이도 어려움
- 스레드 수만큼 자원을 많이 사용함

> > > 대신 논 블로킹 모델을 채택하여 일부 코드(`I/O`)를 백그라운드(다른 프로세스)에서 실행 가능

- 요청을 먼저 받고, 완료될 때 응답함
- `I/O` 관련 코드가 아닌 경우 싱글 스레드, 블로킹 모델과 같아짐

> > > > 점원(스레드)이 하나인 체인점(노드 프로세스)을 여러 개 만들어 문제점 해결 -> <mark>멀티 프로세싱(I/O요청이 많을 때 use)</mark>
> > > > 노드의 핵심은 싱글 스레드 하나의 효율적 관리임

- 멀티 스레딩은 CPU 작업이 많을 때.. 사실상 멀티 스레딩은 아쉬움 달래기용임

### 서버로서의 노드

> 노드 != 서버

- 노드는 서버를 구성할 수 있게 하는 모듈 제공

<b>::노드 서버의 장단점</b>

> > 멀티 스레드 방식에 비해 컴퓨터 자원을 적게 사용
>
> - 싱글 스레드라서 CPU 코어를 하나만 사용
>   > I/O 작업이 많은 서버로 적합
> - CPU 작업이 많은 서버로는 부적합
>   > 멀티 스레드 방식보다 쉬움
> - 하나뿐인 스레드가 멈추지 않도록 관리해야 함
>   > 웹 서버가 내장되어 있음
> - 서버 규모가 커졌을 때 서버를 관리하기 어려움
>   > js의 사용, JSON 형식과 호환이 쉬움
> - 어중간한 성능

> > > CPU 작업을 위해 `AWS Lambda`나 `Google Cloud Functions`같은 별도 서비스 사용
> > > 넷플릭스, 나사 등에서 메인 또는 서브 서버로 사용

> > > > js 런타임이기 때문에 용도가 서버에만 한정되지 않음
> > > > 웹(React), 모바일(RN), 데스크탑(Electron)이 노드 기반으로 동작

### 호출 스택

- 함수 선언, 메모리에 올림
  > 호출 스택(함수의 호출, 자료구조의 스택)
- `Anonymous`(chrome)는 가상의 `전역 컨텍스트`(항상 있다고 생각하는게 좋음)
- 함수 호출 `순서대로` 쌓이고, `역순으로` 실행됨
- 함수 실행이 완료되면 스택(`LIFO`)에서 빠짐 -> js의 실행이 완료되는 시점
- 동기(순서대로)적으로 진행, 비동기 코드를 만났을 땐 `이벤트 루프` 등장

### 이벤트 루프

> 호출스택, 메모리(변수 선언), 백그라운드, 테스크 큐

- 호출 스택의 처리가 백그라운드보다 먼저다 -> 동기 코드가 비동기 코드보다 우선
  - 호출 스택과 백그라운드는 동시에 실행되나 처리의 문제.
    e.g. 백그라운드에서 카운트의 동시 실행
  - 백그라운드에서 `동시에` 돌아간다는 것은 비동기, 멀티 스레드로 돌아간다는 것
    - 백그라운드는 js로 돌아가는게 아니라 다른 언어로(c++, os쪽..?) 돌아감
    - 테스크 큐 또한 그렇다
    - 노드의 `libuv`도 c++로 동작
    - `js`자체는 싱글 스레드고 node 14ver에 `워커 스레드`나 브라우저에 `웹 워커`를 사용해야만 `js`에서 멀티 스레드 사용가능
    - 그래서 그 전에는 싱글 스레드 + 다른 언어의 백그라운드, 테스크 큐로 돌아갔다. 그래서 `동시성`이 있는것
  - 백그라운드로 갈 수 있는 것들이 있다.
    - 타이머, setInterval, 네트워크 요청, 파일 읽는 fs명령어, crypto 등
    ```js
    new Promise((resolve) => {
        resolve('hi);
    }).then(console.log);
    ```
    - `Promise`는 `then`을 만나는 순간 비동기가 된다. 내부까지는 동기
    - 결국 테스크 큐에 `Promise`의 `then`/`catch`, 타이머 등 여러 비동기가 들어갈 수 있는데 백그라운드에서는 어떤 것이 먼저 실행될지는 모른다. 다만 `테스크 큐에 우선순위`는 있음
      - `Promise`의 `then`/`catch`는 다른 비동기 보다 우선순위가 높음
      - `process.nextTick` 또한 우선순위가 다른 비동기에 비해 높다
  - 이외의 것들은 모두 동기적으로

> > 백그라운드에서 처리된 함수가 테스크 큐로 이동하는데, 이벤트 루프가 호출 스택이 비어있을 때 테스크 큐에 있던 함수들을 호출스택으로 이동 시킴

### var, const, let

> 가장 큰 차이점은 블록 스코프(var는 함수 스코프)

- `ES2015` 이후부터는 const와 let
- var은 함수 스코프를 존중하며 const, let은 블록 스코프를 존중
  ```js
  function a() {
    var y = 1;
  }
  console.log(y); // Uncaught ReferenceError: y is not defined
  ```
- const로 선언된 객체의 경우, 객체의 프로퍼티는 변경할 수 있다. 이는 객체의 참조가 변하지 않기 때문
- 객체의 프로퍼티를 변경하는 것은 객체의 참조 자체를 변경하는 것이 아니므로 가능
  ```js
  const aa = { name: "b" }; // aa는 객체 { name: 'b' }를 참조
  aa.name = "bb"; // 객체의 프로퍼티 name을 'bb'로 변경
  ```

### 템플릿 리터럴

```js
function a() {}
a();
== a``; // tagged template literal
```

### 화살표 함수

> 화살표 함수의 this는 부모의 this를 물려받는다.
> function 함수의 this는 자신만의 this

```js
btn.addEventListener("click", function () {
  console.log(this.textContent); // btn에 적혀있는 word
});

this;
btn.addEventListener("click", () => {
  console.log(this.textContent); // 상위 this를 가르킴
});

btn.addEventListener("click", (e) => {
  console.log(e.target.textContent);
});
```

> > this 사용시 function, 안쓰면 arrow

### 구조분해 할당

```js
const arr = [1, 2, 3, 4, 5];
const [x, y, , , z] = arr;
console.log(z); // 5, 배열도 가능
```

```js
const candyMachine = {
  status: {
    name: "node",
    count: 5,
  },
  getCandy() {
    this.status.count--;
    return this.status.count;
  },
};
const {
  getCandy,
  status: { count },
} = candyMachine;
```

> `this`는 함수를 호출할 때 어떻게 호출되었냐에 따라 결정

<b>::getCandy()와 candyMachine.getCandy()의 결과는 다르다</b>

- `this`의 바인딩이 다름
- candyMachine.getCandy()를 호출할 때 `this`는 candyMachine 객체를 가르킴
- 반면, 구조분해를 통해 getCandy 메서드를 추출한 후 getCandy()를 호출하면 this는 전역 객체(브라우저에선 window, Node.js에선 global)를 참조
- getCandy()의 문제를 해결하려면 this를 명시적으로 binding해야 한다.

```js
const boundGetCandy = getCandy.bind(candyMachine);
```

### 클래스

> 프로토타입 문법을 깔끔하게 작성할 수 있는 Class 문법

- Constructor, Extends 등을 깔끔하게 처리할 수 있음
- 코드가 그룹화되어 가독성 향상

```js
class Human {
    constructor(type = 'human'){
        this.type = type;
    }

    static isHuman(human) {
        return human instanceof Human;
    }

    breathe() {
        alert('hi');
    }
}

Class Jun extends Human {
    constructor(type, firName, lastName){
        super(type);
        this.firName = firName;
        this.lastName = lastName;
    }

    sayName() {
        super.breathe();
        alert(`${this.firName} ${this.lastName}`)
    }
}
```

### Promise, async/await

> 콜백 헬의 해결책

- Promise.all([array])
  - 여러개의 Promise 동시 수행
- Promise.allSettled()로 실패한 것만 추려내기
- function -> async await
  - resolve 반환
  - then hell ❌
  - top level await
- async는 Promise 반환
  ```js
  const promise1 = Promise.resolve("성공1");
  const promise2 = Promise.resolve("성공2");
  (async () => {
    for await (promise of [promise1, promise2]) {
      console.log(promise);
    }
  })();
  ```

### Map, Set, WeakMap, WeakSet

> ES2015 + Map, Set
>
> > Map은 객체와 유사, Set은 배열과 유사

```js
const m = new Map();

m.set("a", "b"); // set(key, val)으로 Map에 속성 추가
m.set(3, "c"); // 문자열이 아닌 값을 키로 사용 가능
const d = {};
m.set(d, "e"); // 객체도 가능

m.get(d); // get(키)로 속성값 조회
console.log(m.get(d)); // e

m.size; // size로 속성 개수 조회
console.log(m.size); // 3

for (const [k, v] of m) {
  // 반복문에 바로 넣어 사용 가능
  console.log(k, v); // 'a', 'b', 3, 'c', {}, 'e'
} // 속성 간의 순서도 보장

m.forEach((v, k) => {
  // forEach도 사용 가능
  console.log(k, v);
});

m.has(d); // has(키)로 속성 존재 여부를 확인
console.log(m.has(d)); // true

m.delete(d); // 속성 제거
m.clear(); // clear()로 전부 제거
```

```js
const arr = [1, 2, 3, 2, 3, 5, 2];
const s2 = new Set(arr);

s2; // {1,2,3,5}
Array.from(s2); // [1,2,3,5]
```

- WeakMap도 Map과 유사하지만, WeakMap은 가비지컬렉팅이 적용

```js
let obj4 = {};
Map.set(obj4, "123");

obj4 = null; // Map은 obj4를 갖고 있음
```

```js
let user = { name: "John", age: 24 };

user.married = false;

const userObj = {
  user,
  married: false,
};

const wm = new WeakMap();
wm.set(user, { married: false }); // 객체를 수정하지 않고 부가적인 정보를 저장가능한 수단, 가비지컬렉션이 적용되면서
user = null; // user null 적용시 부가적인 정보도 가비지 컬렉션이 적용
```

### ??, ?.연산자(nullish coalescing, optional chaining)

> 널 병합 연산자(??)는 연산자 대용으로 사용되며, falsy 값(0, '', false, NaN, null, undefined) 중 null과 undefined만 따로 구분

```js
const a = 0;
const b = a || 3;
console.log(b); // 3

const c = 0;
const d = c ?? 3;
console.log(d); // 0

e?.[0];
```

### fe js

- FormData
- encodeURIComponent

  ```js
  ( async () => {
    try {
      const result = await axios.get(`https://www.xxxxx.com/api/search/${encodeURIComponent('노드')}`); // asci 코드 지원
      ...
    }
    catch(e) {

    }
  })
  ```

  - `uri`는 서버에 있는 자원 식별
    - url, urn
  - `url`은 서버에 있는 자원의 위치

- decodeURIComponent
  ```js
  decodeURIComponent("%EB%85"); // 노드, on the server
  ```
- html과 js간의 data 교환
  - data attribute와 dataset
    - 서버의 데이터(공개용)를 fe로 내려줄 때 사용
    - 태그 속성으로 `data-속성명`
    - js에서 `태그.dataset.속성명`으로 접근 가능
      - `data-user-job` -> `dataset.userJob`
    - 반대로 js `dataset`에 값을 넣으면 `data-속성`이 생김
      - `dataset.monthsalary = 1000` -> `data-month-salary = '1000'`
  ```html
  <ul>
    <li data-id="1" data-user-job="progrmmer">Bao</li>
  </ul>
  ```

### module, this, require, 순환참조

```js
const odd = "odd";
const even = "even";

module.exports = {
  odd,
  even, // ES6: key, 변수 동일
}; // possible 객체 or 배열
exports.odd = odd;
exports.even = even; // module.exports === exports === {}

const { odd, even } = require("./temp"); // node require supporting

function checkNum(num) {
  console.log(num);
}
module.exports = checkNum;
```

```js
// 전역 스코프의 this
console.log(this); // window in Js(browser) 🟠, global in Js(node)❌ {} === module.exports ✔️

function a() {
  console.log(this === global); // true
}
```

- 이 외에는 function마다 this 생성 동일, arrow func은 부모의 this 물려받기 동일

```js
require("./temp"); // 오직 temp 파일의 실행, exports한 값을 사용은 안함
console.log(require); // main, extensions, cache, ...
```

- require.main으로 어떤 파일을 실행한건지 알아낼 수 있음.
  - js를 node로 실행 시, 대부분 module
  - require.main은 node 실행 시 첫 모듈을 가리킴
  - require.main === module
  - require.main.filename
  - require.main.exports
- require.cache에서 1번 불러왔을 때는 파일을 읽고 cache에 저장, 2번째 불러올 때는 cache에 저장된 memory에서 읽음.
  - 원래 hdd에서 읽는 건 느리고, memory에서 읽는 건 빠르다. 보통 hdd에 있는 정보를 memory로 옮기는 것을 캐싱이라 한다.

temp1

```js
require("./temp2");
```

temp2

```js
require("./temp1"); // {}
```

- node에서 순환참조가 일어나는 경우, temp1에 exports 값이 있다하더라도 빈 객체(`{}`)로 바꿔버림

### ECMAScript 모듈(import, export default), dynamic import, top level await

> ES module is standard Js module, more CJS -> ES.
>
> > ESModule(browser, node), CJS(node)

```js
export const odd = "odd";
```

```js
import { odd } from "./temp.mjs"; // const {odd, even} = require("./temp"); in cjs

function checkNum(num) {
  console.log(num);
}

export default checkNum; // module.exports = checkNum in cjs
```

```js
import chkN from "./temp2.mjs"; // 변수 선언과 비슷한 개념으로 chkN === checkNum
```

- odd는 이름이 정해진 export -> named export
- chkN -> default export
  > - require -> import
  > - exports -> export
  > - module.exports -> export defualt (1:1대응이 아님, 다르다🟠)
  >   > - ES모듈의 import, export default는 require나 module처럼 함수나 객체가 아니라 문법 그 자체이므로 수정 불가.
  >   > - CJS에서 require는 함수, exports, module.exports는 객체이므로 값을 덮어씌우거나 참조를 끊을 수 있었다.
  >   >   > - mjs확장자 대신 js확장자를 사용하면서, package.json에 type: "module" 속성을 사용 가능 🟠 js확장자 파일도 ESModule로 인식
  >   >   > - CJS와는 다르게 import 시 파일 경로에 js, mjs 같은 확장자를 생략 불가 ❌ node에서는 possible
  >   >   > - EJS top level awiait 가능, CJS에선 불가능 ❌
  >   >   > - EJS에서 **filename, **dirname 불가능(`import.meta.url` 사용), CJS에서 가능

```js
const a = false;
if (a) {
  require("./func"); // dynamic import can be used in CJS
}
console.log("성공");
```

```js
const a = false;
if (a) {
  import "./func.mjs"; // SyntaxError: UnExpected string, import는 최상단에 존재해야
}
```

```js
const a = false;
if (a) {
  const m1 = await import("./func.mjs"); // { default: [Function: chekcNum]}
  // defualt안에 존재, module.exports -> export defualt가 다른 이유
  const m2 = await import("./func2.mjs"); // import 함수는 Promise🟠
}
```

- CJS에서 require함수, module 객체는 따로 선언하지 않았음에도 내장 객체이므로 사용 가능

### 노드 내장 객체(global, console, 타이머)

- globalThis(browser: window, node: global)로 통일
- global.require -> require로 생략 가능
  - global.module.exports(`{}`)
  - global.console.log
  - ...
- global 속성 공유 가능

```js
console.dir({hi: 'hi'}); // {hi: 'hi'}

console.time('hi');
...
console.timeEnd('hi'); // hi: 5.013s

console.trace; // 호출스택 로깅

setTimeout(callback, milliseconds); // ms이후 callback
const hello = setInterval(callback, milliseconds); // 반복
setImmediate(callback); // 즉시 실행
// 안의 함수들을 background(동시에)로 보내는 대표적인 비동기 코드
// background -> task queue -> event loop에 의해 호출스택으로 이동하기 전에 clearImmediate로 취소가능

clearInterval(hello);
```

### os와 path

```js
const os = require('os');

os.cpus(); // core number
os.freemem();
os.totalmem();
...
```

- 운영체제 정보
- cpu 정보
  - os의 스레드와 node의 스레드는 다른 개념
    - 8core 16thread -> 16core라고 봐도 무방
- 메모리 정보

```js
const path = require("path");
// C:\users\jyj
// /user/jyj

path.join(__direname, "/var.js"); // 절대경로 무시(join)
path.join(__direname, "..", "/var.js");
// C:\users\jyj\var.js (window)
// /user/var.js linux,mac(POSIX)

path.resolve(__direname, "..", "/var.js"); // 절대경로 유효(resolve)
// C:\var.js

path.parse();
path.normalize();
path.relative();
```

- 운영체제마다 경로의 분기처리를 path모듈을 통해 해결 가능

### node 내장 모듈(url, dns), searchParams

> node에서 사용하던 url 방식보단 node 버전 7에 추가된 `WHATWG`(웹 표준을 정하는 단체의 이름) 방식의 url 방식을 사용한다.
>
> > 브라우저에서도 `WHATWG` 방식을 사용하므로 호환성이 좋다.
> > <img width="551" alt="image" src="https://github.com/user-attachments/assets/422da0a4-e7da-490d-9aec-53d4caecb3ba">
> >
> > > - https://{username}:{password}@naver.com:443/signin/hi=you

```js
const url = new URL('https://chromewebstore.google.com/?hl=ko&pli=1);
console.log(url);

{
  hash: ""
  host: "chromewebstore.google.com"
  hostname: "chromewebstore.google.com"
  href: "https://chromewebstore.google.com/?hl=ko&pli=1"
  origin: "https://chromewebstore.google.com"
  password: ""
  pathname: "/"
  port: ""
  protocol: "https:"
  search: "?hl=ko&pli=1"
  searchParams: URLSearchParams {size: 2} // Iterator 객체
  username: ""
}
```

`node searchParams`

- url.searchParams.getAll()
- url.searchParams.get()
- url.searchParams.has()
- url.searchParams.keys()
- url.searchParams.values()
- url.searchParams.append()
  - 같은 이름으로 2번 이상 추가 가능
- url.searchParams.set()
- url.searchParams.delete()
- url.searchParams.toString()

```js
const dns = require('dns');

const ip = await dns.lookup('xxx.co.kr'); // ip

// A 레코드 조회
await dns.resolve('example.com', 'A', (err, addresses) => {
  if (err) {
    console.error('Error:', err);
  } else {
    console.log('A 레코드:', addresses);
  }
});

// MX 레코드 조회
await dns.resolve('example.com', 'MX', (err, addresses) => {
...
});

// TXT 레코드 조회
await dns.resolve('example.com', 'TXT', (err, records) => {
...
});

// CNAME 레코드 조회
dns.resolve('www.example.com', 'CNAME', (err, addresses) => {
...
});
// www.example.com이 example.com으로 매핑
```

> `dns.resolve` 함수는 첫 번째 인수로 도메인 이름을, 두 번째 인수로 조회할 레코드 타입을, 세 번째 인수로 콜백 함수를 받는다. 콜백 함수는 두 개의 인수를 받는데, 첫 번째 인수는 오류 객체이고, 두 번째 인수는 조회된 레코드 정보

- A 레코드 조회: 도메인 이름을 IPv4 주소로 변환
- AAA: IPv6
- MX 레코드 조회: 도메인 이름에 대한 메일 서버 정보를 조회
- TXT 레코드 조회: 도메인 이름에 대한 텍스트 정보를 조회
- CNAME(별칭): CNAME 레코드는 하나의 도메인 이름을 다른 도메인 이름으로 매핑하는 데 사용
- NS(네임서버)
- SOA(도메인 정보)

### crypto와 util

- 암호화는 multi-thread로 돌아감
- Hash 기법은 단방향 암호화 기법
  - 복호화가 거의 불가능에 가까움

Hash(sha512)

> createHash(알고리즘): 사용할 해시 알고리즘을 넣어준다.
>
> > - md5, sha1, sha256, sha512 등이 가능하지만, md5와 sha1은 이미 취약점이 발견
> > - 현재는 sha512 정도로 충분하지만, 나중에 sha512마저도 취약해지면 더 강화된 알고리즘으로 바꿔야
> >   update(문자열): 변환할 문자열을 넣어준다.
> >   digest(인코딩): 인코딩할 알고리즘을 넣어준다.

```js
const crypto = require('crypto');

console.log('base64: ', crypto.createHash('sha512').update('비번').digest('base64'));
console.1og('hex: ', crypto.createHash('sha512').update('비번').digest('hex')):
console.log('base64: ', crypto.createHash('sha512').update('다른 비밀번호').digest('base64'));
```

pbkdf2

> 컴퓨터의 발달로 기존 암호화 알고리즘이 위협받고 있음
>
> > crypto.randomBytes로 64바이트 문자열 생성 -> salt 역할
> > pbkdf2 인수로 순서대로 비밀번호, salt, 반복 횟수, 출력 바이트, 알고리즘
> > 반복 횟수를 조정해 암호화하는 데 1초 정도 걸리게 맞추는 것이 권장됨

```js
const crypto = require('crypto');

crypto.randomBytes(64, (err, buf) => {
  const salt = buf.toString('base64');
  console.log('salt:', salt);
  crypto.pbkdf2('비밀번호', salt, 100000. 64, 'shas12', (err, key) => {
      console.1og('password:', key.toString('base64'));
    });
});
```

- 양방향 복호화

  - key가 사용됨
  - 암호화할 때와 복호화 할 때 같은 key사용

  ```js
  const crypto = require("crypto");

  const algorithm = "aes-256-cbc";
  const key = "abcdefghijklmnopqrstuvwxyz123456";
  const iv = "1234567890123456";

  const cipher = crypto.createCipheriv(algorithm, key, iv);
  let result = cipher.update("암호화할 문장", "utf8", "base64");
  result += cipher.final("base64");
  console.log("암호화:", result);

  const decipher = crypto.createDecipheriv(algorithm, key, iv);
  let result2 = decipher.update(result, "base64", "utf8");
  result2 += decipher.final("utf8");
  console.log("복호화:", result2);
  ```

- [crypto-js](https://www.npmjs.com/package/crypto-js) 사용하는 것도 좋다

  ```js
  var SHA512 = require("crypto-js/sha512"); // 단방향 암호화
  var AES = require("crypto-js/aes"); // 양방향(대칭형) 암호화
  ```

  - 비대칭 암호화, 프론트와 서버가 서로 다른 키를 갖고 있으면서 암호화, 복호화 하는 것
    - e.g.) https, rsa

- GCP KMS(Cloud Key Management)

> util: 각종 편의 기능을 모아둔 모듈
> util.deprecate: 함수가 deprecated 처리되었음을 알려준다.
>
> > - 첫 번째 인자로 넣은 함수를 사용했을 때 경고 메시지가 출력
> > - 두 번째 인자로 경고 메시지 내용을 넣고 함수가 조만간 사라지거나 변경될 때 알려줄 수 있어 유용

```js
const util = require("util");
const crypto = require("crypto");

const dontUseMe = util.deprecate((x, y) => {
  console.log(x + y);
}, "dontusele 함수는 deprecated");
dontUseMe(1, 2);
```

> util.promisify: 콜백 패턴을 프로미스 패턴으로 바꿔준다.
>
> > - 바꿀 함수를 인자로 제공하면 된다. 이렇게 바꾸어두면 async/await 패턴까지 사용 가능. 단, 콜백이 `(error, data) => {}` 형식이어야
> > - uticallbackity도 있지만 자주 사용되지는 않음

```js
const randomBytesPromise = util.promisify(crypto.randomBytes);
randomBytesPromise(64)
  .then ((buf) => {
      console.log(buf.toString('base64'));
    })
  .catch((error) => {
    console. error(error);
    }):
```

### worker_threads

```js
const {
  Worker,
  isMainThread,
  parentPort,
  workerData,
} = require("worker_threads");

const min = 2;
let primes = [];

function findPrimes(start, end) {
  let isPrime = true;
  for (let i = start; i <= end; i++) {
    for (let j = min; j < Math.sqrt(end); j++) {
      if (i !== j && i % j === 0) {
        isPrime = false;
        break;
      }
    }
    if (isPrime) {
      primes.push(i);
    }
    isPrime = true;
  }
}

if (isMainThread) {
  // 부모일 때
  const max = 10000000;
  const threadCount = 8;
  const threads = new Set();
  const range = Math.floor((max - min) / threadCount);
  let start = min;
  console.time("prime");
  for (let i = 0; i < threadCount - 1; i++) {
    const end = start + range - 1;
    threads.add(new Worker(__filename, { workerData: { start, range: end } }));
    start += range;
  }
  threads.add(new Worker(__filename, { workerData: { start, range: max } }));
  for (let worker of threads) {
    worker.on("error", (err) => {
      throw err; // 예외 처리에 대한 로직
    });
    worker.on("exit", () => {
      threads.delete(worker);
      if (threads.size === 0) {
        console.timeEnd("prime");
        console.log(primes.length);
      }
    });
    worker.on("message", (msg) => {
      primes = primes.concat(msg);
    });
  }
} else {
  // 워커일 때
  findPrimes(workerData.start, workerData.range);
  parentPort.postMessage(primes);
}
```

- 서버 core 개수에 따라서 달라질 수 있다
- 데이터의 이동: 워커 스레드 -> 부모 스레드
  - 작업의 분배(부모 스레드)
  - 작업의 수행(워커 스레드)
