# Next.js 14 업그레이드 후 `@react-querybuilder/antd` dynamic import가 화면에 안 뜨던 이유와 해결

## 환경

- React 16 + Next.js 9 → React 18 + Next.js 14 마이그레이션
- Pages Router
- 모노레포 (Lerna + Yarn workspaces)
- `dynamic(() => import('@react-querybuilder/antd'), { ssr: false })`로 감싼 컴포넌트가 **뷰에 렌더되지 않음**

---

## 증상

브라우저 콘솔에서 dynamic import 실행 시 아래 에러 발생:

```
ReferenceError: require is not defined
  at react-querybuilder_antd.mjs:4:31
  at ../../node_modules/@react-querybuilder/antd/dist/react-querybuilder_antd.mjs
    (node_modules_react-querybuilder_antd_dist_react-querybuilder_antd_mjs.js:18:1)
```

Next dynamic chunk 파일(`node_modules_react-querybuilder_antd_dist_react-querybuilder_antd_mjs.js`)은 네트워크로 로드되지만, 모듈 평가 단계에서 에러가 발생하여 컴포넌트 렌더 실패.

---

## 원인 분석

### 1. Next.js 9 → 14 전환 시 webpack 4 → 5로 업그레이드됨

webpack은 별도 설치 없이 Next.js 내부 의존성으로 포함된다.

```
Next.js 9  → webpack 4 (next 패키지 내부)
Next.js 14 → webpack 5 (next 패키지 내부)
```

### 2. webpack 5는 package.json의 `exports` 필드를 우선 적용

`@react-querybuilder/antd`의 package.json:

```json
{
  "main": "./dist/cjs/index.js",
  "exports": {
    ".": {
      "import": { "default": "./dist/react-querybuilder_antd.mjs" },
      "require": { "default": "./dist/cjs/index.js" }
    }
  }
}
```

- **webpack 4**: `main` 필드 우선 → `dist/cjs/index.js` (CJS) 선택
- **webpack 5**: `exports` 필드 우선 → `import` 조건 → `dist/react-querybuilder_antd.mjs` (ESM) 선택

### 3. `transpilePackages`에 포함 시 webpack+babel이 `.mjs`를 CJS로 트랜스파일

`next.config.js`에 아래 설정이 있었음:

```js
transpilePackages: [
  "@sejinmind/piip-ui-components",
  // ...
  "@react-querybuilder/antd", // ← 이게 문제
];
```

#### `transpilePackages`가 필요한 이유

이 모노레포에서 내부 패키지(`@sejinmind/piip-ui-components` 등)는 `src/` 원본을 그대로 노출한다:

```json
// piip-ui-components/package.json
{
  "main": "src/index.js",
  "files": ["src"]
}
```

`src/` 안에는 JSX, ES module syntax가 그대로 있다:

```jsx
// src/v2/components/Button.jsx
export const Button = ({ children }) => <button>{children}</button>;
//                                       ↑ JSX — Node.js는 이해 못함
```

Node.js는 JSX를 이해하지 못한다. Next.js는 기본적으로 `node_modules`를 트랜스파일하지 않으므로, 이 패키지들을 `transpilePackages`에 등록해야 webpack+babel이 JSX → `React.createElement()` 변환을 수행한다.

```
transpilePackages: ['@sejinmind/piip-ui-components']
  ↓
webpack+babel이 src/*.jsx를 직접 처리
  ↓
JSX → React.createElement() 변환
  ↓
브라우저/서버에서 실행 가능한 번들 생성
```

즉 `transpilePackages`는 **"빌드 없이 src를 그대로 배포하는 모노레포 내부 패키지"** 를 위한 옵션이다.

#### 외부 패키지에 적용하면 안 되는 이유

`@react-querybuilder/antd`는 이미 빌드된 패키지인데 `transpilePackages`에 포함시키면:

```
webpack+babel이 .mjs 소스를 CJS로 트랜스파일
  ↓
번들 eval() 안에 require() 코드 생성
  ↓
브라우저에서 require is not defined → 모듈 평가 실패
  ↓
dynamic import reject → 컴포넌트 렌더 안 됨
```

### 4. 왜 Next.js 9에서는 동작했나

