# Next.js 모노레포 환경에서의 의존성 및 MobX 호환성 문제 해결

오늘 Next.js 모노레포 환경에서 발생할 수 있는 여러 문제들과 해결 방법에 대해 알아보았다.

## 모노레포 환경에서 React 버전 충돌 문제

모노레포의 모든 패키지에서 React 18을 사용하도록 설정했음에도 React 16이 설치되는 문제가 발생했다. `yarn why react` 명령어로 원인을 분석한 결과, Storybook 관련 패키지들이 React 16을 peer dependency로 요구하고 있어서 발생한 문제였다.

### 원인

- @storybook/ 관련 패키지(5.x, 6.x)가 react@16을 peerDependencies로 요구
- 이로 인해 루트 node_modules에 react@16이 설치됨
- 동시에 앱에서는 react@18이 설치되어 두 버전이 공존하게 됨

### 해결 방법

1. Storybook 7.x 이상으로 업그레이드 (React 18 지원)
2. 모든 패키지의 @storybook/\* 의존성을 7.x 이상으로 업데이트
3. 업그레이드 후:
   - 루트와 모든 패키지의 node_modules, yarn.lock, package-lock.json 삭제
   - 루트에서 `yarn install` 실행
   - `yarn why react`로 react@18만 있는지 확인

### Storybook 7.x 변경사항

- 기존 패키지 삭제: @storybook/addon-actions, @storybook/addon-links, @storybook/addon-viewport, @storybook/addons, @storybook/react (5.x)
- 새로운 패키지로 교체: @storybook/react, @storybook/addon-actions, @storybook/addon-links, @storybook/addon-essentials (7.x)
- @storybook/addons는 7.x부터 별도 설치 불필요

## MobX와 Next.js 13+ 호환성 문제

Next.js 13+ 환경에서 Provider에 올바르게 store를 전달했음에도 "Store 'authModel' is not available!" 에러가 발생하는 문제를 조사했다.

### 원인

- mobx, mobx-react, mobx-react-lite, react의 버전 불일치
- SSR 환경에서의 context 전달 이슈
- 특히 Next.js 13+와 mobx-react 6.x 이하, mobx-react-lite 혼용 시 자주 발생

### 해결 방법

- mobx, mobx-react, mobx-react-lite를 권장 버전으로 업그레이드
- Provider/inject를 모두 mobx-react에서 import
- enableStaticRendering 적용

## Next.js 13 Link 컴포넌트 변경사항

Next.js 13에서는 Link 컴포넌트 사용 방식이 변경되었다.

### 이전 방식 (더 이상 지원되지 않음)

```jsx
<Link href="...">
  <a>...</a>
</Link>
```

### 새로운 방식

```jsx
<Link href="...">내용</Link>
```

### 레거시 지원이 필요한 경우

```jsx
<Link legacyBehavior href="...">
  <a>...</a>
</Link>
```

`npx @next/codemod new-link .` 명령어로 자동 변환을 시도할 수 있으나, 일부 케이스에서는 변환이 잘 되지 않는 이슈가 있다.

오늘 이러한 문제들의 원인과 해결 방법을 학습함으로써 모노레포 환경에서의 의존성 관리와 라이브러리 호환성 이슈를 더 잘 이해할 수 있었다.
