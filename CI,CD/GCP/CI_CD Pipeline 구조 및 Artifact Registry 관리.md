# CI/CD Pipeline 구조 및 Artifact Registry 관리

## 개요

사내 프로젝트는 Google Cloud Build를 활용한 2단계 CI/CD 파이프라인을 운영합니다.

- **CI (Continuous Integration)**: `cloudbuild-staging.yaml`
- **CD (Continuous Deployment)**: `packages/piip-webapp-intranet/piip-intranet-staging-build.yaml`

## GCP Artifact Registry란?

### 정의

Google Cloud의 **컨테이너 이미지 및 패키지 저장소** 서비스입니다. Docker 이미지, npm 패키지, Maven 아티팩트 등을 안전하게 저장하고 관리할 수 있습니다.

### 주요 특징

- **보안**: IAM 기반 접근 제어, 취약점 스캔
- **지역 복제**: 여러 리전에 이미지 복제 가능
- **비용 효율**: 스토리지 사용량 기반 과금
- **Container Registry 후속**: 기존 GCR의 개선 버전

### 프로젝트에서의 역할

```
Docker 이미지 빌드 → Artifact Registry 저장 → App Engine 배포
```

매 배포마다 Docker 이미지가 생성되어 Artifact Registry에 저장되며, App Engine은 이 이미지를 pull하여 서비스를 실행합니다.

## CI/CD 파이프라인 전체 플로우

```
┌─────────────────────────────────────────────────────────────────┐
│                        Git Push (develop)                        │
└────────────────────────────┬────────────────────────────────────┘
                             │
                             ▼
┌─────────────────────────────────────────────────────────────────┐
│                   CI: cloudbuild-staging.yaml                    │
│                                                                   │
│  1. Git 인증 설정 (SSH Key)                                      │
│  2. NPM 인증 복호화 (KMS)                                        │
│  3. 의존성 설치 (yarn install + bootstrap)                       │
│  4. 테스트 실행 (변경된 패키지만)                                │
│  5. 패키지 빌드                                                  │
│  6. 파이프라인 브랜치 생성 (candidate/${APP_ENV}/piip-*)        │
│  7. 버전 업데이트 (patch/minor)                                  │
│  8. NPM 패키지 배포                                              │
│  9. 브랜치 푸시 (candidate/staging/piip-*)                      │
└────────────────────────────┬────────────────────────────────────┘
                             │
                             ▼
┌─────────────────────────────────────────────────────────────────┐
│              CD: piip-intranet-staging-build.yaml                │
│                                                                   │
│  1. Git 인증 설정                                                │
│  2. candidate 브랜치 체크아웃                                    │
│  3. NPM 인증 복호화                                              │
│  4. 의존성 설치                                                  │
│  5. 버전 업데이트 (--amend)                                      │
│  6. Docker 이미지 빌드                                           │
│     └─> ${REGION}-docker.pkg.dev/${PROJECT}/${REGISTRY}/${SERVICE}:${COMMIT_SHA}
│  7. Artifact Registry 푸시                                       │
│  8. App Engine 배포                                              │
│  9. 정리 작업                                                    │
│     ├─> 오래된 App Engine 버전 삭제 (10개 유지)                 │
│     └─> 오래된 Artifact Registry 이미지 삭제 (11개 유지)        │
└─────────────────────────────────────────────────────────────────┘
```

## CI 파이프라인: cloudbuild-staging.yaml

### 목적

**코드 품질 검증 및 패키지 배포 준비**

### 트리거 조건

- `develop` 브랜치에 push
- Pull Request 머지

### 주요 단계

#### 1. 환경 설정 (1-62라인)

```yaml
# Git SSH 인증 설정
- Secret Manager에서 GitHub SSH 키 가져오기
- SSH config 파일 생성
- Git 원격 저장소 URL 변경 (HTTPS → SSH)
- Git 사용자 정보 설정 (DevOpsBot)
```

