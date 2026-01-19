# Next.js 모노레포에서 React 버전 관리와 Webpack 설정

## React 버전 충돌 문제

### 문제 상황

모노레포 환경에서 최상위 루트의 `node_modules`에 React 16이 계속 설치되는 현상이 발생했다. 이로 인해 특정 패키지가 React 17을 사용하려 할 때 문제가 발생했다.

### 원인

- 모노레포 내 일부 패키지(예: piip-webapp-front, piip-landing-modules)에서 `"react": "16"`을 dependencies 또는 peerDependencies로 명시하고 있음
- Yarn Workspaces(또는 npm workspaces)는 모든 워크스페이스 패키지의 의존성 요구사항을 통합해서 관리함
- 호환성을 위해 일반적으로 가장 낮은(또는 호환 가능한) 버전을 루트 node_modules에 설치함
- 결과: intranet 모듈만 17을 요구해도 다른 패키지에서 16을 요구하면 루트에는 16이 설치됨
- 동시에 intranet의 node_modules에는 17이 설치될 수 있어 React 인스턴스가 중복됨
- 이로 인해 "Invalid hook call" 에러가 발생 (React 훅은 동일한 React 인스턴스에서만 작동)

### 해결 방법

- 모든 패키지의 package.json에서 react/react-dom 버전을 17로 통일해야 함
- 중요: 하나라도 16을 요구하면, 루트에는 16이 설치됨
- 모든 패키지의 React 버전을 동일하게 맞추는 것이 가장 안전한 해결책

## Next.js 모노레포에서의 모듈 해석 및 Webpack 설정

### 심볼릭 링크 이해

- Yarn Workspaces + next-transpile-modules 환경에서 `@`가 붙는 패키지명은 심볼릭 링크된 내부 패키지를 의미함
- 예: `@private-package/piip-webapp-modules`와 같은 패키지는 실제로 node_modules에 symlink로 연결된 로컬 패키지임
- 이 심볼릭 링크를 통해 로컬 개발 시 패키지 변경사항이 즉시 반영됨

### Webpack 커스텀 설정

직접 webpack 설정을 커스터마이징하기 위해서는 Next.js 설정에 webpack 함수를 추가해야 한다:

```javascript
module.exports = withTM(
  withBundleAnalyzer({
    reactStrictMode: false,
    webpack(config, options) {
      // 여기서 config 수정 가능
      return config;
    },
  })
);
```

이 설정을 통해 webpack의 다양한 부분(로더, 리졸버, 플러그인 등)을 직접 제어할 수 있다.

### Next.js 버전별 Webpack 관리 방식 변화

- Next.js 9에서는 webpack을 직접 package.json에 명시하고 설치해야 하는 경우가 많았음
- Next.js 13에서는 webpack을 직접 설치하지 않는 것이 표준적인 방식
- 최신 버전에서는 Next.js가 내부적으로 webpack을 관리하므로 dependencies에서 webpack을 제거해도 무방
- 이는 Next.js의 "Zero Config" 철학에 맞춰 변화한 것

## 모노레포에서의 주의사항

### 패키지 간 의존성

- 모노레포에서는 패키지 간 의존성 관계가 복잡해질 수 있음
- 특히 React와 같은 싱글톤 패키지는 버전이 일치해야 함
- 일부 패키지만 업데이트하면 예상치 못한 버전 충돌 문제가 발생할 수 있음

### next-transpile-modules의 역할

- next-transpile-modules는 모노레포 내 로컬 패키지를 Next.js가 트랜스파일할 수 있게 해주는 중요한 도구
- 이를 통해 바벨이 로컬 패키지 코드도 처리할 수 있게 됨
- 심볼릭 링크된 패키지를 올바르게,처리하기 위해 필수적인 설정

### 효율적인 모노레포 관리

- 모든 패키지의 주요 의존성 버전(React, TypeScript 등)을 일관되게 유지하는 것이 중요
- 가능하면 의존성 관리를 루트 레벨에서 통합적으로 수행하는 것이 좋음
- 패키지 간 버전 불일치를 방지하기 위한 CI 검사를 도입하는 것이 도움됨

## 학습 포인트

1. 모노레포에서 패키지 간 의존성 버전 통일의 중요성
2. Yarn Workspaces가 의존성을 해석하고 설치하는 방식
3. Next.js의 webpack 설정 커스터마이징 방법
4. 심볼릭 링크를 통한 로컬 패키지 개발 방식
5. Next.js 버전 변화에 따른 의존성 관리 방식의 변화
