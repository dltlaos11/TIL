# React QueryBuilder SSR 에러 해결 과정

## 문제 상황

Next.js 프로젝트에서 `react-querybuilder`와 `@react-querybuilder/antd`를 사용할 때 SSR(Server-Side Rendering) 단계에서 모듈 충돌 에러가 발생했습니다.

### 에러 원인

```
react-querybuilder (CJS 모듈) +
@react-querybuilder/antd (CJS 모듈)
↓
Next.js (ESM 기반 빌드 시스템)
↓
SSR 시도 → 모듈 해석 충돌 💥
```

**핵심 문제:**

- 패키지가 CommonJS(CJS) 형식으로 제공됨
- Next.js는 ESM(ES Module) 기반으로 빌드
- 서버 렌더링 시 모듈 시스템 불일치로 에러 발생

## 시도한 해결 방법들

### 시도 1: patch-package를 이용한 직접 수정

라이브러리의 소스 코드를 직접 수정하여 문제를 해결하려고 시도했습니다.

```bash
# patch-package 설치
npm install patch-package --save-dev

# node_modules 내 라이브러리 직접 수정 후
npx patch-package @react-querybuilder/antd
```

**package.json에 스크립트 추가:**

```json
{
  "scripts": {
    "postinstall": "patch-package"
  }
}
```

#### patch-package의 동작 방식

1. `node_modules` 내의 패키지 파일을 직접 수정
2. `npx patch-package [패키지명]` 실행
3. `patches/` 디렉토리에 diff 파일 생성
4. `npm install` 시 자동으로 패치 적용

#### 모노레포 환경에서의 문제점

```
monorepo/
├── packages/
│   ├── app-a/
│   │   └── node_modules/ (symlink)
│   └── app-b/
│       └── node_modules/ (symlink)
└── node_modules/
    └── @react-querybuilder/antd (실제 위치)
```

**CI/CD 빌드 실패:**

```bash
[CI] Building app-a...
[Error] ENOENT: no such file or directory
  → patches/@react-querybuilder+antd+x.x.x.patch
```

**문제 원인:**

- 모노레포에서 각 패키지는 루트의 `node_modules`를 공유
- CI 환경에서 workspace별로 독립 빌드 수행
- 패키지별 작업 디렉토리가 달라 patch 파일 경로 불일치
- symlink 구조로 인한 경로 혼선

**patch-package의 한계:**

- 모노레포의 복잡한 의존성 구조 지원 미흡
- CI/CD 파이프라인에서 각 패키지가 독립적으로 빌드될 때 경로 문제
- Workspace 간 의존성 해결 불안정

### 최종 해결 방법: 2단계 접근

patch-package 대신 Next.js 생태계의 표준 솔루션을 사용하기로 결정했습니다.

#### 1단계: `next-transpile-modules` 설정

CJS 모듈을 ESM으로 변환하여 Next.js와 호환되도록 설정합니다.

```javascript
// next.config.js
const withTM = require("next-transpile-modules")([
  "@react-querybuilder/antd",
  // ... 기타 패키지들
]);

module.exports = withTM({
  // Next.js 설정
});
```

**역할:**

- 빌드 타임에 CJS → ESM 변환 (트랜스파일)
- 모듈 형식 호환성 확보
- 서버/클라이언트 양쪽에서 사용 가능한 코드 생성

#### 2단계: Dynamic Import + SSR 비활성화

트랜스파일 후에도 남을 수 있는 SSR 관련 이슈를 완전히 차단합니다.

```javascript
import dynamic from "next/dynamic";

const QueryBuilderAntD = dynamic(
  () => import("@react-querybuilder/antd").then((mod) => mod.QueryBuilderAntD),
  { ssr: false } // 서버 렌더링 비활성화
);
```

**`ssr: false`의 의미:**

- 서버 빌드 단계에서 해당 컴포넌트를 완전히 제외
- **오직 브라우저(CSR)에서만** 로드하고 렌더링
- DOM API 의존성이 있는 코드 보호

## 동작 흐름

```
[빌드 타임]
├─ next-transpile-modules
│  └─ @react-querybuilder/antd (CJS) → ESM 변환
│
[서버 렌더링]
├─ QueryBuilderAntD 컴포넌트
│  └─ ssr: false → 렌더링 스킵 (placeholder만 출력)
│
[브라우저 로드]
├─ 트랜스파일된 ESM 코드 다운로드
├─ QueryBuilderAntD 컴포넌트 실행
└─ 하이드레이션 완료 ✅
```

