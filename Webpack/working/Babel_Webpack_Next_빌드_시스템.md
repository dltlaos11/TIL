# Babel과 Webpack 완벽 가이드: 빌드 시스템 이해하기

> 클래스 컴포넌트를 함수형으로 변환하며 얻은 Babel, Webpack, Next.js 빌드 시스템 인사이트

## 📚 목차

- [1. 함수형 컴포넌트 변환 패턴](#1-함수형-컴포넌트-변환-패턴)
- [2. Babel의 역할 - 환경별 구분](#2-babel의-역할---환경별-구분)
- [3. Babel vs Webpack의 역할 분담](#3-babel-vs-webpack의-역할-분담)
- [4. Webpack의 모듈 이해 능력](#4-webpack의-모듈-이해-능력)
- [5. next-transpile-modules의 진짜 역할](#5-next-transpile-modules의-진짜-역할)
- [6. 전체 빌드 프로세스](#6-전체-빌드-프로세스-nextjs)
- [7. 테스트 환경 vs 빌드 환경](#7-테스트-환경-vs-빌드-환경)
- [8. useState vs useMemo 선택 기준](#8-usestate-vs-usememo-선택-기준)

---

## 1. 함수형 컴포넌트 변환 패턴

### Store/ViewModel 생성

```javascript
// ✅ 올바른 방법: useState lazy initializer
const [viewModel] = useState(() => {
  return new FileWrapperListAdminViewModel(...)
})

// ❌ 잘못된 방법: useMemo
const viewModel = useMemo(() => {
  return new FileWrapperListAdminViewModel(...)
}, [])
```

**이유**:

- `useState`의 lazy initializer는 첫 렌더링에만 실행 (의미론적 보장)
- `useMemo`는 React가 필요시 재계산 가능 (성능 최적화일 뿐)

### 라이프사이클 매핑

| 클래스 컴포넌트                            | 함수형 컴포넌트                 |
| ------------------------------------------ | ------------------------------- |
| `constructor`                              | `useState` 초기화               |
| `componentDidMount` + `componentDidUpdate` | `useEffect`                     |
| `shouldComponentUpdate`                    | `React.memo` + 커스텀 비교 함수 |

### 예시 코드

```javascript
// 클래스 컴포넌트
class FileWrapperListAdminMediator extends React.Component {
  constructor(props) {
    super(props)
    this.viewModel = new FileWrapperListAdminViewModel(...)
  }

  shouldComponentUpdate(nextProps) {
    return !isQueryEqual(this.props.query, nextProps.query)
  }

  componentDidUpdate(prevProps) {
    if (!isQueryEqual(prevProps.query, this.props.query)) {
      // Model 업데이트
    }
  }
}

// ↓ 함수형 컴포넌트

const FileWrapperListAdminMediator = (props) => {
  // ViewModel은 한 번만 생성
  const [viewModel] = useState(() => {
    return new FileWrapperListAdminViewModel(...)
  })

  // componentDidUpdate 로직
  useEffect(() => {
    // query 변경 시 Model 업데이트
  }, [props.query])

  return <FileWrapperListAdminView viewModel={viewModel} {...props} />
}

// React.memo로 불필요한 리렌더링 방지
const MemoizedMediator = React.memo(
  FileWrapperListAdminMediator,
  (prevProps, nextProps) => {
    return isQueryEqual(prevProps?.query, nextProps?.query)
  }
)
```

---

## 2. Babel의 역할 - 환경별 구분

### 테스트 환경 (NODE_ENV === 'test')

```javascript
const presets = [
  "@babel/preset-react", // JSX → React.createElement()
  "@babel/preset-env", // ES modules → CommonJS
];
```

**왜 필요한가?**

- Node.js는 CommonJS 환경 (`require`/`module.exports`)
- Jest는 번들러 없이 Node.js에서 직접 실행
- `import/export`를 `require/module.exports`로 변환 필요

### 빌드 환경 (NODE_ENV !== 'test')

```javascript
const presets = [
  "@babel/preset-react", // JSX만 변환
];
```

**왜 JSX만?**

- Webpack/Next.js가 모듈 시스템 처리
- ES modules를 그대로 둬도 Webpack이 번들링

### babel.config.js 전체 예시

```javascript
module.exports = (api) => {
  api.cache(true);

  const presets =
    process.env.NODE_ENV === "test"
      ? [
          "@babel/preset-react",
          ["@babel/preset-env", { targets: { node: "current" }, loose: true }],
        ]
      : ["@babel/preset-react"];

  const plugins = [
    ["@babel/plugin-proposal-decorators", { legacy: true }],
    ["@babel/plugin-proposal-class-properties", { loose: true }],
    ["@babel/plugin-syntax-dynamic-import"],
    ["@babel/plugin-proposal-optional-chaining"],
  ];

  return { presets, plugins };
};
```

---

## 3. Babel vs Webpack의 역할 분담

### 도구 비교

| 도구        | 타입                     | 역할        | 처리 대상               |
| ----------- | ------------------------ | ----------- | ----------------------- |
| **Babel**   | Transpiler (코드 변환기) | 문법 변환   | JSX → JS, ES6+ → ES5    |
| **Webpack** | Bundler (모듈 번들러)    | 파일 합치기 | 여러 파일 → 하나의 번들 |

### 처리 순서

```
소스 코드 (JSX + ES modules)
  ↓
[Babel]
  - JSX → React.createElement()
  - (테스트 시) ES modules → CommonJS
  ↓
표준 JavaScript
  ↓
[Webpack]
  - 여러 파일 합치기
  - 모듈 시스템 처리
  - 코드 스플리팅
  - 최적화 (minify, tree shaking)
  ↓
브라우저용 번들 파일
```

### 구체적인 예시

```javascript
// 1. 소스 코드
import React from "react";
import { Button } from "antd";

const App = () => <div className="app">Hello</div>;

// 2. Babel 처리 후
import React from "react";
import { Button } from "antd";

const App = () =>
  React.createElement(
    "div",
    { className: "app" },
    "Hello"
  )(
    // 3. Webpack 번들링 후 (간소화)
    function () {
      var React = __webpack_require__("react");
      var Button = __webpack_require__("antd").Button;
      var App = function () {
        return React.createElement("div", { className: "app" }, "Hello");
      };
    }
  )();
```

---

## 4. Webpack의 모듈 이해 능력

Webpack은 다양한 모듈 시스템을 **모두 이해**하고 처리할 수 있습니다.

### 지원하는 모듈 시스템

```javascript
// ✅ ES Modules
import X from 'y'
export default X

// ✅ CommonJS
const X = require('y')
module.exports = X

// ✅ AMD
define(['y'], function(Y) { ... })

// ✅ 혼용 가능!
import React from 'react'        // ES Module
const moment = require('moment') // CommonJS
```

### 왜 @babel/preset-env 없이도 되는가?

```javascript
// Babel이 ES modules를 그대로 둬도
import React from "react";

// Webpack이 알아서 처리
var React = __webpack_require__("react");
```

**결론**: Webpack이 모듈 시스템을 처리하므로, Babel은 JSX만 변환하면 됨!

---

## 5. next-transpile-modules의 진짜 역할

### 잘못된 이해 ❌

"ES 모듈을 트랜스파일한다"

### 올바른 이해 ✅

"특정 node_modules 패키지를 Babel 처리 대상에 포함시킨다"

### Monorepo 문제 상황

```
기본 동작:
✅ src/ 폴더 → Babel로 처리
❌ node_modules/ → Babel 처리 안 함 (이미 빌드된 거라 가정)

문제:
packages/piip-customers-modules (소스 코드)
  ↓ (심볼릭 링크)
node_modules/@sejinmind/piip-customers-modules
  ↓
❌ "node_modules니까 Babel 안 해!"
  ↓
JSX 에러 발생!
```

### 해결 방법

```javascript
// next.config.js
const withTM = require("next-transpile-modules")([
  "@sejinmind/piip-ui-components",
  "@sejinmind/piip-cases-modules",
  "@sejinmind/piip-customers-modules", // "이것들도 Babel로 처리해줘!"
]);
```

### 처리 흐름

```
[1] next-transpile-modules 설정
    "이 패키지들은 node_modules지만 Babel 처리해!"

[2] Babel 실행
    - src/ 폴더 처리 ✅
    - 지정된 monorepo 패키지들 처리 ✅
    - 나머지 node_modules 무시 ✅

[3] Webpack 번들링
    모든 처리된 코드를 번들링
```

---

## 6. 전체 빌드 프로세스 (Next.js)

### 개발 모드 (yarn dev)

```bash
yarn dev
  ↓
Next.js 개발 서버 시작
  ↓
파일 변경 감지
  ↓
[Babel] JSX 변환 + 지정된 패키지 처리
  ↓
[Webpack] Hot Module Replacement (HMR)
  ↓
브라우저 자동 새로고침
```

### 프로덕션 빌드 (yarn next:build)

```bash
yarn next:build
  ↓
[1] next-transpile-modules
    Babel 처리 대상 설정
  ↓
[2] Babel 실행
    - JSX → React.createElement()
    - src/ + 지정된 monorepo 패키지들
  ↓
[3] Webpack 실행
    - 모듈 번들링
    - 코드 스플리팅
    - Tree shaking
    - Minification
    - 최적화
  ↓
[4] 결과물 생성
    .next/ 폴더에 최적화된 번들 파일들
```

### 디렉토리 구조

```
.next/
├── static/
│   ├── chunks/          # 코드 스플릿된 청크들
│   ├── css/             # 추출된 CSS
│   └── media/           # 이미지, 폰트 등
├── server/
│   └── pages/           # 서버 사이드 렌더링용
└── cache/               # 빌드 캐시
```

---

## 7. 테스트 환경 vs 빌드 환경

### 비교표

| 환경        | 번들러     | Babel 역할     | ES modules 처리 | 실행 위치 |
| ----------- | ---------- | -------------- | --------------- | --------- |
| **Jest**    | ❌ 없음    | JSX + ES → CJS | Babel이 처리    | Node.js   |
| **Next.js** | ✅ Webpack | JSX만 변환     | Webpack이 처리  | Browser   |

### Jest 환경

```javascript
// 테스트 파일
import React from "react";
import { render } from "@testing-library/react";

// ↓ Babel + @babel/preset-env

const React = require("react");
const { render } = require("@testing-library/react");

// ↓ Node.js에서 직접 실행
```

### Next.js 빌드 환경

```javascript
// 소스 파일
import React from "react";
const App = () => <div>Hello</div>;

// ↓ Babel (@babel/preset-react만)

import React from "react";
const App = () =>
  React.createElement(
    "div",
    null,
    "Hello"
  )(
    // ↓ Webpack 번들링

    function () {
      var React = __webpack_require__("react");
      // ... 번들 코드
    }
  )();
```

### jest.config.js 설정

```javascript
module.exports = {
  testEnvironment: "jsdom", // 브라우저 환경 시뮬레이션
  moduleNameMapper: {
    // CSS 파일을 빈 객체로 모킹
    "\\.(css|less|scss|sass)$": "<rootDir>/__test__/styleMock.js",
  },
};
```

---

## 8. useState vs useMemo 선택 기준

### 핵심 차이

```javascript
// useState - 의미론적 보장
const [value] = useState(() => expensiveComputation());
// ✅ 첫 렌더링에만 실행
// ✅ 절대 재계산 안 됨

// useMemo - 성능 최적화
const value = useMemo(() => expensiveComputation(), []);
// ⚠️ React가 필요하다고 판단하면 재계산 가능
// ⚠️ 보장이 아님 (힌트일 뿐)
```

### 공식 문서 인용

> You may rely on `useMemo` as a performance optimization, not as a semantic guarantee. In the future, React may choose to "forget" some previously memoized values and recalculate them on next render.

### 사용 기준

| 상황                     | 선택       | 이유             |
| ------------------------ | ---------- | ---------------- |
| Store/ViewModel 인스턴스 | `useState` | 재생성되면 안 됨 |
| 비싼 계산 결과 캐싱      | `useMemo`  | 재계산 가능      |
| 컴포넌트 상태            | `useState` | 상태 관리        |
| 참조 동일성 유지         | `useMemo`  | 최적화           |

### 예시 코드

```javascript
// ✅ Store 인스턴스 - useState
const [casesStore] = useState(() =>
  CasesAdminStore.createInstance({
    [CasesAdminStore.type.FILE_WRAPPER_MODEL]: {
      service: FileWrapperApolloService.createInstance(apolloClient),
    },
  })
);

// ✅ 비싼 계산 캐싱 - useMemo
const expensiveValue = useMemo(() => {
  return heavyComputation(data);
}, [data]);

// ✅ 콜백 메모이제이션 - useCallback
const handleClick = useCallback(() => {
  doSomething(id);
}, [id]);
```

---

## 🎓 핵심 요약

### 5가지 핵심 개념

1. **Babel = 코드 변환기** (Transpiler)

   - JSX → JavaScript
   - ES6+ → ES5
   - 환경에 따라 역할 다름

2. **Webpack = 모듈 번들러** (Bundler)

   - 여러 파일 → 하나의 번들
   - 코드 스플리팅, 최적화
   - 다양한 모듈 시스템 이해

3. **Babel + Webpack = 세트**

   - Babel이 문법 변환
   - Webpack이 파일 합침
   - Next.js가 orchestration

4. **환경별 Babel 설정**

   - 테스트: JSX + ES modules 모두 변환
   - 빌드: JSX만 변환 (Webpack이 모듈 처리)

5. **next-transpile-modules**
   - 트랜스파일러 아님
   - Babel 처리 대상 지정
   - Monorepo 필수 설정

### 트러블슈팅 체크리스트

```markdown
❓ Jest에서 `import` 에러가 나요
→ babel.config.js에 @babel/preset-env 추가

❓ Monorepo 패키지에서 JSX 에러가 나요
→ next.config.js의 next-transpile-modules에 패키지 추가

❓ VSCode Jest 확장이 테스트를 못 찾아요
→ .vscode/settings.json의 jest.virtualFolders에 패키지 추가

❓ Store가 리렌더링마다 재생성돼요
→ useMemo 대신 useState(() => ...) 사용
```

---

## 📚 참고 자료

- [Babel 공식 문서](https://babeljs.io/docs/en/)
- [Webpack 공식 문서](https://webpack.js.org/)
- [Next.js 공식 문서](https://nextjs.org/docs)
- [React Hooks 공식 문서](https://react.dev/reference/react)
- [next-transpile-modules](https://github.com/martpie/next-transpile-modules)