webpack 4는 `exports` 필드를 무시하고 `main` 필드(`dist/cjs/index.js`)를 선택했기 때문에, `transpilePackages`에 포함되어도 CJS 파일을 처리하여 문제가 없었다.

---

## Next.js 3가지 모듈 로딩 흐름

Next.js는 단계에 따라 모듈을 다른 방식으로 로드한다.

| 단계           | 시점                              | 로드 방식                  | 담당                   |
| -------------- | --------------------------------- | -------------------------- | ---------------------- |
| **빌드**       | `next build` 실행 시              | webpack + babel            | webpack                |
| **서버**       | 서버 프로세스 시작 / 요청 처리 시 | Node.js native `require()` | Node.js (require-hook) |
| **클라이언트** | 브라우저에서 페이지 로드 시       | `<script>`로 청크 fetch    | 브라우저               |

### 빌드 단계

```
src/*.jsx (raw JSX, ES module)
    ↓ webpack 의존성 그래프 분석
    ↓ babel: JSX → React.createElement(), ES → CJS 변환
.next/server/pages/xxx.js   ← SSR용 서버 번들
.next/static/chunks/xxx.js  ← CSR용 클라이언트 청크
```

### 서버 단계와 require-hook

```
node server.js 실행
  → Next.js 프레임워크를 native require()로 로드
  → 요청이 오면 .next/server/pages/xxx.js를 require()
  → 번들 안에 남아있는 require() 코드도 native로 실행
```

**require-hook**은 Next.js가 Node.js의 `require()`를 중간에 가로채는(hook) 레이어다. 일부 모듈의 경로를 리다이렉트하거나 처리를 수정하는 용도로 사용된다. 중요한 점은:

> webpack `config.resolve.alias`는 빌드 타임에만 적용된다.
> require-hook을 통한 서버 런타임 `require()`에는 alias가 적용되지 않는다.

이 때문에 `transpilePackages`에 `@react-querybuilder/antd`가 있으면 CJS 번들(`dist/cjs/index.js`) 안의 `require("antd/es/...")` 코드가 서버 런타임에 실행되어 Node.js 20 strict ESM 처리에 의해 거부된다:

```
dist/cjs/index.js 안:
  require("antd/es/date-picker/generatePicker/index.js")
    ↓
require-hook → Node.js 20이 antd/es/*.js를 ESM으로 인식
    ↓
ERR_MODULE_NOT_FOUND: antd/es/_util/type
```

### 클라이언트 단계

```
브라우저가 HTML 수신
  → <script src="/_next/static/chunks/xxx.js"> 파싱
  → HTTP로 청크 fetch
  → dynamic({ ssr: false }) 컴포넌트는 hydration 후 추가 청크 fetch
```

`dynamic({ ssr: false })`으로 선언된 컴포넌트는 별도 청크로 분리되어 브라우저 Network 탭에서 lazy load 요청을 직접 확인할 수 있다.

---

## 번들 비교

### 문제 케이스 (`transpilePackages`에 포함)

```js
// eval() 안에 require()가 생성됨
var _interopRequireDefault2 = require(".../interopRequireDefault.js");
var _radio = _interopRequireDefault2(require("antd/lib/radio"));
var _index = _interopRequireDefault2(
  require("antd/es/date-picker/generatePicker/index.js"),
);
// → 브라우저에서 require is not defined
```

### 정상 케이스 (`transpilePackages`에서 제거)

```js
// webpack이 ESM 번들로 처리 → __webpack_require__ 사용
__webpack_require__.d(__webpack_exports__, { QueryBuilderAntD: ... });
var antd = __webpack_require__("../../node_modules/antd/es/index.js");
var datePicker = __webpack_require__("../../node_modules/antd/es/date-picker/generatePicker/index.js");
// → 브라우저에서 정상 동작 (__webpack_require__는 webpack 런타임이 제공)
```

`transpilePackages` 없으면 webpack 5가 `.mjs`를 **ESM 모듈 그대로** 처리하므로 `__webpack_require__`로 관리되어 브라우저에서 정상 동작한다.

---

## 해결 방법

### 방법 1: `transpilePackages`에서 제거 (가장 단순)

```js
// next.config.js
transpilePackages: [
  "@sejinmind/piip-ui-components",
  // '@react-querybuilder/antd',  ← 제거
];
```

