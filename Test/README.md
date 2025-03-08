### jest(자바스크립트 + 테스트, 농담이란 뜻)

> - 페이스북에서 만든 테스트 프레임워크
> - Ts/Babel/리액트/Node.js 전부 다 지원
> - Vitest(Vite), Jasmine, Mocha+Sinon+Chai 등의 대체재도 있음

### 필요성

1. 예전에 났던 에러가 또 나는 경우
2. 코드가 복잡한데 많이 바꿔야하는 경우
3. 하나의 코드를 수정했더니 import한 다른 곳에서 에러가 나는 경우
4. 장기간에 걸쳐 유지보수를 해야 하는 경우

> ts-jest는 TypeScript로 작성된 테스트 코드를 Jest가 실행할 수 있도록 해주는 TypeScript 전처리기(preprocessor)

### installation

```sh
npm i jest -D

npm i ts-jest @types/jest -D

npm i babel-jest @babel/core @babel/preset-env

npm i cross-env // 윈도우 호환용 패키지

npm init jest@latest // jest.config.js 세팅 명령어
```

### execution

```sh
# commonjs 모듈일 때
npx jest

# ECMA모듈, package.json에 "type": "module"도 넣을 것
npx cross-env NODE_OPTIONS="$NODE_OPTIONS --experimental-vm-modules" jest
```

### Ts 및 Jest 세팅

> - package.json에 type:”module” → cjs에서 ecma 모듈로 변경
> - ts는 기본적으로 cjs
> - ecma모듈은 named export, export default
> - cjs는 require, module.exports
> - `npx ts-jest config:init`으로 jest 관리 혹은 `package.json`에서 관리 가능
> -

> ```text
> Copytsconfig.json (TypeScript 설정)
> ├─ 타입스크립트 컴파일러 설정
> ├─ 타입 체크 규칙 설정
> └─ 타입 정의 파일 위치 설정
>
> jest.config.js (Jest 설정)
> ├─ 테스트 실행 환경 설정
> ├─ TypeScript 변환 설정 (ts-jest)
> └─ 테스트 파일 위치 설정
> ```
>
> tsconfig.json은 TypeScript 코드를 JavaScript로 변환하고 타입을 체크하는 규칙을 정의
> jest.config.js는 Jest가 테스트를 실행할 때 필요한 설정을 정의
>
> - ts-jest가 이 둘을 연결:
>
> > - Jest가 TypeScript 파일을 실행할 때 ts-jest가 tsconfig.json의 설정을 참조하여 TypeScript 코드를 JavaScript로 변환
> > - 즉, ts-jest는 TypeScript 컴파일러와 Jest 테스트 러너 사이의 브릿지 역할
>
> settings.json
>
> ```json
> {
>   "jest.pathToJest": "**/node_modules/.bin/jest",
>   "jest.pathToConfig": "**/jest.config.js",
>   "jest.showCoverageOnLoad": true
> }
> ```
>
> `jest.pathToJest": "**/node_modules/.bin/jest`
>
> - Jest 실행 파일의 경로를 지정
> - 프로젝트의 로컬 Jest를 사용하도록 보장 (전역 설치된 Jest가 아닌)
> - 워크스페이스 내 여러 프로젝트가 있을 때도 각각의 Jest를 찾을 수 있도록 \*\* 글로브 패턴을 사용
>
> `jest.pathToConfig": "\*\*/jest.config.js`
>
> - Jest 설정 파일의 경로를 지정
> - 커스텀 설정(테스트 환경, 변환 규칙, 커버리지 설정 등)을 Jest가 찾을 수 있도록
> - 마찬가지로 여러 프로젝트의 설정을 찾을 수 있도록 \*\* 패턴 사용
>
> `jest.showCoverageOnLoad": true`
>
> - VS Code가 시작될 때 자동으로 테스트 커버리지 정보를 표시
> - 코드 커버리지를 실시간으로 확인할 수 있어 테스트 작성 시 유용
>
> vsCode에서 `Jest` Plugin 에디터와 결합이 좋아보임
>
> `filename.spec.ts` or `filename.test.ts`를 `jest.config.js`에서 testRegex를 통해 커스텀하게 수정가능

### Jest

### 기본