#### 2. NPM 인증 (63-82라인)

```yaml
# KMS를 통한 NPM 토큰 복호화
- staging-npm.enc → .npmrc
- yarn logout (기존 세션 정리)
- npm whoami (인증 확인)
```

#### 3. 빌드 및 테스트 (84-116라인)

```bash
# Monorepo 의존성 설치
yarn install
yarn bootstrap

# 변경된 패키지만 테스트 (병렬 실행)
yarn lerna run test:ci --since --parallel --stream

# 모든 패키지 빌드
yarn run packages:build
```

#### 4. 배포 준비 (118-154라인)

```bash
# 각 패키지별 candidate 브랜치 생성
yarn lerna run pipeline:git:branch --since --concurrency=1

# 버전 업데이트 (patch/minor)
yarn packages:version:${_BUILD_TARGET}

# NPM 레지스트리에 패키지 배포
./pipeline/scripts/publish-packages.sh
```

#### 5. 브랜치 푸시 (156-166라인)

```bash
# CD 파이프라인 트리거를 위한 브랜치 푸시
git push -u origin refs/heads/candidate/${_APP_ENV}/piip-*
```

**결과**: `candidate/staging/piip-webapp-intranet` 브랜치 생성 및 푸시

## CD 파이프라인: piip-intranet-staging-build.yaml

### 목적

**Docker 이미지 빌드 및 App Engine 배포**

### 트리거 조건

- `candidate/staging/piip-webapp-intranet` 브랜치에 push
- CI 파이프라인 완료 후 자동 실행

### 주요 단계

#### 1. 환경 설정 (1-82라인)

```yaml
# Git SSH 인증 설정
- Secret Manager에서 GitHub SSH 키 가져오기
- SSH config 파일 생성 (chmod 600)
- Git 원격 저장소 URL 변경
- Git 사용자 정보 설정
- candidate/${_APP_ENV}/${_SERVICE_NAME} 브랜치 체크아웃

# NPM 인증
- KMS로 staging-npm.enc 복호화 → .npmrc
- .npmrc를 서비스 패키지로 복사 (./packages/${_SERVICE_NAME}/.npmrc)
```

**중요**: CD 파이프라인은 CI와 달리 `.npmrc` 파일을 서비스별 디렉토리에 복사합니다.

#### 2. 의존성 및 버전 관리 (83-112라인)

```bash
yarn logout
npm whoami  # 인증 확인
yarn install
yarn bootstrap

# 버전 업데이트 (커밋 수정 모드, git 태그 없이)
yarn lerna version ${_BUILD_TARGET} --amend --no-git-tag-version --yes
```

**주의**: CD 파이프라인에서는 패키지 빌드를 하지 않습니다. Docker 이미지 빌드 시 내부에서 빌드가 수행됩니다.

#### 3. Docker 이미지 빌드 (124-145라인)

```bash
# Docker 이미지 빌드
docker build \
  --build-arg _NODE_ENV=${_NODE_ENV} \
  --build-arg _APP_ENV=${_APP_ENV} \
  -t asia-northeast3-docker.pkg.dev/PROJECT/REGISTRY/piip-webapp-intranet:COMMIT_SHA \
  ./packages/piip-webapp-intranet

# Artifact Registry 푸시
docker push asia-northeast3-docker.pkg.dev/...
```

**이미지 태그 형식**: `${COMMIT_SHA}` (Git 커밋 해시)

#### 4. App Engine 배포 (148-159라인)

```bash
gcloud app deploy \
  ./packages/piip-webapp-intranet/piip-webapp-intranet.yaml \
  --stop-previous-version \
  --image-url asia-northeast3-docker.pkg.dev/.../piip-webapp-intranet:COMMIT_SHA
```

**배포 전략**:

- `--stop-previous-version`: 이전 버전 자동 중지
- 무중단 배포 (Blue-Green)

#### 5. 정리 작업 (161-179라인)