webpack이 패키지를 "외부 라이브러리"로 취급하여 이미 빌드된 ESM 번들을 그대로 사용한다.

컴포넌트 사용:

```jsx
// queryBuilder.js
const QueryBuilderWithAntD = dynamic(
  () =>
    import("@react-querybuilder/antd").then((mod) => {
      const { QueryBuilderAntD } = mod;
      const Wrapped = (props) => (
        <QueryBuilderAntD>
          <QueryBuilder {...props} />
        </QueryBuilderAntD>
      );
      return { default: Wrapped };
    }),
  { ssr: false },
);
```

---

### 방법 2: `transpilePackages`에 유지 + webpack alias로 CJS 강제

`transpilePackages`에 포함을 유지해야 하는 경우, webpack alias로 클라이언트 번들에서 CJS 파일을 직접 지정한다.

```js
// next.config.js
const path = require('path')
const rqbAntdRoot = path.dirname(require.resolve('@react-querybuilder/antd/package.json'))

transpilePackages: [
  // ...
  '@react-querybuilder/antd',
],

webpack: (config, { isServer }) => {
  if (!isServer) {
    config.resolve.alias = {
      ...(config.resolve.alias || {}),
      '@react-querybuilder/antd': path.join(rqbAntdRoot, 'dist', 'cjs', 'index.js'),
    }
  }
  return config
},
```

webpack alias로 클라이언트 번들에서 `.mjs` 대신 `dist/cjs/index.js`를 선택하도록 강제한다.

컴포넌트에서는 `QueryBuilderAntD`(provider) 대신 `antdControlElements`를 사용하는 방식으로 변경:

```jsx
// queryBuilder.js
const QueryBuilderWithAntD = dynamic(
  () =>
    import("@react-querybuilder/antd").then((mod) => {
      const m = mod?.default ? { ...mod.default, ...mod } : mod;
      const antdControlElements = m.antdControlElements;
      const Wrapped = (props) => (
        <QueryBuilder {...props} controlElements={antdControlElements} />
      );
      return { default: Wrapped };
    }),
  { ssr: false },
);
```

---

## 검증 과정

### 1. 에러 재현: 모듈 레벨 import (서버에서도 실행됨)

```js
// queryBuilder.js 모듈 레벨에 추가
import("@react-querybuilder/antd")
  .then((m) => console.log("success", m))
  .catch((e) => console.error("failed", e));
```

- 서버 로그: `ERR_MODULE_NOT_FOUND: antd/es/_util/type` (require-hook이 CJS 번들 안의 antd/es를 Node.js 20에서 로드 시도)
- 브라우저 콘솔: `require is not defined`

### 2. CSR 검증: useEffect 안에서만 import

```js
useEffect(() => {
  import("@react-querybuilder/antd")
    .then((m) => console.log("client success", m))
    .catch((e) => console.error("client failed", e));
}, []);
```

- 서버 로그: 에러 없음 (CSR에서만 실행되므로)
- 브라우저 콘솔: `client failed ReferenceError: require is not defined`

→ 서버 문제가 아니라 **CSR에서 브라우저 번들 평가 시 `require()`가 없어서 실패**하는 것임을 확인

### 3. 번들 내용 직접 확인

`.next/static/chunks/node_modules_react-querybuilder_antd_dist_react-querybuilder_antd_mjs.js` 파일을 열어 `require(` 포함 여부로 정상/비정상 판별 가능.

---

## 핵심 교훈

> `transpilePackages`는 raw JSX/ES syntax를 그대로 배포하는 **모노레포 내부 패키지**를 위한 옵션이다.
> 이미 빌드된 외부 패키지(`dist/` 포함)를 `transpilePackages`에 넣으면 webpack+babel이 재처리하면서 오히려 번들이 깨질 수 있다.

> webpack 4 → 5 전환 시 `package.json`의 `exports` 필드 우선 적용으로 선택되는 파일이 달라질 수 있다. 동일한 `transpilePackages` 설정이라도 다른 파일을 선택하여 다른 결과를 낼 수 있다.

---

## `transpilePackages`가 babel-loader로 이어지는 내부 구조

### Next.js webpack-config.js의 exclude 로직

`node_modules/next/dist/build/webpack-config.js`에서 webpack rule의 `exclude` 함수가 이렇게 동작한다:

```js
const codeCondition = {
  test: /\.(tsx|ts|js|cjs|mjs|jsx)$/,
  exclude: (excludePath) => {
    const shouldBeBundled = isResourceInPackages(
      excludePath,
      config.transpilePackages,
    );
    if (shouldBeBundled) return false; // ← exclude 해제 = babel-loader 처리 대상
    return excludePath.includes("node_modules"); // ← 기본: node_modules 제외
  },
};
```

- 기본: `node_modules`는 exclude → babel-loader 처리 안 함
- `transpilePackages`에 있는 패키지: `exclude: false` → babel-loader 처리 대상

### `next/babel`이 적용되는 이유

babel-loader 설정:

```js
{
    loader: require.resolve("./babel/loader/index"),
    options: {
        configFile: babelConfigFile,  // ← 프로젝트의 babel.config.js
    }
}
```

`babel.config.js`의 `presets: ['next/babel']`이 읽히고, `next/babel`이 `preset-env`를 포함한다.

### `next/babel` → `preset-env` 체인 (실제 코드)

`node_modules/next/babel.js` → `node_modules/next/dist/build/babel/preset.js`:

```js
// preset.js 내부
const presetEnvConfig = {
    // In production/development this option is set to `false` so that
    // webpack can handle import/export with tree-shaking
    modules: "auto",
    ...
}

return {
    sourceType: "unambiguous",
    presets: [
        [require("next/dist/compiled/babel/preset-env"), presetEnvConfig],
        [require("next/dist/compiled/babel/preset-react"), ...],
        ...
    ]
}
```

`modules: "auto"` → babel-loader 호출 시 caller 정보를 보고 `modules: false`(webpack) 또는 `modules: "commonjs"`(Jest/Node)를 결정한다.

### webpack이 `__webpack_require__`로 교체하는 조건

webpack이 `import` 문을 `__webpack_require__`로 교체하려면 **`import` 문이 webpack에 도달해야 한다**.

```
babel이 먼저 처리하면:
  import → require() 변환 → webpack은 그냥 통과
  → 브라우저에서 require is not defined

babel이 처리 안 하면 (transpilePackages 제외):
  import 문 그대로 webpack 도달 → __webpack_require__로 교체
  → 브라우저 정상 동작
```

---

## 모듈 시스템 호환성 규칙

문제의 근본은 모듈 시스템 간 호환성이다.

| 호출자    | 대상        | 가능 여부 | 이유                                         |
| --------- | ----------- | --------- | -------------------------------------------- |
| CJS → CJS | `require()` | ✓         | 동기 로드, 동일 시스템                       |
| ESM → ESM | `import`    | ✓         | 비동기 로드, 동일 시스템                     |
| ESM → CJS | `import`    | ✓         | ESM은 CJS를 가져올 수 있음                   |
| CJS → ESM | `require()` | ✗         | ESM은 비동기 평가, `require()`는 동기 → 불가 |

이 프로젝트에서 문제가 생긴 이유:

```
babel이 .mjs를 CJS로 변환
  → 번들 안에 require("antd/es/date-picker/...") 생성
  → antd/es/*.js는 ESM (package.json "type": "module")
  → CJS → ESM: require() 불가 ✗ (서버)
  → 브라우저: require is not defined ✗ (클라이언트)
```

---

## 빠른 진단 체크리스트

문제가 의심될 때 확인 순서:

### 1. 실제 번들 결과물 확인 (가장 확실)

```bash
# dynamic import된 청크 파일 찾기
ls .next/static/chunks/ | grep 패키지명

# require()가 있는지 확인
grep "require(" .next/static/chunks/node_modules_패키지명_*.js | head -5
```

- `require(` 있음 → 브라우저에서 `require is not defined` 발생
- `__webpack_require__(` 있음 → 정상

### 2. 패키지가 어떤 파일을 선택하는가 (참고용)

```bash
cat node_modules/@패키지명/package.json | grep -E '"main"|"module"|"exports"'
```

- `exports.import` → `.mjs` 선택 가능성

단, 파일 확장자만으로는 판단 불가. babel 설정(preset-env의 `modules` 옵션, targets 등)에 따라 결과가 달라질 수 있다. 번들 결과물을 직접 확인하는 것이 가장 확실하다.