> - test, expect
>
> - toBe, toStrictEqual, toMatchObject
>
> - toHaveBeenCalled, toHaveBeenCalledTimes, toHaveBeenCalledWith
>
> - Promise 테스트 resolves/rejects, then/catch, async/await
>
> - callback함수
>
> - toThrow(함수 필수)
>
> - describe, it(test), it.skip it.todo,
>
> - \*\*it.concurrent(테스트는 순서대로 실행되는데 동시에 실행하는 실험적 기능)
>
> - beforeEach, beforeAll, afterEach, afterAll
>
> - useFakeTimers, setSystemTime, useRealTimers, runAllTimers, advanceTimersByTime
>
> - expect.assertions(비동기 테스트 때 적어두는 것 강추)
>
> - 순서, toBeLessThan, toBeGreaterThan,
>
> - jest-extended
>
> - toHaveBeenCalledWith에서 일부만 테스트하기
>
> - import/require는 캐싱됨. 리셋하려면 jest.resetModules
>
> - only로 이 테스트만 실행하게 할 수 있음. only를 붙일 때와 뗄 때 결과가 다르다면 다른 테스트에 의해 영향받고 있는 것
>
> - each로 중복되는 테스트를 하나로 합칠 수 있음(설명에 %i, $a)
>
> - expect.any, expect.closeTo, expect.anything 같은 유틸들 적극 활용하기.
>
> - —runInBand = 싱글스레드 옵션(모노레포나 컴퓨터 성능 느릴 시 테스트 속도 향상)
>
> - —maxWorkers = 멀티스레드 개수 옵션(기본은 cpu 수 - 1)
>
> - 파일 변경 추적: —watch = 변경된 부분만 테스트, —watchAll = 모두 다 테스트
>
> - 테스트를 다 마쳤는데 터미널에서 끝나지 않고 계속 남아있다면 오픈 핸들을 의심하자.
>
> > - —detectOpenHandles로 네트워크 요청, 커넥션 확인해서 종료하기
> > - 타이머 종료되지 않은 것은 clearAllTimers로 종료(fakeTimers 필요)
> > - 도저히 못 찾겠으면 `--forceExit` 추가

### 모킹

> ```js
> jest.fn(), jest.fn(함수)
>
> jest.spyOn(객체, 메서드)
>
> .mockImplementation(가짜구현), .mockImplementationOnce
>
> .mockReturnValue(가짜값), .mockReturnValueOnce
>
> .mockResolvedValue(가짜프로미스), .mockResolvedValueOnce
>
> .mockRejectedValue(가짜에러), .mockRejectedValueOnce
>
> jest.useFakeTimers().setSystemTime, jest.useRealTimers
>
> mockReset mockRestore mockClear
>
> jestResetAllMocks, jest.restorAllMocks, jest.clearAllMocks
>
> jest.replaceProperty
>
> jest.mock(모듈), jest.mock(모듈, 함수) 호이스팅, __mocks__
>
> `import fetch from ‘cross-fetch’;
> jest.mock('cross-fetch');
> (fetch as jest.Mock).mockResolvedValue();
> (fetch as jest.Mock).mockImplementation();
> (fetch as jest.Mock).mockClear();`
>
> jest.mock 호이스팅을 원치 않으면 jest.spyOn
>
> jest.mock시 module.exports나 export default가 함수면 함수 모킹, 클래스면 클래스 메서드 모킹
>
> 원본을 jest.requireActual로 가져올 수 있음
> ```

#### toStrictEqual, toMatchObject

> - 객체는 toBe로 비교 안됨. 값이 참조하는 메모리 주소가 다르기에 toStrictEqual를 통해 비교(!= {})
> - toMatchObject는 같은 객체여도 생성자가 다른 경우(Class문법) 사용(!= Class)
>   > ```ts
>   > test("클래스 비교는 toMatchObject로 해야 한다", () => {
>   >   expect(obj("hello")).not.toStrictEqual({ a: "hello" });
>   >   expect(obj("hello")).toMatchObject({ a: "hello" });
>   > });
>   > ```
>   >
>   > - 되는것과 안되는 것을 명시해야. 안되는 경우 명시가 중요

#### toHaveBeenCalled 시리즈와 jest.fn, jest.spyOn

