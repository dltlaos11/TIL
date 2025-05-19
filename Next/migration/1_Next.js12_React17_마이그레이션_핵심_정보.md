# Next.js 12, React 17 마이그레이션 핵심 정보

## Next.js 버전 호환성

- **Next.js 12**는 Node.js 12.22.0 이상 버전에서 지원됨
- Node.js 20도 기술적으로 호환되지만, Node.js 16이 가장 안정적
- Next.js 12는 React 17과 완벽하게 호환됨

## next-transpile-modules 호환성

- Next.js 12에는 **next-transpile-modules 9.0.0 이상** 버전이 필요함
- 이전 버전(6.0.0 등)은 Next.js 12와 호환되지 않아 `next.config.js` 로딩 오류 발생 가능성 높음
- 모노레포 환경에서는 패키지 버전 충돌에 특히 주의해야 함

## SWC와 Babel 관계

- Next.js 12부터 SWC(Speedy Web Compiler)가 기본 컴파일러로 도입됨
- 커스텀 Babel 설정(`babel.config.js` 등)이 있으면 SWC는 자동으로 비활성화됨
- SWC는 Babel보다 최대 17배 빠르지만, 모든 Babel 플러그인을 지원하지는 않음
- 빌드 속도가 중요하다면 SWC 활성화를 고려할 수 있음

## MobX 패키지 호환성

- MobX 6.10.2와 mobx-react 9.1.0은 상호 호환되며 React 17과도 호환됨
- MobX 6부터는 데코레이터가 선택 사항이며, makeObservable/makeAutoObservable API 사용 가능
- 데코레이터 사용 시 바벨 설정에 `@babel/plugin-proposal-decorators`가 필요함

## 웹팩 설정 (next.config.js)

- Next.js 12에서 `@zeit/next-bundle-analyzer`는 `@next/bundle-analyzer`로 대체됨
- `@zeit/next-css`는 Next.js 12에서 내장 기능으로 제공되어 더 이상 필요하지 않음
- 모노레포 환경에서 외부 모듈을 트랜스파일하려면 올바른 버전의 next-transpile-modules 필수
- 웹팩 설정 문제 디버깅 시 간단한 설정부터 시작하여 점진적으로 확장하는 것이 효과적

## Browserslist 업데이트

- `npx browserslist@latest --update-db` 명령으로 브라우저 호환성 데이터베이스 업데이트 가능
- 오래된 브라우저 데이터로 인한 빌드 오류나 경고 해결에 도움
- Next.js와 같은 프레임워크는 내부적으로 Browserslist를 사용하여 폴리필 생성

## 모노레포 환경에서의 주의사항

- 패키지 간 버전 충돌 주의 필요 (예: next-transpile-modules 여러 버전)
- 경로 별칭(path aliases)이 실제 디렉토리 구조와 일치하는지 확인
- JSX를 포함하는 .js 파일을 트랜스파일할 수 있도록 웹팩 설정 필요

## 디버깅 테크닉

- 최소한의 설정으로 시작하여 점진적으로 기능 추가
- 오류 발생 시 `DEBUG=*` 또는 `NODE_OPTIONS="--trace-warnings"` 환경 변수 활용
- 파일 직접 실행으로 검증: `node -e "console.log(require('./next.config.js'))"`
- 캐시 문제 해결을 위해 `.next` 디렉토리 및 노드 모듈 캐시 정리
