# NPM Token & Lerna Publish 에러 해결 과정

## 목차

1. [배경 및 초기 문제](#배경-및-초기-문제)
2. [CI/CD 전체 플로우](#cicd-전체-플로우)
3. [에러 #1: NPM Token 만료](#에러-1-npm-token-만료)
4. [에러 #2: Lerna Publish 실패 (Granular Token)](#에러-2-lerna-publish-실패-granular-token)
5. [최종 해결](#최종-해결)
6. [학습 내용](#학습-내용)

---

## 배경 및 초기 문제

### 프로젝트 구조

- **Monorepo**: Lerna 3.20.2 + Yarn Workspaces
- **Private Packages**: `@private-package/*` 스코프의 14개 패키지
- **CI/CD**: GCP Cloud Build (Staging & Production)
- **NPM Token**: KMS로 암호화하여 사용

### 초기 상황

- GCP Cloud Build용 NPM Token이 2026년 3월 8일 만료 예정
- 로컬 개발용 NPM Token은 2999년 만료 (문제 없음)
- 90일마다 토큰 재발급하는 것이 번거로움 → 장기 토큰으로 교체 결정

---

## CI/CD 전체 플로우

### 브랜치 전략

현재 프로젝트는 **Candidate Branch 전략**을 사용합니다:

```
develop (메인 개발 브랜치)
  ↓
candidate/staging/piip-webapp-intranet  (Staging CD 트리거)
candidate/staging/piip-webapp-front
candidate/production/piip-webapp-intranet  (Production CD 트리거)
candidate/production/piip-webapp-front
```

### GCP Cloud Build 트리거 구성

#### CI 트리거 (Integration)

```
트리거 이름: Integration-piip-webapp-monorepo
브랜치: develop
파일: cloudbuild-staging.yaml
역할: 빌드, 테스트, 버전 관리, NPM 배포
```

#### CD 트리거 (Deployment)

```
트리거 이름: Deploy-piip-staging-intranet
브랜치: candidate/staging/piip-webapp-intranet
파일: packages/piip-webapp-intranet/piip-intranet-staging-build.yaml
역할: Docker 빌드 및 App Engine 배포
```

### 전체 플로우 (Staging 환경 기준)

```
┌─────────────────────────────────────────────────────────────┐
│ 1. 개발자가 코드 변경                                       │
│    - piip-site-modules/src/components/Tag.js 수정           │
└────────────────┬────────────────────────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────────────────────────┐
│ 2. develop 브랜치에 커밋 & 푸시                             │
│    git push origin develop                                  │
└────────────────┬────────────────────────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────────────────────────┐
│ 3. CI 트리거 자동 실행                                      │
│    Integration-piip-webapp-monorepo (develop 브랜치)        │
│    cloudbuild-staging.yaml 실행                             │
└────────────────┬────────────────────────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────────────────────────┐
│ 4. Git 설정 & SSH 키 복호화                                 │
│    - Secret Manager에서 GitHub SSH 키 가져오기             │
│    - Git 사용자 설정 (ci-bot@example.com)                  │
└────────────────┬────────────────────────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────────────────────────┐
│ 5. NPM 토큰 복호화                                          │
│    gcloud kms decrypt                                        │
│      --ciphertext-file=staging-npm.enc                      │
│      --plaintext-file=.npmrc                                │
│    → npm_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx              │
└────────────────┬────────────────────────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────────────────────────┐
│ 6. 의존성 설치                                              │
│    yarn install (프라이빗 패키지 다운로드)                 │
│    yarn bootstrap (Lerna monorepo 설정)                    │
└────────────────┬────────────────────────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────────────────────────┐
│ 7. 테스트 실행                                              │
│    yarn test:ci (변경된 패키지만 테스트)                   │
└────────────────┬────────────────────────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────────────────────────┐
│ 8. 패키지 빌드                                              │
│    yarn packages:build                                      │
│    → packages/*/lib/ 디렉토리에 빌드 결과 생성             │
└────────────────┬────────────────────────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────────────────────────┐
│ 9. Candidate 브랜치 생성 ⚡ (CD 트리거 준비)               │
│    yarn lerna run pipeline:git:branch --since               │
│    → candidate/staging/piip-webapp-intranet 생성            │
│    → candidate/staging/piip-webapp-front 생성               │
│    (변경된 모듈이 있을 때만 생성)                           │
└────────────────┬────────────────────────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────────────────────────┐
│ 10. 버전 업데이트 ⚡ (Git Tag 생성)                        │
│     yarn packages:version:patch                             │
│     → Lerna가 변경된 패키지 감지                           │
│     → package.json 버전 업데이트                           │
│       @private-package/piip-site-modules: 1.0.236 → 1.0.237      │
│     → Git 태그 생성                                        │
│       @private-package/piip-site-modules@1.0.237                 │
│     → develop 브랜치에 커밋                                │
└────────────────┬────────────────────────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────────────────────────┐
│ 11. NPM 배포                                                │
│     yarn packages:publish:release                           │
│     → lerna publish from-git --yes --no-verify-access      │
│     → Git 태그 기반으로 NPM에 배포                         │
│     → @private-package/piip-site-modules@1.0.237 published       │
└────────────────┬────────────────────────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────────────────────────┐
│ 12. Candidate 브랜치 푸시 ⚡ (CD 트리거 발동!)             │
│     git push -u origin refs/heads/candidate/staging/piip-*  │
│     → candidate/staging/piip-webapp-intranet 푸시           │
│     → candidate/staging/piip-webapp-front 푸시              │
└────────────────┬────────────────────────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────────────────────────┐
│ 13. CD 트리거 자동 실행 🚀                                  │
│     Deploy-piip-staging-intranet 트리거                     │
│     (candidate/staging/piip-webapp-intranet 브랜치)         │
│     piip-intranet-staging-build.yaml 실행                   │
└────────────────┬────────────────────────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────────────────────────┐
│ 14. Docker 이미지 빌드                                      │
│     docker build -t asia-northeast3-docker.pkg.dev/...      │
│     → Next.js 애플리케이션 빌드 포함                       │
└────────────────┬────────────────────────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────────────────────────┐
│ 15. Artifact Registry에 푸시                                │
│     docker push asia-northeast3-docker.pkg.dev/...          │
└────────────────┬────────────────────────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────────────────────────┐
│ 16. App Engine 배포                                         │
│     gcloud app deploy                                       │
│     → 이전 버전 자동 중지                                  │
│     → 새 버전으로 트래픽 전환                              │
└────────────────┬────────────────────────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────────────────────────┐
│ 17. 구버전 정리                                             │
│     최근 10개 버전 제외하고 삭제                            │
└─────────────────────────────────────────────────────────────┘
```

### CD 트리거 조건

**CD가 실행되는 조건:**

1. **Candidate 브랜치 푸시**

   ```
   candidate/staging/piip-webapp-intranet
   candidate/staging/piip-webapp-front
   ```

2. **Candidate 브랜치가 생성되는 조건**

   - `lerna version`이 모듈 버전을 업데이트했을 때
   - 즉, **변경된 모듈이 있을 때만!**

3. **버전 업데이트 기준**
   - Git 히스토리에서 마지막 태그 이후 변경사항 확인
   - 변경된 패키지만 버전 증가

### 시나리오별 동작

#### 시나리오 1: 모듈 변경 있음 (CD 실행)

```
1. piip-site-modules/src/components/Tag.js 수정
2. develop에 푸시
3. CI: 빌드 & 테스트
4. CI: lerna version
   → piip-site-modules: 1.0.236 → 1.0.237
   → Git 태그 생성: @private-package/piip-site-modules@1.0.237
5. CI: candidate/staging/piip-webapp-intranet 브랜치 생성 & 푸시
6. CD: Deploy-piip-staging-intranet 자동 실행 ✅
7. CD: Docker 빌드 & App Engine 배포
```

#### 시나리오 2: 모듈 변경 없음 (CD 실행 안 됨)

```
1. README.md만 수정
2. develop에 푸시
3. CI: 빌드 & 테스트
4. CI: lerna version
   → 변경된 패키지 없음
   → 버전 업데이트 안 함
5. CI: candidate 브랜치 생성 안 함
6. CD: 실행 안 됨 ❌
```

#### 시나리오 3: 여러 모듈 동시 변경

```
1. piip-site-modules, piip-finance-modules 수정
2. develop에 푸시
3. CI: lerna version
   → piip-site-modules: 1.0.236 → 1.0.237
   → piip-finance-modules: 1.0.135 → 1.0.136
4. CI: candidate 브랜치 푸시
5. CD: Deploy-piip-staging-intranet 실행 ✅
   (piip-webapp-intranet가 두 모듈에 의존하므로)
```

### refs/heads/ 표기법

```bash
git push -u origin refs/heads/candidate/staging/piip-*
                   ↑
                   Git 내부 참조 경로 (브랜치임을 명시)
```

**의미:**

- `refs/heads/` = 로컬 브랜치
- `refs/remotes/` = 원격 브랜치
- `refs/tags/` = 태그

**장점:**

- 브랜치와 태그를 명확히 구분
- 와일드카드 사용 시 더 안전
- CI/CD 스크립트에서 명확성 확보

### 핵심 포인트

1. **CI (Integration)**

   - 트리거: develop 브랜치 푸시
   - 역할: 빌드, 테스트, 버전 관리, NPM 배포, Candidate 브랜치 생성

2. **CD (Deployment)**

   - 트리거: candidate 브랜치 푸시 (CI가 자동 생성)
   - 역할: Docker 빌드 & App Engine 배포

3. **CD 트리거 조건**

   - `lerna version`이 모듈 버전을 업데이트했을 때
   - 변경된 모듈이 있을 때만 candidate 브랜치 생성
   - candidate 브랜치 푸시 → CD 자동 실행

4. **Candidate 브랜치의 역할**
   - develop 브랜치 내용을 그대로 복사
   - CD 전용 트리거 브랜치
   - 환경별(staging/production), 서비스별(intranet/front) 분리

---

## 에러 #1: NPM Token 만료

### 문제 발견

GCP Cloud Build 토큰 만료일 확인 필요:

- Staging 환경: `staging-npm.enc`
- Production 환경: `npm.enc`

### 토큰 저장 방식

#### 로컬 개발 환경

```bash
# 위치: ~/.npmrc
//registry.npmjs.org/:_authToken=npm_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
```

#### GCP Cloud Build 환경

```
평문 토큰 (.npmrc)
    ↓ KMS 암호화
암호화된 파일 (staging-npm.enc, npm.enc)
    ↓ Git 커밋
    ↓ Cloud Build 실행 시
    ↓ KMS 복호화
평문 토큰 (.npmrc)
    ↓
yarn install 실행
```

### 해결 과정

#### 1. GCP KMS 설정 확인

**Staging 환경:**

```bash
Project:  piip-intra-staging
Keyring:  piip-intra-staging-keyring
Key:      api-config-key
Location: global
```

**Production 환경:**

```bash
Project:  piip-intra
Keyring:  piip-intra-keyring
Key:      api-config-key
Location: global
```

#### 2. 기존 토큰 복호화 및 확인

```bash
# Staging 토큰 복호화
gcloud kms decrypt \
  --ciphertext-file=staging-npm.enc \
  --plaintext-file=/dev/stdout \
  --location=global \
  --keyring=piip-intra-staging-keyring \
  --key=api-config-key \
  --project=piip-intra-staging

# 출력: //registry.npmjs.org/:_authToken=xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
```

**발견**: 기존 토큰은 Classic Token (UUID 형식)

#### 3. 새 토큰 생성

**로컬용 토큰:**

```
npm_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx (예시)
```

**GCP용 토큰:**

```
npm_yyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyy (예시)
```

**특징**: Granular Access Token (npm\_ 접두사)

#### 4. 로컬 토큰 교체

```bash
# 백업
cp ~/.npmrc ~/.npmrc.backup.20251208

# 새 토큰으로 교체
cat > ~/.npmrc << 'EOF'
//registry.npmjs.org/:_authToken=npm_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
EOF

# 검증
npm whoami
# 출력: your-username ✅
```

#### 5. GCP용 토큰 암호화

```bash
# .npmrc 파일 생성
cat > .npmrc << 'EOF'
//registry.npmjs.org/:_authToken=npm_yyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyy
EOF

# Staging 환경 암호화
gcloud kms encrypt \
  --plaintext-file=.npmrc \
  --ciphertext-file=staging-npm.enc \
  --location=global \
  --keyring=piip-intra-staging-keyring \
  --key=api-config-key \
  --project=piip-intra-staging

# Production 환경 암호화
gcloud kms encrypt \
  --plaintext-file=.npmrc \
  --ciphertext-file=npm.enc \
  --location=global \
  --keyring=piip-intra-keyring \
  --key=api-config-key \
  --project=piip-intra

# 평문 삭제 (보안)
rm .npmrc
```

#### 6. 암호화 검증

```bash
# 복호화 테스트
gcloud kms decrypt \
  --ciphertext-file=staging-npm.enc \
  --plaintext-file=/dev/stdout \
  --location=global \
  --keyring=piip-intra-staging-keyring \
  --key=api-config-key \
  --project=piip-intra-staging

# 출력: //registry.npmjs.org/:_authToken=npm_yyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyy ✅
```

### 결과

✅ 로컬 토큰 교체 완료
✅ GCP 토큰 암호화 완료
✅ 복호화 검증 성공

---

## 에러 #2: Lerna Publish 실패 (Granular Token)

### 문제 발생

토큰 교체 후 CI 실행 시 에러:

```
lerna info Verifying npm credentials
lerna notice SECURITY NOTICE: Classic tokens expire December 9...
lerna http fetch GET 403 https://registry.npmjs.org/-/npm/v1/user 229ms
403 Forbidden - GET https://registry.npmjs.org/-/npm/v1/user
lerna ERR! EWHOAMI Authentication error. Use `npm whoami` to troubleshoot.
error Command failed with exit code 1.
```

### 원인 분석

#### 1. 토큰 형식 확인

**Classic Token (Legacy):**

```
형식: ab63a39a-5539-49e5-a4cc-4a68e5281443 (UUID)
권한: Read-Write
/-/npm/v1/user 접근: ✅ 가능
상태: 2024년 12월 9일부터 deprecated
```

**Granular Token (새 방식):**

```
형식: npm_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
권한: Read-Write (생성 시 설정)
/-/npm/v1/user 접근: ❌ 불가능
상태: NPM 권장 방식
```

#### 2. 토큰 권한 테스트

```python
import requests

token = "npm_yyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyy"
headers = {'Authorization': f'Bearer {token}'}

# 기본 인증
r = requests.get('https://registry.npmjs.org/-/whoami', headers=headers)
print(f"/-/whoami: {r.status_code}")  # 200 ✅

# Lerna가 사용하는 엔드포인트
r = requests.get('https://registry.npmjs.org/-/npm/v1/user', headers=headers)
print(f"/-/npm/v1/user: {r.status_code}")  # 403 ❌
```

**결과:**

- `npm whoami` 작동: ✅
- `lerna publish` 실패: ❌

#### 3. Lerna의 동작 방식

```javascript
// Lerna 3.20.2 내부 로직
async function verifyNpmCredentials(token) {
  // NPM API 직접 호출
  const response = await fetch("https://registry.npmjs.org/-/npm/v1/user", {
    headers: { Authorization: `Bearer ${token}` },
  });

  if (response.status === 403) {
    throw new Error("EWHOAMI Authentication error");
  }
}
```

**문제**: Granular Token은 `/-/npm/v1/user` 엔드포인트 접근 불가

### 해결책 조사

#### 시도 1: Classic Token 재사용?

**문제점:**

- Classic Token은 12월 9일부터 deprecated
- 90일마다 재발급 필요
- NPM이 곧 완전히 폐기 예정
- ❌ 장기적 해결책 아님

#### 시도 2: Lerna 업그레이드?

**현재 버전:**

```json
{
  "lerna": "3.20.2" // 2020년 버전
}
```

**최신 버전:**

- Lerna 7.x 또는 8.x (2024년)
- Granular Token 지원 가능성 있음

**문제점:**

- Breaking changes 많음 (3.x → 8.x)
- 테스트 시간 필요
- 프로덕션 시스템이라 급한 변경 위험
- ⚠️ 단기 해결책 아님

#### 시도 3: GitHub Issue 발견! 🎯

**GitHub Issue #2788:**

> "Lerna doesn't work with NPM automation tokens"
> https://github.com/lerna/lerna/issues/2788

**핵심 코멘트 (dyladan):**

> Using `--no-verify-access` may fix this. Automation tokens don't have permission to access the endpoint lerna uses to verify permission.

**해결 방법:**

```bash
lerna publish from-git --yes --no-verify-access
```

### 해결 과정

#### `--no-verify-access` 플래그의 역할

```
기존 동작:
1. Lerna: /-/npm/v1/user 체크
   → 403 Forbidden
   → 중단! (publish 시도조차 안 함)

--no-verify-access 사용 시:
1. Lerna: 권한 체크 건너뜀
2. Lerna: npm publish 실행
3. NPM Registry: 실제 publish 권한 체크
   → 토큰에 권한 있음 ✅
   → 배포 성공!
```

**중요**: NPM Registry가 여전히 권한을 체크하므로 보안 문제 없음

#### 코드 수정

**파일: `package.json`**

```diff
{
  "scripts": {
-   "packages:publish:release": "lerna publish from-git --yes",
+   "packages:publish:release": "lerna publish from-git --yes --no-verify-access",
  }
}
```

#### 새 토큰으로 재암호화

```bash
# 새 Granular Token (Read-write)
npm_zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz

# .npmrc 생성
cat > .npmrc << 'EOF'
//registry.npmjs.org/:_authToken=npm_zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz
EOF

# 암호화
gcloud kms encrypt \
  --plaintext-file=.npmrc \
  --ciphertext-file=staging-npm.enc \
  --location=global \
  --keyring=piip-intra-staging-keyring \
  --key=api-config-key \
  --project=piip-intra-staging

gcloud kms encrypt \
  --plaintext-file=.npmrc \
  --ciphertext-file=npm.enc \
  --location=global \
  --keyring=piip-intra-keyring \
  --key=api-config-key \
  --project=piip-intra

# 평문 삭제
rm .npmrc
```

#### 커밋 및 배포

```bash
git add package.json staging-npm.enc npm.enc
git commit -m "fix: add --no-verify-access flag for lerna publish with Granular Token"
git push
```

### 결과

CI 로그:

```
yarn run v1.22.19
$ lerna publish from-git --yes --no-verify-access
lerna notice cli v3.20.2
lerna info versioning independent
lerna WARN Yarn's registry proxy is broken, replacing with public npm registry
lerna notice from-git No tagged release found
lerna success No changed packages to publish
Done in 1.40s.
```

✅ **에러 해결!** (권한 체크 에러 없음)

---

## 추가 이슈: Git Tag 문제

### 문제

```
lerna notice from-git No tagged release found
lerna success No changed packages to publish
```

### 원인

`lerna publish from-git`은:

1. Git 태그를 찾음 (예: `v1.0.10`)
2. 태그가 있으면 → NPM에 배포
3. 태그가 없으면 → "No tagged release found"

### CI 프로세스

```yaml
# cloudbuild-staging.yaml

# 1. 버전 업데이트 (태그 생성)
- name: node:16
  args: ["yarn", "packages:version:${_BUILD_TARGET}"]
  id: "Patch versions"

# 2. 패키지 배포 (태그에서 publish)
- name: node:16
  args: ["./pipeline/scripts/publish-packages.sh"]
  id: "Publish packages"
```

**`lerna version`**이 Git 태그를 생성함

### 해결 방법

이전 CI 실패로 일부 모듈의 버전이 Git에만 올라가고 NPM에는 배포 안 됨:

```
Local/Git: @private-package/piip-admin-modules@1.0.10 (존재)
NPM:       @private-package/piip-admin-modules@1.0.9 (마지막 성공 버전)
```

**해결**: 각 모듈을 하나씩 수정해서 재배포

```bash
# Finance 모듈 수정 (띄어쓰기 추가 등)
git commit -m "chore: trigger finance module publish"
git push
# → CI 실행 → lerna version → lerna publish → NPM 배포 ✅

# Admin 모듈 수정
git commit -m "chore: trigger admin module publish"
git push
# → 반복...
```

---

## 최종 해결

### 변경 사항 요약

#### 1. NPM 토큰

- **로컬**: Classic → Granular Token (장기)
- **GCP**: Classic → Granular Token (장기)
- **암호화**: KMS로 `staging-npm.enc`, `npm.enc` 생성

#### 2. Lerna 설정

```json
// package.json
{
  "packages:publish:release": "lerna publish from-git --yes --no-verify-access"
}
```

#### 3. 암호화된 파일

```bash
# 최종 토큰
npm_zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz

# 암호화 위치
staging-npm.enc  (Staging)
npm.enc          (Production)
```

### CI/CD 플로우 (최종)

```
1. 코드 변경 & 커밋
        ↓
2. Cloud Build 트리거
        ↓
3. KMS로 NPM 토큰 복호화
        ↓
4. yarn install (Granular Token으로 성공 ✅)
        ↓
5. yarn bootstrap
        ↓
6. lerna version (Git 태그 생성)
        ↓
7. lerna publish --no-verify-access (Granular Token으로 성공 ✅)
        ↓
8. Docker 빌드 & 배포
```

---

## 학습 내용

### 1. NPM Token 종류

| 특징             | Classic Token       | Granular Token               |
| ---------------- | ------------------- | ---------------------------- |
| 형식             | UUID                | `npm_xxxxx`                  |
| 만료             | 12/9부터 deprecated | NPM 권장                     |
| 권한             | 전체 또는 Read-only | 세밀한 권한 설정             |
| `/-/whoami`      | ✅                  | ✅                           |
| `/-/npm/v1/user` | ✅                  | ❌                           |
| Lerna 3.20.2     | ✅                  | ⚠️ `--no-verify-access` 필요 |

### 2. Lerna Publish 동작

```bash
# from-git: Git 태그에서 버전 확인 후 배포
lerna publish from-git --yes

# 프로세스
1. Git 태그 찾기 (v1.0.10, v1.0.68 등)
2. npm 권한 체크 (/-/npm/v1/user) ← Granular Token 실패
3. 각 패키지 npm publish 실행
```

### 3. KMS 암호화/복호화

```bash
# 암호화
plaintext (.npmrc) → [KMS] → ciphertext (staging-npm.enc)

# 복호화
ciphertext (staging-npm.enc) → [KMS] → plaintext (.npmrc)

# 특징
- 같은 평문 → 매번 다른 암호문 (보안 강화)
- 다른 KMS 키 → 다른 암호문
- 복호화 결과는 항상 동일
```

### 4. Monorepo 패키지 관리

**Lerna의 역할:**

- 여러 패키지의 버전 관리 (`lerna version`)
- 변경된 패키지만 배포 (`lerna publish`)
- 의존성 관리 (`lerna bootstrap`)

**프라이빗 패키지:**

- `@private-package/*` 스코프
- NPM 토큰 없이는 설치 불가
- Monorepo 내부에서 서로 의존

### 5. `--no-verify-access` 플래그

**효과:**

- Lerna의 사전 권한 체크만 건너뜀
- NPM Registry의 실제 권한 체크는 유지
- 보안상 문제 없음

**사용 사례:**

- Granular Token 사용 시
- CI/CD 환경에서 Automation Token 사용 시

---

## 참고 자료

### GitHub Issues

- [Lerna #2788 - Doesn't work with NPM automation tokens](https://github.com/lerna/lerna/issues/2788)

### NPM Documentation

- [NPM Tokens](https://docs.npmjs.com/about-access-tokens)
- [Granular Access Tokens](https://docs.npmjs.com/creating-and-viewing-access-tokens)
- [Token Migration](https://github.blog/changelog/2024-11-19-npm-is-deprecating-support-for-legacy-token-formats/)

### GCP Documentation

- [Cloud KMS](https://cloud.google.com/kms/docs)
- [Encrypting and Decrypting Data](https://cloud.google.com/kms/docs/encrypt-decrypt)