> - toHaveBeenCalled는 함수가 호출되었는지, toHaveBeenCalled만 쓰면 의미 없음
> - jest.fn은 새로운 모의 함수를 만들 때 사용하고, jest.spyOn은 기존 객체의 메서드를 감시하거나 모의할 때 사용
>
> ```js
> test("sum 함수가 1,2와 함께 호출되었다", () => {
>   const sumSpy = jest.fn(sum);
>   sumSpy(1, 2);
>   expect(sumSpy).toHaveBeenCalledWith(1, 2);
> });
>
> test("obj.minus 함수가 1번 호출되었다(spy함수 생성)", () => {
>   const minusSpy = jest.fn(obj.minus);
>   minusSpy(1, 2);
>   expect(minusSpy).toHaveBeenCalledTimes(1); // how times
> });
>
> test("obj.minus 함수가 1번 호출되었다(spy 삽입)", () => {
>   jest.spyOn(obj, "minus");
>   const result = obj.minus(1, 2);
>   console.log(obj.minus); // mock관련 함수 추가, constructior부터 다름
>   expect(obj.minus).toHaveBeenCalledTimes(1);
>   expect(result).toBe(-1);
> });
> ```

#### mockImplementation, mockReturnValue

> - e.g. mockImplementation으로 함수 호출의 유무만 테스트하고 db를 거치지않고 mock데이터 넘기기 가능
> - e.g. mockReturnValue은 mockImplementation의 짧은 버전. 함수를 갈아끼우는 mockImplementation에 비해 mockReturnValue는 값을 갈아끼움
>
> ```ts
> test("obj.minus에 스파이를 심고 리턴값이 서로 다르게 나오게", () => {
>   spyFn = jest
>     .spyOn(obj, "minus")
>     .mockImplementationOnce((a, b) => a + b)
>     .mockImplementationOnce(() => 5)
>     .mockImplementation(() => 3);
>   const result1 = obj.minus(1, 2);
>   const result2 = obj.minus(1, 2);
>   const result3 = obj.minus(1, 2);
>   expect(obj.minus).toHaveBeenCalledTimes(3);
>   expect(result1).toBe(3);
>   expect(result2).toBe(5);
>   expect(result3).toBe(3);
> });
>
> test("obj.minus에 스파이를 심고 리턴값이 다르게 나오게(mockReturnValue)", () => {
>   spyFn = jest.spyOn(obj, "minus").mockReturnValue(5);
>   const result1 = obj.minus(1, 2);
>   expect(obj.minus).toHaveBeenCalledTimes(1);
>   expect(result1).toBe(5);
> });
>
> test("obj.minus에 스파이를 심고 리턴값이 다르게 나오게(mockReturnValueOnce)", () => {
>   spyFn = jest
>     .spyOn(obj, "minus")
>     .mockReturnValueOnce(5)
>     .mockReturnValueOnce(3)
>     .mockReturnValue(8);
>   const result1 = obj.minus(1, 2);
>   const result2 = obj.minus(1, 2);
>   const result3 = obj.minus(1, 2);
>   expect(obj.minus).toHaveBeenCalledTimes(3);
>   expect(result1).toBe(5);
>   expect(result2).toBe(3);
>   expect(result3).toBe(8);
> });
> ```

#### 비동기함수 테스트

