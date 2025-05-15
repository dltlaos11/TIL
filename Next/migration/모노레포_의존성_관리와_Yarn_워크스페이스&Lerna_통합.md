# 모노레포 의존성 관리와 Yarn 워크스페이스/Lerna 통합

## 모노레포의 의존성 관리

### peerDependencies vs dependencies

- **dependencies**: 패키지가 직접 의존하는 라이브러리로, 해당 패키지 설치 시 함께 설치됨
- **peerDependencies**: 패키지가 사용하는 라이브러리지만, 직접 설치하지 않고 상위 프로젝트에서 제공받는 의존성
- **핵심 차이**: dependencies는 자체 설치, peerDependencies는 호스트 환경에서 제공받음
- **중요**: peerDependencies는 심볼릭 링크 생성과 직접적인 관련이 없음

### 싱글톤 패턴과 의존성 관리

- React, Next.js 같은 라이브러리는 애플리케이션 내에서 싱글톤으로 유지되어야 함
- 다중 인스턴스 존재 시 "Invalid hook call" 등의 예상치 못한 오류 발생 가능
- **엔트리 포인트**: dependencies에 명시 (실제 설치)
- **참조 모듈**: peerDependencies에 명시 (상위에서 제공받음)
- peerDependencies 사용은 중복 설치를 방지하는 명시적인 방법이지만, 호이스팅만으로도 가능함

### 호이스팅 메커니즘

- npm/yarn은 중복 의존성을 루트로 끌어올리는 '호이스팅' 사용
- 동일/호환 버전은 하나로 통합되어 중복 설치 방지
- 메이저 버전 차이가 있으면 호이스팅이 제대로 작동하지 않아 문제 발생
- 호이스팅은 dependencies와 peerDependencies 선언 여부와 관계없이 패키지 매니저가 수행

## 심볼릭 링크와 모노레포

### 심볼릭 링크 작동 방식

- 모노레포 내 패키지 간 참조를 실제 파일 복사 없이 원본 위치를 가리키는 특수 파일
- 로컬 패키지 변경 시 참조하는 다른 패키지에 즉시 반영됨
- 심볼릭 링크는 전적으로 패키지 매니저의 워크스페이스 기능에 의해 생성되며, peerDependencies와 직접적인 관계 없음
- 워크스페이스 설정이 있으면 dependencies, devDependencies, peerDependencies 유형과 관계없이 로컬 패키지 참조는 심볼릭 링크로 연결됨

### 패키지 매니저별 접근 방식

- **npm/Yarn Classic**: 호이스팅 + 심볼릭 링크
- **Yarn Berry**: PnP(Plug'n'Play) 시스템으로 가상 경로 사용
- **pnpm**: 콘텐츠 주소 지정 저장소(content-addressable store)와 엄격한 심볼릭 링크 구조 사용

## Yarn 워크스페이스와 Lerna 통합

### Yarn 워크스페이스의 역할

- 단일 `yarn.lock` 파일로 버전 충돌 방지
- 중복 의존성 호이스팅으로 디스크 공간 최적화
- 로컬 패키지 간 심볼릭 링크 자동 생성
- 루트에서 `yarn install` 한 번으로 모든 패키지 의존성 설치
- 워크스페이스는 패키지 간 참조 시 자동으로 심볼릭 링크를 생성하는 주체

### Lerna의 역할

- 버전 관리: 패키지 버전 일괄 업데이트
- 배포 관리: 변경된 패키지만 선별적 배포
- 작업 실행: 여러 패키지에서 명령어 병렬 실행
- 변경 사항 추적: 변경된 패키지 식별
- Lerna 자체는 심볼릭 링크 생성에 직접 관여하지 않음 (useWorkspaces: true 설정 시)

### `useWorkspaces: true`의 의미

- Lerna가 자체 링크 메커니즘을 비활성화하고 Yarn 워크스페이스 기능에 완전히 의존
- `lerna bootstrap`이 내부적으로 `yarn install` 실행
- 심볼릭 링크 생성, 의존성 호이스팅 등 모든 의존성 관리는 Yarn이 담당
- "Lerna는 버전 관리와 배포에 집중, 의존성 관리는 Yarn에 위임"

## 베스트 프랙티스

### 의존성 관리 최적화

- **엔트리 포인트**: React, Next.js 등 핵심 라이브러리를 dependencies에 명시
- **참조 모듈**: 동일 라이브러리를 peerDependencies에 명시
- **공통 개발 도구**: 루트 package.json의 devDependencies에 배치
- `peerDependencies`는 심볼릭 링크와 관련 없지만, 싱글톤 패턴 유지에 효과적

### 모노레포 구성 전략

- 명확한 패키지 구조와 책임 분리
- 일관된 의존성 관리 정책 수립
- 패키지 간 버전 동기화 관리
- 효율적인 빌드 및 배포 파이프라인 구축

## 문제 해결 전략

- 버전 업그레이드 시 모든 참조 패키지의 peerDependencies도 함께 업데이트
- 의존성 그래프를 고려한 빌드 순서 최적화 (--sort 옵션)
- 변경된 패키지와 영향받는 패키지만 선별적으로 테스트/빌드

## 주요 개념 정리

- **심볼릭 링크**: 패키지 매니저의 워크스페이스 기능에 의해 생성됨, peerDependencies와 직접 관련 없음
- **peerDependencies**: 의존성 중복 방지 및 싱글톤 패턴 유지를 위한 명시적 선언 방법
- **호이스팅**: 패키지 매니저가 수행하는 의존성 중복 제거 메커니즘
- **useWorkspaces: true**: Lerna가 Yarn의 워크스페이스 기능에 의존하도록 설정