## 최종 구현 코드

```javascript
// next.config.js
const withTM = require("next-transpile-modules")(["@react-querybuilder/antd"]);

module.exports = withTM({
  // 기타 설정...
});
```

```javascript
// components/QueryBuilder.js
import React from "react";
import dynamic from "next/dynamic";
import {
  QueryBuilder as RQB,
  formatQuery,
  parseJsonLogic,
} from "react-querybuilder";
import "react-querybuilder/dist/query-builder.css";

// CSR 전용 컴포넌트로 로드
const QueryBuilderAntD = dynamic(
  () => import("@react-querybuilder/antd").then((mod) => mod.QueryBuilderAntD),
  { ssr: false }
);

const QueryBuilderWrapper = (props) => {
  return (
    <RQB
      {...props}
      controlClassnames={{ queryBuilder: "queryBuilder-branches" }}
    />
  );
};

export default QueryBuilderWrapper;
export { formatQuery, parseJsonLogic, QueryBuilderAntD };
```

## 해결책 비교

| 방법                                 | 장점                               | 단점                                       | 모노레포 호환성 |
| ------------------------------------ | ---------------------------------- | ------------------------------------------ | --------------- |
| **patch-package**                    | 소스 직접 수정 가능, 세밀한 제어   | CI/CD 경로 문제, workspace 구조에서 불안정 | ❌ 불안정       |
| **next-transpile-modules + dynamic** | 표준 솔루션, 안정적, 유지보수 용이 | 추가 설정 필요                             | ✅ 안정적       |

## 두 가지 해결책이 필요한 이유

| 해결책                   | 레이어      | 역할                                     |
| ------------------------ | ----------- | ---------------------------------------- |
| `next-transpile-modules` | 빌드 시스템 | CJS → ESM 변환으로 모듈 형식 호환성 확보 |
| `dynamic` + `ssr: false` | 런타임 제어 | 서버 실행 차단, 브라우저 전용 실행 보장  |

**핵심 포인트:**

- `next-transpile-modules`만으로는 SSR 시 DOM API 의존성 문제가 남을 수 있음
- `ssr: false`만으로는 모듈 형식 불일치 문제를 해결할 수 없음
- **두 가지를 조합하여 완전한 해결**

## 대안 (Next.js 13.1+)

최신 버전의 Next.js를 사용한다면 내장 옵션을 활용할 수 있습니다:

```javascript
// next.config.js
module.exports = {
  transpilePackages: ["@react-querybuilder/antd"],
  experimental: {
    esmExternals: "loose",
  },
};
```

하지만 레거시 패키지나 복잡한 의존성이 있는 경우, `dynamic` + `ssr: false` 조합이 가장 안전한 방법입니다.

## 교훈 및 권장사항

### patch-package는 언제 사용해야 하나?

**✅ 사용하기 좋은 경우:**

- 단일 저장소(non-monorepo) 프로젝트
- 간단한 버그 수정이나 타입 정의 추가
- 공식 패치가 나올 때까지의 임시 해결책

**❌ 피해야 하는 경우:**

- 모노레포 환경 (특히 CI/CD 파이프라인)
- 프레임워크 레벨의 모듈 시스템 문제
- 장기적인 유지보수가 필요한 경우

### 모노레포에서의 권장 접근법

1. **프레임워크 표준 도구 우선 사용** (`transpilePackages`, `next-transpile-modules`)
2. **런타임 제어 활용** (`dynamic import`, `ssr: false`)
3. **근본 원인 해결** (모듈 시스템 호환성)
4. **patch-package는 최후의 수단**

## 결론

CJS/ESM 모듈 충돌 문제는 두 가지 레이어에서 접근해야 합니다:

1. **빌드 타임**: 모듈 형식 변환 (`next-transpile-modules`)
2. **런타임**: 실행 환경 제어 (`dynamic` + `ssr: false`)

모노레포 환경에서는 **프레임워크가 제공하는 표준 솔루션**을 우선 적용하고, 직접적인 소스 패치는 단순한 프로젝트 구조에서만 신중하게 사용해야 합니다. 이 조합으로 Next.js 프로젝트에서 CJS 기반 라이브러리를 안전하고 안정적으로 사용할 수 있습니다.