> - promise를 반환하는 return하는 테스트 방법은 크게 3가지
>   > - resolves, then & aync, await & 에러에서는 catch, rejects 그리고 try-catch
> - `expect(okSpy()).resolves.toBe("no")`, resolves를 쓰면 앞에 return 필수, promise가 resolve 될 때까지 기다렸다가 테스트 가능. return이 없으면 resolve되기 전에 끝남
> - promise 테스트를 하는 방법 중 then이 있음. 그래도 return은 필수
> - 실패한 promise는 catch와 reject, 성공한 promise는 resolve와 then
> - async 함수는 Promise 객체를 반환
> - async, await에선 resolve도 불필요, 에러 날 경우 try-catch 안에서 expect는 사용
> - jest.spyOn을 통해 spy함수를 심으면 mock메서드 사용이 가능한데 mockRejectedValue는 mockReturnValue(rejected Promise)와 동일
>   > ```ts
>   > jest.spyOn(fns, "noPromise").mockRejectedValue("no"); // spy함수 심기,
>   > jest.spyOn(fns, "noPromise").mockReturnValue(Promise.reject("no"));
>   > ```
>
> ```js
> import * as fns from "./asyncFunction";
>
> test("okPromise 테스트", () => {
>   const okSpy = jest.fn(fns.okPromise);
>   return expect(okSpy()).resolves.toBe("no");
> });
>
> test("okPromise 테스트2", () => {
>   expect.assertions(1);
>   const okSpy = jest.fn(fns.okPromise);
>   return okSpy().then((result) => {
>     expect(result).toBe("ok");
>   });
> });
>
> test("noPromise 테스트", () => {
>   expect.assertions(1);
>   const noSpy = jest.fn(fns.noPromise); // spy함수 생성
>   return noSpy().catch((result) => {
>     expect(result).toBe("no");
>   });
> });
>
> test("noPromise 테스트2", () => {
>   expect.assertions(1);
>   jest.spyOn(fns, "noPromise").mockRejectedValue("no"); // spy함수 심기,
>   return expect(fns.noPromise()).rejects.toBe("no");
> });
> ```

#### 콜백함수 테스트

> - done 콜백의 타입적 특징:
>
> > - DoneCallback은 함수이면서 fail 메서드를 가진 인터페이스
> > - ProvidesCallback 타입은 done 콜백을 받는 함수 또는 Promise를 반환하는 함수일 수 있다.
> > - 모든 생명주기 메서드(beforeAll, afterAll 등)에서 사용 가능합니다.
>
> ```ts
> interface DoneCallback {
>  (...args: any[]): any;
>   fail(error?: string | { message: string }): any;
> }
>
> type ProvidesCallback =
>  ((cb: DoneCallback) => void | undefined) |
>   (() => PromiseLike<unknown>);
>
> type ProvidesHookCallback = (() => any) | ProvidesCallback;>
> ...
> declare var test: jest.It;
> ...
> interface It {
> (name: string, fn?: ProvidesCallback, timeout?: number): void;
> // ... 다른 속성들
> }
> ```
>
> - callback함수를 테스트할 때는 It 타입의 구현이며, done이 DoneCallback 타입의 파라미터를 써서 테스트 가능
> - done이 없다면 비동기 특성상 jest가 타이머를 기다리지 못함. done을 통해 기다리게.
> - <b>다만, 콜벡함수 방식보다는 Promise로 통일해서 테스트하는게 낫다.</b>
>
> ```ts
> export function timer(callback: (str: string) => void) {
>   setTimeout(() => {
>     callback("success");
>   }, 10_000);
> }
>
> import { timer } from "./callback";
>
> test.skip("타이머 테스트", (done: jest.DoneCallback) => {
>   expect.assertions(1);
>   jest.useFakeTimers();
>   timer((message: string) => {
>     expect(message).toBe("success");
>     done();
>   });
> }, 25_000);
> ```

#### 에러 테스트, toThrow

> - expect안에서 에러를 함수로 감싸서 실행해주기, toThrow로 비교
> - try-catch 부분에서 catch에서 받는 Err인자는 에러 객체이므로 toStrictEqual에 주의
>
> ```ts
> export function error() {
>   throw new Error();
> }
>
> export class CustomError extends Error {}
> export function customeError() {
>   throw new CustomError();
> }
> import { error, customeError, CustomError } from "./throwFunction";
>
> test("error가 잘 난다", () => {
>   expect(() => error()).toThrow(Error);
>   expect(() => customeError()).toThrow(CustomError);
>   // expect(customeError()).toThrow(CustomError); ❌, 함수로 감싸서 실행을 해줘야 () => customeError()
> });
>
> test("error가 잘 난다(try/catch)", () => {
>   try {
>     error();
>   } catch (err) {
>     expect(err).toStrictEqual(new Error()); // toThrow가 아니라 toStrictEqual. err은 객체
>   }
> });
> ```

#### mockClear, mockReset, mockRestore