##### 5-1. App Engine 버전 정리

```bash
./pipeline/scripts/delete-older-appengine-versions.sh piip-webapp-intranet 10
```

**동작**:

1. 중지된(STOPPED) 버전 목록 조회
2. 최신 10개 제외하고 삭제
3. 현재 서빙 중인 버전은 절대 삭제 안 됨

**목적**: App Engine 버전 메타데이터 정리

##### 5-2. Artifact Registry 이미지 정리 (신규 추가)

```bash
./pipeline/scripts/delete-older-artifact-images.sh \
  $PROJECT_ID \
  asia-northeast3 \
  piip-docker-repo \
  piip-webapp-intranet \
  11
```

**동작**:

1. Artifact Registry에서 이미지 목록 조회
2. 생성 시간 기준 내림차순 정렬
3. 최신 11개 제외하고 삭제
4. 연결된 태그도 함께 삭제 (`--delete-tags`)

**목적**: Docker 이미지 스토리지 비용 절감

## 정리 작업 상세 비교

| 항목          | App Engine 버전                      | Artifact Registry 이미지          |
| ------------- | ------------------------------------ | --------------------------------- |
| **대상**      | 버전 메타데이터                      | Docker 이미지 실제 파일           |
| **보관 개수** | 10개                                 | 11개                              |
| **삭제 조건** | `STOPPED` 상태만                     | 생성 시간 기준 오래된 것          |
| **스크립트**  | `delete-older-appengine-versions.sh` | `delete-older-artifact-images.sh` |
| **용량**      | 작음 (수 MB)                         | 큼 (수백 MB ~ GB)                 |
| **비용 절감** | 미미                                 | 크다                              |

### 왜 11개인가?

- **현재 배포 중**: 1개
- **롤백 가능**: 10개
- **합계**: 11개

App Engine 버전은 10개만 보관하지만, Artifact Registry 이미지는 현재 배포 중인 것까지 포함하여 11개를 보관합니다.

## Artifact Registry 이미지 정리 스크립트 상세

### 파일 위치

```
pipeline/scripts/delete-older-artifact-images.sh
```

### 실행 예시

```bash
./delete-older-artifact-images.sh \
  piip-production-12345 \          # PROJECT_ID
  asia-northeast3 \                 # REGION
  piip-docker-repo \                # ARTIFACT_REGISTRY
  piip-webapp-intranet \            # SERVICE_NAME
  11                                # KEEP_COUNT
```

### 핵심 로직

```bash
# 이미지 목록 조회 (최신 순)
IMAGES=$(gcloud artifacts docker images list \
    "$LOCATION-docker.pkg.dev/$PROJECT/$REPOSITORY/$PACKAGE" \
    --sort-by="~CREATE_TIME" \
    --format="value(version)" \
    --limit=1000)

# 순회하며 11개 초과 이미지 삭제
for IMAGE in $IMAGES
do
    ((COUNT++))
    if [ $COUNT -gt $KEEP_COUNT ]
    then
        gcloud artifacts docker images delete \
            "$LOCATION-docker.pkg.dev/$PROJECT/$REPOSITORY/$PACKAGE@$IMAGE" \
            --delete-tags --quiet
    fi
done
```

### 비용 절감 효과

**가정**:

- Docker 이미지 크기: 500MB
- 월 배포 횟수: 60회 (하루 2회)
- 정리 없이 2개월 운영 시: 120개 이미지

**비용 계산**:

```
정리 전: 120개 × 500MB = 60GB
정리 후: 11개 × 500MB = 5.5GB
절감: 54.5GB (약 91% 감소)

월 비용 절감 (Artifact Registry 스토리지: $0.10/GB):
54.5GB × $0.10 = $5.45/월
```

## 환경별 파이프라인 구성

### Staging 환경

- **CI**: `cloudbuild-staging.yaml`
- **CD**: `piip-intranet-staging-build.yaml`
- **브랜치**: `develop` → `candidate/staging/piip-*`
- **도메인**: `staging.piip.co.kr`

