# Private npm Registry → GCP Artifact Registry 마이그레이션 가이드

Lerna 기반 Monorepo를 기존 private npm registry에서 GCP Artifact Registry로 마이그레이션한 경험을 공유합니다.

## 목차

1. [마이그레이션 배경](#마이그레이션-배경)
2. [사전 준비](#사전-준비)
3. [GCP Artifact Registry 설정](#gcp-artifact-registry-설정)
4. [로컬 개발 환경 설정](#로컬-개발-환경-설정)
5. [Monorepo 설정 업데이트](#monorepo-설정-업데이트)
6. [CI/CD 파이프라인 설정](#cicd-파이프라인-설정)
7. [트러블슈팅](#트러블슈팅)
8. [교훈](#교훈)

---

## 마이그레이션 배경

### 기존 방식의 문제점

- **보안**: KMS로 암호화된 영구 npm 토큰 사용 (보안 취약)
- **관리**: 토큰 만료 시 수동 갱신 및 재암호화 필요
- **비용**: 별도 npm registry 서비스 유지 비용

### GCP Artifact Registry의 장점

- **보안 강화**: 1시간 만료 OAuth 토큰 자동 생성
- **통합 관리**: GCP IAM으로 권한 통합 관리
- **비용 절감**: GCP 내부 네트워크 무료 (같은 리전)

---

## 사전 준비

### 프로젝트 환경

- **Monorepo**: Lerna 3.20.2 (independent versioning)
- **Package Manager**: Yarn workspaces
- **CI/CD**: Google Cloud Build
- **Packages**: 12개 publishable, 2개 private apps

### 필요한 도구

```bash
# gcloud CLI 설치 확인
gcloud --version

# Node.js & Yarn
node --version
yarn --version
```

### GCP 권한 요구사항

#### 개발자 (로컬 개발)

- `roles/artifactregistry.reader` - 패키지 다운로드

#### CI/CD 서비스 계정

- `roles/artifactregistry.writer` - 패키지 publish

---

## GCP Artifact Registry 설정

### 1. gcloud CLI 인증

```bash
# GCP 프로젝트 인증
gcloud auth login

# Application Default Credentials (로컬 개발용)
gcloud auth application-default login

# 프로젝트 설정
gcloud config set project YOUR_PROJECT_ID
```

### 2. Artifact Registry API 활성화

```bash
gcloud services enable artifactregistry.googleapis.com
```

### 3. npm Repository 생성

```bash
# Staging 환경
gcloud artifacts repositories create npm-private \
  --repository-format=npm \
  --location=asia-northeast3 \
  --description="Private npm packages" \
  --project=YOUR_PROJECT_STAGING

# Production 환경
gcloud artifacts repositories create npm-private \
  --repository-format=npm \
  --location=asia-northeast3 \
  --description="Private npm packages" \
  --project=YOUR_PROJECT_PROD
```

**Registry URL 형식:**

```
https://asia-northeast3-npm.pkg.dev/YOUR_PROJECT_ID/npm-private/
```

### 4. CI/CD 서비스 계정 권한 부여

```bash
# Cloud Build 서비스 계정 확인
PROJECT_NUMBER=$(gcloud projects describe YOUR_PROJECT_ID --format="value(projectNumber)")
CLOUDBUILD_SA="${PROJECT_NUMBER}@cloudbuild.gserviceaccount.com"

# Writer 권한 부여
gcloud artifacts repositories add-iam-policy-binding npm-private \
  --location=asia-northeast3 \
  --project=YOUR_PROJECT_ID \
  --member="serviceAccount:${CLOUDBUILD_SA}" \
  --role="roles/artifactregistry.writer"
```

---

## 로컬 개발 환경 설정

### 1. .npmrc 파일 생성

프로젝트 루트에 `.npmrc` 파일 생성:

```ini
# @your-scope scope를 GCP Artifact Registry로 라우팅
@your-scope:registry=https://asia-northeast3-npm.pkg.dev/YOUR_PROJECT_ID/npm-private/

# 인증 항상 필요
//asia-northeast3-npm.pkg.dev/YOUR_PROJECT_ID/npm-private/:always-auth=true

# 기타 public 패키지는 npmjs.org 사용
registry=https://registry.npmjs.org/

# 인증 토큰 (1시간 유효)
//asia-northeast3-npm.pkg.dev/YOUR_PROJECT_ID/npm-private/:_authToken=YOUR_TOKEN_HERE
```

### 2. 토큰 자동 생성 스크립트

```bash
# 토큰 생성 및 .npmrc 업데이트
TOKEN=$(gcloud auth print-access-token)
cat > .npmrc <<EOF
@your-scope:registry=https://asia-northeast3-npm.pkg.dev/YOUR_PROJECT_ID/npm-private/
//asia-northeast3-npm.pkg.dev/YOUR_PROJECT_ID/npm-private/:always-auth=true
registry=https://registry.npmjs.org/
//asia-northeast3-npm.pkg.dev/YOUR_PROJECT_ID/npm-private/:_authToken=${TOKEN}
EOF
```

### 3. Shell 별칭 설정 (권장)

`~/.zshrc` 또는 `~/.bashrc`에 추가:

```bash
alias npm-auth='TOKEN=$(gcloud auth print-access-token) && sed -i "" "s|:_authToken=.*|:_authToken=${TOKEN}|" .npmrc && echo "✅ NPM 인증 토큰 갱신 완료"'
```

사용:

```bash
npm-auth  # 토큰 갱신 (1시간마다)
```

### 4. .gitignore 업데이트

```bash
# .npmrc에 토큰이 포함되므로 반드시 gitignore
echo ".npmrc" >> .gitignore
```

### 5. .npmrc.template 생성 (팀원용)

```ini
# .npmrc.template (저장소에 커밋 가능)

@your-scope:registry=https://asia-northeast3-npm.pkg.dev/YOUR_PROJECT_ID/npm-private/
//asia-northeast3-npm.pkg.dev/YOUR_PROJECT_ID/npm-private/:always-auth=true
registry=https://registry.npmjs.org/

# 사용 방법:
# 1. cp .npmrc.template .npmrc
# 2. gcloud auth application-default login
# 3. npm-auth (별칭 사용)
```

---

## Monorepo 설정 업데이트

### 1. package.json publishConfig 수정

**문제**: 기존에는 `publishConfig`에 registry URL을 하드코딩

**해결**: `.npmrc`의 scope 라우팅 사용

**수정 전:**

```json
{
  "name": "@your-scope/package-name",
  "publishConfig": {
    "registry": "https://old-registry.example.com"
  }
}
```

**수정 후:**

```json
{
  "name": "@your-scope/package-name",
  "publishConfig": {}
}
```

### 2. 일괄 업데이트 스크립트

```bash
# macOS
find packages/* -name "package.json" -type f -not -path "*/node_modules/*" -exec \
  sed -i '' 's/"registry": "https:\/\/old-registry\.example\.com"//' {} \;

# Linux
find packages/* -name "package.json" -type f -not -path "*/node_modules/*" -exec \
  sed -i 's/"registry": "https:\/\/old-registry\.example\.com"//' {} \;
```

### 3. Private 패키지는 제외

`"private": true` 패키지는 publish하지 않으므로 수정 불필요:

```json
{
  "name": "your-app",
  "private": true,
  "publishConfig": {
    "registry": "..." // 그대로 유지 (영향 없음)
  }
}
```

---

## CI/CD 파이프라인 설정

### 주요 변경 사항

#### Before: KMS 암호화 토큰 방식

```yaml
# 기존 방식 (제거)
- name: gcr.io/cloud-builders/gcloud
  args:
    - kms
    - decrypt
    - "--ciphertext-file=npm-token.enc"
    - "--plaintext-file=.npmrc"
    - "--location=global"
    - "--keyring=npm-keyring"
    - "--key=npm-key"
```

#### After: OAuth 동적 토큰 생성

```yaml
# 새 방식
- name: "gcr.io/cloud-builders/gcloud"
  entrypoint: "bash"
  args:
    - "-c"
    - |
      cat > .npmrc <<EOF
      @your-scope:registry=https://asia-northeast3-npm.pkg.dev/YOUR_PROJECT_ID/npm-private/
      registry=https://registry.npmjs.org/
      EOF
      echo "//asia-northeast3-npm.pkg.dev/YOUR_PROJECT_ID/npm-private/:_authToken=$(gcloud auth print-access-token)" >> .npmrc
      echo "//asia-northeast3-npm.pkg.dev/YOUR_PROJECT_ID/npm-private/:always-auth=true" >> .npmrc
      echo "Generated .npmrc for Artifact Registry"
  id: "Setup Artifact Registry auth"
```

### Cloud Build 전체 워크플로우

```yaml
steps:
  # 1. SSH 설정 (Git 작업용)
  - name: gcr.io/cloud-builders/gcloud
    entrypoint: "bash"
    args:
      - "-c"
      - "gcloud secrets versions access latest --secret=GIT_SECRET > /root/.ssh/id_github"
    volumes:
      - name: "ssh"
        path: /root/.ssh

  # 2. Git 설정
  - name: "gcr.io/cloud-builders/git"
    entrypoint: "bash"
    args:
      - "-c"
      - |
        chmod 600 /root/.ssh/id_github
        cat <<EOF >/root/.ssh/config
        Hostname github.com
        IdentityFile /root/.ssh/id_github
        EOF
        ssh-keyscan -t rsa github.com > /root/.ssh/known_hosts
    volumes:
      - name: "ssh"
        path: /root/.ssh

  # 3. Git remote 설정
  - name: "gcr.io/cloud-builders/git"
    entrypoint: "bash"
    args:
      - "-c"
      - |
        git remote set-url origin git@github.com:YOUR_ORG/YOUR_REPO
        git config --global user.email ci-bot@example.com
        git config --global user.name CI-Bot
        git fetch origin -q --unshallow
    volumes:
      - name: "ssh"
        path: /root/.ssh

  # 4. Artifact Registry 인증 (핵심!)
  - name: "gcr.io/cloud-builders/gcloud"
    entrypoint: "bash"
    args:
      - "-c"
      - |
        cat > .npmrc <<EOF
        @your-scope:registry=https://asia-northeast3-npm.pkg.dev/YOUR_PROJECT_ID/npm-private/
        registry=https://registry.npmjs.org/
        EOF
        echo "//asia-northeast3-npm.pkg.dev/YOUR_PROJECT_ID/npm-private/:_authToken=$(gcloud auth print-access-token)" >> .npmrc
        echo "//asia-northeast3-npm.pkg.dev/YOUR_PROJECT_ID/npm-private/:always-auth=true" >> .npmrc
        echo "Generated .npmrc for Artifact Registry"
    id: "Setup Artifact Registry auth"

  # 5. Yarn logout (에러 무시)
  - name: node:14
    entrypoint: yarn
    args: ["logout"]
    id: "Logout yarn"

  # 6. npm whoami 확인 (OAuth는 미지원 - 에러 무시)
  - name: node:14
    entrypoint: "bash"
    args:
      - "-c"
      - |
        npm whoami || echo "⚠️ npm whoami not supported with Artifact Registry (using OAuth)"
    id: "Check current logged user"

  # 7. 의존성 설치
  - name: node:14
    entrypoint: yarn
    args: ["install"]
    id: "Yarn install"

  # 8. Lerna bootstrap
  - name: node:14
    entrypoint: yarn
    args: ["bootstrap"]
    id: "Yarn Lerna bootstrap"

  # 9. 테스트 실행
  - name: node:14
    entrypoint: "bash"
    args:
      - "-c"
      - |
        yarn lerna run test:ci --since --parallel --stream
    id: "Test only what is changed"

  # 10. 패키지 빌드
  - name: node:14
    entrypoint: "bash"
    args:
      - "-c"
      - |
        yarn run packages:build
        git reset --hard
    timeout: 2400s
    id: "Build packages"

  # 11. 버전 패치
  - name: node:14
    entrypoint: "bash"
    args:
      - "-c"
      - |
        yarn packages:version:${_BUILD_TARGET}
    volumes:
      - name: "ssh"
        path: /root/.ssh
    id: "Patch versions"

  # 12. 패키지 publish
  - name: node:14
    entrypoint: "bash"
    args:
      - "-c"
      - |
        ./scripts/publish-packages.sh
    volumes:
      - name: "ssh"
        path: /root/.ssh
    env: ["BUILD_TARGET=$_BUILD_TARGET"]
    id: "Publish packages"

timeout: 3600s
options:
  substitution_option: "ALLOW_LOOSE"
```

### publish-packages.sh 스크립트

```bash
#!/usr/bin/env bash

in_array() {
    local needle array value
    needle="${1}"; shift; array=("${@}")
    for value in ${array[@]}; do [ "${value}" == "${needle}" ] && echo "true" && return; done
    echo "false"
}

release_array=("minor" "patch" "prerelease")
release_check=`in_array $BUILD_TARGET ${release_array[@]} == "true"`

if [[ "${release_check}" == "true" ]]; then
    yarn packages:publish:release
elif [[ "$BUILD_TARGET" == "canary" ]]; then
    yarn packages:publish:canary
fi
```

### 개별 서비스 빌드 파일 (.npmrc 복사 필요)

애플리케이션 패키지 빌드 시 `.npmrc` 복사:

```yaml
# packages/your-app/cloudbuild.yaml

steps:
  # ... 이전 단계들 ...

  # .npmrc 복사
  - name: "gcr.io/cloud-builders/gcloud"
    entrypoint: "bash"
    args:
      - "-c"
      - |
        cp .npmrc ./packages/${_SERVICE_NAME}/.npmrc
    id: "Copy npmrc to service directory"

  # 서비스 빌드
  - name: node:14
    entrypoint: yarn
    args: ["build"]
    dir: "packages/${_SERVICE_NAME}"
    id: "Build service"
```

---

## 트러블슈팅

### 1. OAuth 관련 에러

#### npm whoami 실패

**에러:**

```
npm ERR! code ENEEDAUTH
npm ERR! need auth This command requires you to be logged in.
```

**원인**: GCP Artifact Registry는 OAuth를 사용하므로 `npm whoami` 미지원

**해결**: 에러 무시 처리

```yaml
npm whoami || echo "⚠️ npm whoami not supported with Artifact Registry (using OAuth)"
```

#### yarn logout 실패

**현상**: `yarn logout` 실패 (실제로는 에러 없음)

**원인**: OAuth 방식에서는 login/logout 개념이 없음

**해결**: 별도 처리 불필요 (그냥 실행해도 됨)

### 2. 인증 오류

#### 401 Unauthorized

**로컬 개발:**

```bash
# Application Default Credentials 재설정
gcloud auth application-default login

# 토큰 재생성
npm-auth

# 권한 확인
gcloud projects get-iam-policy YOUR_PROJECT_ID \
  --flatten="bindings[].members" \
  --filter="bindings.members:user:$(gcloud config get-value account)"
```

**CI/CD:**

```bash
# Cloud Build 서비스 계정 확인
PROJECT_NUMBER=$(gcloud projects describe YOUR_PROJECT_ID --format="value(projectNumber)")
echo "${PROJECT_NUMBER}@cloudbuild.gserviceaccount.com"

# 권한 확인
gcloud artifacts repositories get-iam-policy npm-private \
  --location=asia-northeast3 \
  --project=YOUR_PROJECT_ID
```

#### 403 Forbidden

**원인**: Artifact Registry 읽기 권한 없음

**해결**:

```bash
# 개발자에게 읽기 권한 부여
gcloud artifacts repositories add-iam-policy-binding npm-private \
  --location=asia-northeast3 \
  --project=YOUR_PROJECT_ID \
  --member="user:developer@example.com" \
  --role="roles/artifactregistry.reader"
```

### 3. 로컬 개발 워크플로우

#### 토큰 만료 에러

**현상**: 1시간 후 `yarn install` 실패

**해결**:

```bash
# 매번 작업 시작 시 실행
npm-auth && yarn install
```

#### Monorepo 클린 설치

**워크플로우**:

```bash
# 1. 토큰 갱신
npm-auth

# 2. 클린 설치
yarn clean && yarn clean:next && yarn install --force && yarn bootstrap

# 3. 빌드
yarn packages:build
```

**중요**: `yarn install` 전에 반드시 토큰 갱신 필요

- `yarn install`이 먼저 Artifact Registry에서 패키지 다운로드 시도
- 이후 `yarn bootstrap`이 로컬 심볼릭 링크로 교체
- 첫 번째 단계에서 토큰 없으면 실패

### 4. Cloud Build 디버깅

#### Step 실패 시 로그 확인

```bash
# 최근 빌드 목록
gcloud builds list --limit=5 --project=YOUR_PROJECT_ID

# 특정 빌드 로그
gcloud builds log BUILD_ID --project=YOUR_PROJECT_ID

# .npmrc 생성 확인
# 로그에서 "Generated .npmrc for Artifact Registry" 메시지 찾기
```

#### 패키지 설치 실패

**확인 사항:**

1. ✅ Step 'Setup Artifact Registry auth' 성공?
2. ✅ `.npmrc` 파일 생성됨?
3. ✅ Cloud Build 서비스 계정에 `artifactregistry.writer` 권한?
4. ✅ Registry URL이 올바른지?

---

## 교훈

### 1. OAuth vs npm Token

**npm 전통 방식:**

- ❌ 영구 토큰 (보안 취약)
- ❌ 수동 관리 필요
- ❌ `npm login`, `npm whoami`, `npm logout` 사용

**GCP OAuth 방식:**

- ✅ 1시간 만료 토큰 (보안 강화)
- ✅ 자동 생성 (`gcloud auth print-access-token`)
- ⚠️ `npm whoami` 미지원 (무시 처리 필요)

### 2. Scope 기반 Registry 라우팅

**핵심 개념:**

```ini
# @your-scope 패키지는 private registry
@your-scope:registry=https://asia-northeast3-npm.pkg.dev/YOUR_PROJECT_ID/npm-private/

# 나머지는 public registry
registry=https://registry.npmjs.org/
```

**장점:**

- Public 패키지는 npmjs.org에서 (빠름)
- Private 패키지만 Artifact Registry에서
- 별도 설정 없이 자동 라우팅

### 3. CI/CD 자동화

**Before (수동):**

1. npm 토큰 생성
2. KMS로 암호화
3. 암호화 파일 저장소에 커밋
4. CI/CD에서 복호화

**After (자동):**

1. Cloud Build 서비스 계정 IAM 권한만 부여
2. 런타임에 `gcloud auth print-access-token` 자동 실행
3. 토큰 수동 관리 완전 제거

### 4. Monorepo 특수 케이스

**문제**:

- Yarn workspaces에서 내부 패키지가 `dependencies`에 버전으로 명시됨
- `yarn install` 시 Artifact Registry에서 먼저 다운로드 시도

**해결**:

- 로컬: `npm-auth` 먼저 실행 후 `yarn install`
- CI/CD: `.npmrc` 자동 생성 후 `yarn install`
- `yarn bootstrap`이 심볼릭 링크로 교체

### 5. 보안 Best Practices

✅ **DO:**

- `.npmrc`를 `.gitignore`에 추가
- 짧은 만료 시간 토큰 사용 (1시간)
- IAM으로 최소 권한 원칙 적용
- 개발자는 reader, CI/CD는 writer

❌ **DON'T:**

- 토큰을 저장소에 커밋
- 영구 토큰 사용
- 모든 사용자에게 writer 권한

### 6. 비용 최적화

**무료:**

- Cloud Build ↔ Artifact Registry (같은 리전)
- asia-northeast3 ↔ asia-northeast3

**유료:**

- 다른 리전에서 접근 시 네트워크 송신 비용
- 스토리지 비용 (구버전 정리 권장)

**스토리지 정리 정책:**

```bash
cat > cleanup-policy.json <<EOF
{
  "rules": [
    {
      "id": "delete-old-versions",
      "action": "DELETE",
      "condition": {
        "olderThan": "90d",
        "versionNamePatterns": ["**"],
        "newerVersions": 5
      }
    }
  ]
}
EOF

gcloud artifacts repositories set-cleanup-policies npm-private \
  --location=asia-northeast3 \
  --policy=cleanup-policy.json
```

---

## 체크리스트

### 마이그레이션 전

- [x] GCP 프로젝트 생성 및 권한 확인
- [x] Artifact Registry API 활성화
- [x] npm repository 생성 (staging, production)
- [x] Artifact Registry admin 권한 확인

### 로컬 설정

- [x] `.npmrc` 생성 및 토큰 발급
- [x] `.npmrc.template` 작성
- [x] `.gitignore`에 `.npmrc` 추가
- [x] `npm-auth` 별칭 추가
- [x] 토큰 갱신 후 `yarn install` 테스트

### 코드 수정

- [x] 모든 `package.json`의 `publishConfig` 업데이트
- [x] Cloud Build YAML 파일 수정 (OAuth 방식)
- [x] `npm whoami` 에러 처리 추가
- [x] 개별 서비스 빌드 파일에 `.npmrc` 복사 추가

### 테스트

- [x] 로컬에서 `yarn install` 성공 확인
- [x] 로컬에서 `yarn packages:build` 성공 확인
- [x] Cloud Build에서 빌드 성공 확인
- [x] 패키지 publish 테스트 (canary)
- [x] 패키지 다운로드 테스트

### 문서화

- [x] 팀원에게 새 registry 설정 안내

---

## 참고 자료

- [GCP Artifact Registry Documentation](https://cloud.google.com/artifact-registry/docs)
- [Artifact Registry Node.js Quickstart](https://cloud.google.com/artifact-registry/docs/nodejs/quickstart)
- [Cloud Build Configuration](https://cloud.google.com/build/docs/build-config-file-schema)
- [Lerna Documentation](https://lerna.js.org/)
- [npm Scoped Packages](https://docs.npmjs.com/cli/v9/using-npm/scope)

---

## 요약

### 핵심 변경 사항

| 항목              | Before              | After               |
| ----------------- | ------------------- | ------------------- |
| **인증 방식**     | KMS 암호화 npm 토큰 | OAuth 동적 토큰     |
| **토큰 유효기간** | 영구                | 1시간               |
| **토큰 관리**     | 수동 갱신/재암호화  | 자동 생성           |
| **권한 관리**     | npm 토큰 공유       | GCP IAM             |
| **로컬 개발**     | 토큰 한 번만 설정   | 1시간마다 갱신 필요 |
| **CI/CD**         | 암호화 파일 관리    | 서비스 계정 권한    |
| **보안**          | 토큰 유출 위험      | 단기 토큰 + IAM     |

### 마이그레이션 효과

✅ **장점:**

- 보안 강화 (1시간 만료 토큰)
- 관리 자동화 (토큰 수동 관리 제거)
- 비용 절감 (GCP 내부 네트워크 무료)
- 통합 권한 관리 (GCP IAM)

⚠️ **단점:**

- 로컬 개발 시 1시간마다 토큰 갱신 필요
- OAuth 미지원 npm 명령어 에러 처리 필요
- 초기 설정 복잡도 증가

📈 **결과:**

- CI/CD 토큰 관리 시간: 100% 절감
- 보안 취약점: 제거
- 개발자 경험: npm-auth 별칭으로 간소화