> - mockClear: spy함수가 몇번 실행되었는지, CalledWih...와 같이 불린 횟수를 초기화
> - mockReset: `mockClear() + mockImplementation(() => {})`, 스파이 함수 불린 횟수 초기화 후에 mockImplementation으로 빈 함수로 만든다.
> - mockRestore: 아예 전부 reset, 가장 강력한 초기화
> - 초기화를 안하고 spy함수를 계속 사용하면 횟수에 대한 테스트가 실패(전체파일에서, 개별 test는 성공하더라도)
>
> ```ts
> test("obj.minus 함수가 1번 호출되었다(spy 삽입) 그리고 횟수 초기화", () => {
>   spyFn = jest.spyOn(obj, "minus");
>   const result = obj.minus(1, 2);
>   console.log(obj.minus);
>   expect(obj.minus).toHaveBeenCalledTimes(1);
>   expect(result).toBe(-1);
>   spyFn.mockRestore(); // RESET
> });
> ```

#### 테스트 라이프사이클 - beforeAll, beforeEach, afterEach, afterAll

> - beforeAll: file단위, 전체 테스트 실행 전 준비사항
> - beforeEach: 각 테스트 전에 실행, e.g.) 변수 초기화
> - afterEach: `spyFn.mockRestore()`로 각 테스트 끝나고 정리할 때
>   > - `jest.clearAllMocks()`: 모든 spy함수 클리어
>   > - `jest.resetAllMocks()`: clear는 ~with나 ~times를 초기화한다면, reset은 거기에다가 mockImplementation을 빈 함수로 만듦
>   >   > - `mockClear() + mockImplementation(() => {})`
>   > - `jest.restoreAllMocks()`: spy자체를 없애버림
> - afterAll: beforeAll에서 준비한 DB연결이라던지 서버 연결을 해제

#### test 그룹화를 위한 describe

> - 테스트의 그룹화, 파일 단위로 나눠도 무방하지만 같은 파일내에서 그룹화 가능
> - describe 내부의 afterAll은 상위 스코프의 beforeEach보다 전에 실행됨
> - `beforeAll, beforeEach, afterEach, afterAll` 모두 describe안에서 동작

#### 테스트 잠깐 미루기 - skip, todo

> - `test.skip`, `test.todo`, `describe.skip`
> - `xdescribe`, `xit`, `xtest`

#### 날짜/시간 테스트 + expect.assertions

> - `expect.assertions(1);`으로 expect호출 횟수 테스트

> ```ts
> test("3일 후를 리턴한다", () => {
>   jest.useFakeTimers().setSystemTime(new Date(2024, 3, 9));
>   console.log(new Date());
>   expect(after3days()).toStrictEqual(new Date(2024, 3, 12));
> });
>
> test("0.1+0.2는 0.3", () => {
>   expect(0.1 + 0.2).toBeCloseTo(0.3); // 부동소수점 문제
> });
>
> afterEach(() => {
>   jest.useRealTimers(); // 원래 시간되돌려놓기
> });
>
> test("시간아 빨리가라!", (done: jest.DoneCallback) => {
>   expect.assertions(1);
>   jest.useFakeTimers();
>   timer((message: string) => {
>     expect(message).toBe("success");
>     done();
>   });
>   // jest.runAllTimers();
>   jest.advanceTimersByTime(10_000); // 10초 흐르게
> });
> ```

#### 호출 순서 테스트, mock 객체, jest-extended, mock 객체의 활용