### Production 환경

- **CI**: `cloudbuild-production.yaml` (있을 경우)
- **CD**: `piip-intranet-build.yaml`
- **브랜치**: `master` 또는 `main` → `candidate/production/piip-*`
- **도메인**: `piip.co.kr`
- **NPM 암호화 파일**: `npm.enc` (staging과 다름)

## Cloud Build 변수

### 공통 변수

```yaml
_GIT_SECRET: github-ssh-key
_GIT_USERNAME: your-org
_REPO_NAME: piip-webapp-monorepo
_KEYRING: piip-keyring
_NPM_KEY: npm-token-key
_NODE_VERSION: 14.21.3
```

### CD 전용 변수

```yaml
_APP_ENV: staging / production
_NODE_ENV: production
_SERVICE_NAME: piip-webapp-intranet
_REGION: asia-northeast3
_ARTIFACT_REGISTRY: piip-docker-repo
_BUILD_TARGET: patch / minor
```

## 보안 관리

### Secret Manager

- GitHub SSH 키
- NPM 인증 토큰 (암호화)

### Cloud KMS

- `.npmrc` 파일 암호화/복호화
- `staging-npm.enc` → `.npmrc`

### IAM 권한

- Cloud Build 서비스 계정
  - Artifact Registry Writer
  - App Engine Deployer
  - Secret Manager Accessor

## 타임아웃 설정

| 단계            | 타임아웃      | 이유               |
| --------------- | ------------- | ------------------ |
| 전체 파이프라인 | 3600s (1시간) | 안전 마진          |
| 패키지 빌드     | 2400s (40분)  | Monorepo 전체 빌드 |
| Docker 빌드     | 3600s (1시간) | 대용량 이미지      |

## 트러블슈팅

### Artifact Registry 이미지 삭제 실패

```bash
# 수동 확인
gcloud artifacts docker images list \
  asia-northeast3-docker.pkg.dev/PROJECT/REPO/SERVICE

# 수동 삭제
gcloud artifacts docker images delete \
  asia-northeast3-docker.pkg.dev/PROJECT/REPO/SERVICE@sha256:xxx \
  --delete-tags --quiet
```

### App Engine 버전 정리 실패

```bash
# 버전 목록 확인
gcloud app versions list --service piip-webapp-intranet

# 수동 삭제
gcloud app versions delete VERSION_ID --service piip-webapp-intranet
```

### NPM 인증 실패

```bash
# KMS 키 확인
gcloud kms keys list --location global --keyring piip-keyring

# 수동 복호화
gcloud kms decrypt \
  --ciphertext-file=staging-npm.enc \
  --plaintext-file=.npmrc \
  --location=global \
  --keyring=piip-keyring \
  --key=npm-token-key
```

## 모니터링

### Cloud Build 로그

```
https://console.cloud.google.com/cloud-build/builds
```

### Artifact Registry 사용량

```
https://console.cloud.google.com/artifacts
```

### App Engine 버전

```
https://console.cloud.google.com/appengine/versions
```

## 개선 사항 (추가된 기능)

### Before (이미지 정리 전)

```
문제점:
- Artifact Registry 이미지 무한 누적
- 스토리지 비용 증가
- 관리 어려움
```

### After (이미지 정리 후)

```
개선:
✅ 자동 이미지 정리 (11개 유지)
✅ 스토리지 비용 91% 절감
✅ 롤백 가능성 유지 (10개 백업)
✅ 배포 파이프라인 통합
```

## 참고 자료

- [Google Cloud Build 문서](https://cloud.google.com/build/docs)
- [Artifact Registry 가격](https://cloud.google.com/artifact-registry/pricing)
- [App Engine 표준 환경](https://cloud.google.com/appengine/docs/standard)
- [Lerna Monorepo 관리](https://lerna.js.org/)
