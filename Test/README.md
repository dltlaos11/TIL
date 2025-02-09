### Ts 및 Jest 세팅

> - package.json에 type:”module” → cjs에서 ecma 모듈로 변경
> - ts는 기본적으로 cjs
> - ecma모듈은 named export, export default
> - cjs는 require, module.exports
> - `npx ts-jest config:init`으로 jest 관리 혹은 `package.json`에서 관리 가능

> ts-jest는 TypeScript로 작성된 테스트 코드를 Jest가 실행할 수 있도록 해주는 TypeScript 전처리기(preprocessor)
>
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