> jest.fn을 통해서 spy함수로 만들거나 spy를 심는것도 Mocking의 일부(사이드 이펙트에서 자유로움)
>
> - 함수가 호출되었는지
> - 함수가 어떤 인수로 호출되었는지
> - 횟수나 인수 이런거보다 순서가 더 중요할 때가 있다.
>
> - `spy1.mock.invocationCallOrder[0]`가독성의 문제로 jest-extended 사용
>   > - 전역 타입 확장
>   > - `jest-extended`설치 후 global.d.ts를 `import "jest-extended";`명시 후 추가
>   > - tsconfig.json의 include에 컴파일할 파일 지정하기 위해 global.d.ts추가하여 인식
> - 결국에는 mock객체로 만들어낸 것들이라 편의성 및 가독성을 위해 사용하는 것
>
> ```ts
> test("first->second->third", () => {
>   const spy1 = jest.fn(first);
>   const spy2 = jest.fn(second);
>   const spy3 = jest.fn(third);
>   (spy1 as any)(1, 2, 3); // ts 즉시호출
>   spy2();
>   (spy1 as any)("hello");
>   spy3();
>   spy1();
>   expect(spy1.mock.invocationCallOrder[0]).toBeLessThan(
>     spy2.mock.invocationCallOrder[0]
>   );
>   expect(spy3.mock.invocationCallOrder[0]).toBeGreaterThan(
>     spy2.mock.invocationCallOrder[0]
>   );
> });
>
> test("first->second->third 2", () => {
>   const spy1 = jest.fn(first);
>   const spy2 = jest.fn(second);
>   const spy3 = jest.fn(third);
>   (spy1 as any)(1, 2, 3);
>   spy2();
>   (spy1 as any)("hello");
>   spy3();
>   spy1();
>   expect(spy1).toHaveBeenCalledBefore(spy2);
>   expect(spy3).toHaveBeenCalledAfter(spy2);
> });
>
> test("인수의 일부 테스트", () => {
>   const fn = jest.fn();
>   fn({
>     a: {
>       b: {
>         c: "hello",
>       },
>       d: "bye",
>     },
>     e: ["f"],
>   });
>   expect(fn).toHaveBeenCalledWith({
>     a: {
>       b: {
>         c: "hello",
>       },
>       d: "bye",
>     },
>     e: ["f"],
>   }); // 무지성 복사
>   expect(fn.mock.calls[0][0].a.b.c).toBe("hello"); // 특정 인수만 테스트
> });
> ```

#### 모듈 모킹하기(jest.mock)

> 모듈이나 메서드, 속성 테스트에 일일이 jest.fn()을 사용하기보다는 jest.mock을 써보자
>
> - 적용 이후 모듈 파일의 메서드를 통째로 jest.spyOn적용
>   > - jest.spyOn은 기존 객체의 메서드를 감시하고, jest.fn은 새로운 모의 함수를 생성하는 데 사용
> - prop은 적용되지 않음
>   > - jest.replaceProperty(obj, "prop", "replaced");로 대체 가능
> - jest.mock의 가장 큰 특징 중 하나는 호이스팅된다는 점.
>   > - 호이스팅 방지하려면 jest.spyOn을 사용해야, 물론 jest.mock으로 특정 메서드에만 임의 값(mock이나 else)을 return하도록 가능하긴함.
>   > - 최상위(가장 상단에)에서 작성하는 것을 추천
>
> 파일 자체를 통째로 수정할 때는 jest.mock
>
> - `jest.mock("./module");` -> `__mocks__/module.ts`처럼 mocks폴더 안에서 동일한 파일 이름으로 전체를 대체 가능 (수동모킹)
>
> 파일을 어떻게 수정할지 지정 (자동모킹)
>
> - `jest.mock("./module", () => {return {obj:{a: 'b'}}});`
>
> <b>TypeScript에서 import와 export는 ESM 구문이지만, 컴파일러 설정에 따라 CJS 또는 ESM으로 변환되어 출력될 수 있음. tsconfig.json에 기반해서 컴파일하기 때문</b>
>
> - CJS: require는 동적이며, `코드 실행 시점`(동기적)에 모듈이 로드되고 실행됩니다.
> - ESM: import는 정적이며, `코드 실행 전`(`호이스팅` 된 것처럼 동작)에 모듈이 미리 로드됩니다.
>
>   > - 이는 모듈의 의존성을 미리 분석하고 최적화할 수 있게 해줍니다.
>
> - `jest.mock("axios");` -> 속성들은 모킹 안돼고 함수들만 모킹되어(spyOn) 있다.
> - node_modules와 동일한 위치에 **\_\_mocks\_\_**폴더를 만들어서 axios와 동일한 이름으로
>   > - jest.config.js에 rootDir을 'src' -> '.'(node_modules)포함시켜야해서
>   > - <b>'\_\_mocks\_\_': 테스트하고자 하는 모듈의 root안에 같이 있어야</b>
>
> jest.requireActual: 원본을 살리는
>
> ```ts
> jest.mock("./module"); // 모듈 파일의 모든 메서드에 spyOn적용, 수동 모킹(__mocks__)
> jest.mock("axios"); // jest.mock은 호이스팅
> import { obj } from "./module"; // 자동 모킹
> import axios from "axios";
>
> test("모듈을 전부 모킹", () => {
>   jest.replaceProperty(obj, "prop", "replaced");
>   console.log(obj);
> });
>
> test("axios를 전부 모킹", () => {
>   console.log(axios);
> });
> ```
>
> - 특정한 메서드나 props를 수정 가능
>
> ```ts
> export default {
>   ...jest.requireActual("axios"),
>   haha: "통째로 바꿨지롱",
> };
> ```

