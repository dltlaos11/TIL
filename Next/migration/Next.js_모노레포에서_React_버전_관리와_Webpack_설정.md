최상위 루트(node_modules)에 react@16이 계속 설치되는 이유는
**모노레포 내 다른 패키지(예: piip-webapp-front, piip-landing-modules 등)**에서
"react": "16"을 dependencies 또는 peerDependencies로 명시하고 있기 때문입니다.

Yarn Workspaces(또는 npm workspaces)는
모든 워크스페이스 패키지의 react 버전 요구사항을 합쳐서
루트 node_modules에 가장 낮은(또는 호환 가능한) 버전을 설치합니다.

즉,

intranet 모듈만 17을 요구해도
다른 패키지에서 16을 요구하면
루트에는 16이 설치되고,
intranet의 node_modules에는 17이 설치될 수 있습니다.
이렇게 되면 React 인스턴스가 중복되어 "Invalid hook call" 에러가 발생합니다.

해결 방법
모든 패키지의 package.json에서 react/react-dom 버전을 17로 통일해야
루트 node_modules/react도 17로 설치됩니다.
하나라도 16을 요구하면, 루트에는 16이 설치됩니다.
요약:
루트에 react@16이 설치되는 것은
다른 워크스페이스 패키지에서 react@16을 요구하고 있기 때문입니다.
모든 패키지의 react 버전을 17로 맞추세요.

'yarn workspaces + next-transpile-modules 환경에서
@가 붙는 패키지명은 symlink된 내부 패키지는 node_modules에 symlink로 연결된 로컬 패키지'라는 것에서

직접 webpack 커스텀 빌드하는 경우 webpack(config, options) { ... } 함수를 추가해야 합니다.

```js
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

Next.js 9에서는 webpack 직접 설치가 필요한 경우가 많았음
Next.js 13에서는 직접 설치하지 않는 것이 표준
(Next.js가 알아서 관리하므로 삭제해도 무방)
