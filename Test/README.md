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
