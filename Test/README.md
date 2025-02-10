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