#### requireActual로 원본 모듈 가져오기

> 모킹을 할 때 객체 메서드들만 모킹이 되는게 아니라 클래스의 메서드들도 파악해서 모킹이 된다.
>
> - `jest.requireActual`: 원본을 가져오거나 전체중에 특정한 메서드만 모킹
>
> 함수나 클래스 메서드들도 알아서 모킹이 된다.
>
> ```ts
> jest.mock("./mockFunc", () => {
>   return {
>     ...jest.requireActual("./mockFunc"),
>     double: jest.fn(), // inline 모킹, 리턴값으로 모킹이 가능
>   };
> });
> jest.mock("./mockClass");
> import func from "./mockFunc";
> import c from "./mockClass";
>
> it("func와 c가 정의되어 있어야 한다.", () => {
>   const original = jest.requireActual("./mockFunc");
>   console.log(original);
>   console.log("__");
>   console.log(func);
>   expect(func).toBeDefined();
>   expect(c).toBeDefined();
> });
> ```

#### 테스트간 간섭 끊기 - jest.resetModules, test.only

> js에선 모듈을 dynamic import하거나 require하면 그 모듈이 캐싱되어 있음.
>
> - 두번째 테스트 c의prop에서 '===' 수행시 같은 객체임을 알 수 있음
>   > - `jest.resetModules();`로 간섭 끊기 가능
> - 각 테스트간 독립적으로 운용해야
> - `.only` keyword가 붙은 테스트를 제외한 테스트는 스킵
>   > - 붙었을 때 에러가 난다면 다른 테스트에 영향을 받고 있다는 의미
>
> ```ts
> // beforeEach(() => {
> //    jest.resetModules();
> // });
>
> it("first import", async () => {
>   const c = await import("./mockClass"); // dynamic Import || require('./mockClass'){e.g. Node.js}
>   (c as any).prop = "hello";
>   expect(c).toBeDefined();
> });
>
> // it.only("second import", async () => {
> it("second import", async () => {
>   const c = await import("./mockClass");
>   expect((c as any).prop).toBe("hello");
> });
> ```

#### 테스트 중복 줄이기 - each

> 고차함수 형태로 존재
>
> - 흔하지는 않지만 반복되는 형태를 줄일 수 있음
>
> ```ts
> it.skip("1 더하기 1은 2", () => {
>   expect(1 + 1).toBe(2);
> });
> it.skip("2 더하기 3은 5", () => {
>   expect(2 + 3).toBe(5);
> });
> it.skip("3 더하기 4은 7", () => {
>   expect(3 + 4).toBe(7);
> });
>
> it.each([
>   { a: 1, b: 1, c: 2 },
>   { a: 2, b: 3, c: 5 },
>   { a: 3, b: 4, c: 7 },
> ])("$a 더하기 $b는 $c", ({ a, b, c }) => {
>   expect(a + b).toBe(c);
> });
> ```

#### 유사한 값도 통과시키기 - expect.any, expect.closeTo

