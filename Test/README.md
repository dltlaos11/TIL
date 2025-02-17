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

#### installation

```sh
npm i jest -D

npm i ts-jest @types/jest -D

npm i babel-jest @babel/core @babel/preset-env

npm i cross-env // 윈도우 호환용 패키지

npm init jest@latest // jest.config.js 세팅 명령어
```

#### execution

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

> toStrictEqual, toMatchObject
>
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
>
> toHaveBeenCalled 시리즈와 jest.fn, jest.spyOn
>
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
>
> mockImplementation, mockReturnValue
>
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
>
> 콜백함수 테스트
>
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

```

```