> `jest-extended`
>
> - `expect.anthing`: null과 undefined만 아닌 모든 값을 의미
>
> ```js
> test("map calls its argument with a non-null argument", () => {
>   const mock = jest.fn();
>   [1].map((x) => mock(x));
>   expect(mock).toHaveBeenCalledWith(expect.anything());
>   // expect().toBeUndefined
>   // expect().not.toBeNull
> });
> ```
>
> - `expect.any(constructor)`: math.random 같은게 있을 떄 많이 사용. 매번 달라지는 값을 테스트하는 경우
>   > - math.random을 spyOn으로 고정값으로 바꾸는
>   >
>   > ```js
>   > // math.test.js
>   > import { getRandomNumber } from "./math";
>   >
>   > describe("getRandomNumber", () => {
>   >   it("should return a mocked random number", () => {
>   >     // Math.random을 spyOn으로 모킹
>   >     const randomSpy = jest.spyOn(Math, "random").mockReturnValue(0.5);
>   >
>   >     const result = getRandomNumber();
>   >
>   >     // 모킹된 값이 반환되었는지 확인
>   >     expect(result).toBe(0.5);
>   >
>   >     // spyOn을 복구
>   >     randomSpy.mockRestore();
>   >   });
>   > });
>   > ```
>   >
>   > - 혹은 아래의 예제 처럼 `expect.any(Number)` 사용가능, 생성자를 넣어주기
>   >   > - `expect(obj()).toStrictEqual({ a: expect.any(Number) });`
>
> ```js
> class Cat {}
> function getCat(fn) {
>   return fn(new Cat());
> }
>
> test("randocall calls its callback with a class instance", () => {
>   const mock = jest.fn();
>   getCat(mock);
>   expect(mock).toHaveBeenCalledWith(expect.any(Cat));
> });
>
> function randocall(fn) {
>   return fn(Math.floor(Math.random() * 6 + 1));
> }
>
> test("randocall calls its callback with a number", () => {
>   const mock = jest.fn();
>   randocall(mock);
>   expect(mock).toHaveBeenCalledWith(expect.any(Number));
> });
> ```
>
> - `expect.any(constructor)`: 부동소수점 같은 것 테스트

#### 알아두면 유용한 실행 옵션 - runInBand, watch, detectOpenHandles

> [--runInBand](https://jestjs.io/docs/cli#--runinband)
>
> - 테스트를 싱글 스레드에서 돌게, jest는 기본적으로 테스트를 멀티스레드에서 돌림
>   > - cpu가 8개라면 7로 돌림. 메인 스레드가 돌아야하기 때문에 영향을 미치지 않기위해서, user의 cpu-1개의 스레드를 생성해서 동시에 돌림
>   > - cpu가 하나밖에 없거나 너무 느리면 runInBand를 사용해서 싱글스레드로 돌아가서 성능이 향상되는 효과가 있다
> - runInBand를 붙여서 실행하거나 뺴서 실행했을 때 빠른 경우를 비교해보는 것도 하나의 방법
> - Monorepo의 경우 모든 프로젝트의 테스트를 돌리면 쓰레드가 너무 많이 생성되는 문제가 생길 수 있음
>   > - 예를 들어 5개의 패키지가 합쳐져 있고 CPU가 8개라면 7개가 생성되는게 아니라 35개의 쓰레드가 생성된다. 각각의 패키지들이 전부 각각 알아서 7개씩 생성하기 때문
>   >   > - 이 경우에 runInBand를 사용하면 쓰레드를 5개만 생성. 안하는 경우엔 35개 생성
>
> [--maxWorkers=<num>|<string>](https://jestjs.io/docs/cli#--maxworkersnumstring)
>
> - 해당 명령어로 cpu수를 조절 가능
>   > - 상황에 맞게 최적값을 고려하는것도 생각해봐야
> - `For environments with variable CPUs available, you can use percentage based configuration: --maxWorkers=50%`
>
> [--watch](https://jestjs.io/docs/cli#--watch), `--watchAll`
>
> - --watch: 수정한 소스코드의 테스트만
> - --watchAll: 전체 테스트 파일을 다시 실행
>
> [--detectOpenHandles](https://jestjs.io/docs/cli#--detectopenhandles)
>
> - `setInterval`을 사용하면 무한히 도는데 test가 끝남에도 계속 돌기에 memory leak 발생.
>   > - 실제 서버에 요청을 보냈는데 10분이 걸리거나
>   > - DB 후에 테스트가 끝났는데도 데이터베이스 연결을 끊지를 않으면 스크립트가 종료되지 않음
>   >   > - `Test leaking`이라고 하는데 이것을 감지하려면 `detectOpenHandles`을 추천함
>   > - `detectOpenHandles`보다는 timer인 경우 clearAllTimers를 사용하고 db는 db.close()같은 걸로 db 연결 종료
>
> ```js
> beforeEach(() => {
>   jest.useFakeTimers();
> });
>
> it("openHandles", () => {
>   setInterval(() => {
>     console.log("hi");
>   });
>   expect(1).toBe(1);
> });
>
> afterAll(() => {
>   jest.clearAllTimers();
> });
> ```
