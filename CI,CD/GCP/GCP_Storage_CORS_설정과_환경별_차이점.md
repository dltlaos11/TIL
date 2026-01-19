# GCP Storage CORS 설정과 환경별 차이점

## 문제 상황

- Local 개발환경에서 `piip-intra-staging` 버킷에 axios 요청 시 CORS 에러 발생
- Development 환경으로 바꾸면 정상 동작

## 원인 분석

### CORS 에러의 실제 위치

```console
Access to XMLHttpRequest at 'https://storage.googleapis.com/piip-intra-content-staging/...'
from origin 'http://localhost:3000' has been blocked by CORS policy
```

- **백엔드 API 서버가 아닌 GCP Storage 버킷 자체의 CORS 정책** 문제
- Signed URL을 통해 직접 GCS에 업로드할 때 발생
- 버킷별로 독립적인 CORS 설정을 가짐

## 환경별 CORS 설정 확인

### Development 버킷 (정상 동작)

```json
[
  {
    "maxAgeSeconds": 3600,
    "method": ["GET", "PUT", "HEAD"],
    "origin": ["http://localhost:3000"], // ✅ localhost 허용
    "responseHeader": ["Content-Type", "x-goog-acl"]
  }
]
```

### Staging 버킷 (CORS 에러)

```json
[
  {
    "maxAgeSeconds": 3600,
    "method": ["GET", "PUT", "HEAD"],
    "origin": [
      "https://staging-front.piip.co.kr",
      "https://staging-admin.piip.co.kr",
      "https://staging-ipms.piip.co.kr"
    ], // ❌ localhost 미포함
    "responseHeader": ["Content-Type", "x-goog-acl"]
  }
]
```

## Signed URL의 당위성

### 1. 보안상의 이유

```javascript
// ❌ 나쁜 방법: 서버를 통한 업로드
Frontend → Backend → Cloud Storage
// - 서버 리소스 낭비
// - 파일이 서버 메모리/디스크를 거쳐감
// - 서버 대역폭 2배 사용 (클라이언트→서버, 서버→스토리지)
```

```javascript
// ✅ 좋은 방법: Signed URL 직접 업로드
Frontend → Cloud Storage (Signed URL)
// - 서버 부하 최소화
// - 네트워크 효율성 극대화
// - 임시 권한으로 보안 유지
```

### 2. 성능상의 이점

```javascript
// 대용량 파일 업로드 시나리오
const largeFile = new File(/* 100MB 파일 */);

// 서버 경유: 100MB × 2 = 200MB 네트워크 사용
// 직접 업로드: 100MB × 1 = 100MB 네트워크 사용
```

### 3. 확장성 측면

```javascript
// 서버 경유 시 병목점
1000명 동시 업로드 → 서버 CPU/메모리/대역폭 폭증

// Signed URL 시 분산 처리
1000명 동시 업로드 → Cloud Storage가 직접 처리
```

## AWS S3 vs GCP Storage 차이점

### 1. Signed URL 생성 방식

#### AWS S3

```javascript
// AWS SDK v3
import { getSignedUrl } from "@aws-sdk/s3-request-presigner";
import { PutObjectCommand } from "@aws-sdk/client-s3";

const signedUrl = await getSignedUrl(
  s3Client,
  new PutObjectCommand({
    Bucket: "my-bucket",
    Key: "file.jpg",
    ContentType: "image/jpeg",
  }),
  { expiresIn: 3600 }
);

// 결과 URL 형태
// https://my-bucket.s3.amazonaws.com/file.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&...
```

#### GCP Storage

```javascript
// GCP SDK
import { Storage } from "@google-cloud/storage";

const [signedUrl] = await storage
  .bucket("my-bucket")
  .file("file.jpg")
  .getSignedUrl({
    version: "v4",
    action: "write",
    expires: Date.now() + 15 * 60 * 1000, // 15 minutes
    contentType: "image/jpeg",
  });

// 결과 URL 형태
// https://storage.googleapis.com/my-bucket/file.jpg?X-Goog-Algorithm=GOOG4-RSA-SHA256&...
```

### 2. CORS 설정 방식

#### AWS S3

```json
// S3 Console 또는 AWS CLI
{
  "CORSRules": [
    {
      "AllowedOrigins": ["http://localhost:3000"],
      "AllowedMethods": ["GET", "PUT", "POST"],
      "AllowedHeaders": ["*"],
      "MaxAgeSeconds": 3600
    }
  ]
}
```

```bash
# AWS CLI
aws s3api put-bucket-cors --bucket my-bucket --cors-configuration file://cors.json
```

#### GCP Storage

```json
// gsutil
[
  {
    "maxAgeSeconds": 3600,
    "method": ["GET", "PUT", "HEAD"],
    "origin": ["http://localhost:3000"],
    "responseHeader": ["Content-Type", "x-goog-acl"]
  }
]
```

```bash
# gsutil CLI
gsutil cors set cors.json gs://my-bucket
```

### 3. 자동화된 서비스 차이점

#### AWS S3 - 수동 설정이 많음

```javascript
// 멀티파트 업로드 직접 관리
const upload = new AWS.S3.ManagedUpload({
  params: {
    Bucket: "my-bucket",
    Key: "large-file.zip",
    Body: fileStream,
  },
  partSize: 10 * 1024 * 1024, // 수동 설정
  queueSize: 4, // 수동 설정
});

// CDN 연동도 별도 CloudFront 설정 필요
// 압축도 별도 Lambda@Edge 설정 필요
```

#### GCP Storage - 자동화된 최적화

```javascript
// 자동 resumable upload (5MB 이상 시)
const stream = bucket.file("large-file.zip").createWriteStream({
  resumable: true, // 자동 청크 크기 최적화
  metadata: {
    contentType: "application/zip",
  },
});

// 자동 압축 (gzip)
const stream = bucket.file("data.json").createWriteStream({
  gzip: true, // 자동 압축 + Content-Encoding 헤더 설정
});

// 자동 CDN (Cloud CDN 연동 시 캐시 헤더 자동 설정)
```

## GCP IAM vs 객체별 ACL 심화

### 1. IAM (Identity and Access Management) - 프로젝트/버킷 레벨

#### 역할 기반 권한

```javascript
// 프로젝트 레벨 IAM 역할
const roles = {
  'roles/storage.admin': '모든 스토리지 관리',
  'roles/storage.objectAdmin': '객체 생성/삭제/읽기',
  'roles/storage.objectCreator': '객체 생성만',
  'roles/storage.objectViewer': '객체 읽기만',
  'roles/storage.legacyBucketReader': '버킷 메타데이터 읽기',
  'roles/storage.legacyBucketWriter': '버킷 메타데이터 쓰기'
}

// Terraform으로 IAM 설정
resource "google_project_iam_member" "storage_admin" {
  project = "piip-intra"
  role    = "roles/storage.objectAdmin"
  member  = "serviceAccount:piip-intra-content@piip-intra.iam.gserviceaccount.com"
}
```

#### 조건부 IAM (Conditional IAM)

```javascript
// 특정 조건에서만 권한 부여
resource "google_project_iam_member" "conditional_access" {
  project = "piip-intra"
  role    = "roles/storage.objectAdmin"
  member  = "user:developer@company.com"

  condition {
    title       = "Time-based access"
    description = "Only during business hours"
    expression  = "request.time.getHours() >= 9 && request.time.getHours() < 18"
  }
}
```

### 2. 객체별 ACL (Access Control List) - 파일 레벨

#### Predefined ACL

```javascript
// 업로드 시 미리 정의된 ACL 적용
const [file] = await bucket.upload(filePath, {
  // 공개 읽기 가능
  predefinedAcl: "publicRead",

  // 기타 옵션들
  // 'authenticatedRead': 인증된 사용자만 읽기
  // 'bucketOwnerFullControl': 버킷 소유자 전체 제어
  // 'bucketOwnerRead': 버킷 소유자 읽기
  // 'private': 비공개 (기본값)
  // 'projectPrivate': 프로젝트 멤버만
  // 'publicReadWrite': 공개 읽기/쓰기
});
```

#### 커스텀 ACL

```javascript
// 세밀한 권한 제어
await file.acl.add({
  entity: "user-specific-email@gmail.com",
  role: "READER",
});

await file.acl.add({
  entity: "group-marketing@company.com",
  role: "WRITER",
});

await file.acl.add({
  entity: "domain-company.com",
  role: "READER",
});

// ACL 확인
const [acl] = await file.acl.get();
console.log("Current ACL:", acl);
```

### 3. IAM vs ACL 사용 시나리오

#### IAM 사용하는 경우

```javascript
// ✅ 대부분의 일반적인 경우
// - 서비스 어카운트 권한 관리
// - 개발자 권한 관리
// - 애플리케이션 레벨 권한 제어

// 예: 백엔드 서비스에서 사용
const storage = new Storage({
  keyFilename: "service-account-key.json", // IAM 기반 인증
  projectId: "piip-intra",
});
```

#### ACL 사용하는 경우

```javascript
// ✅ 파일별로 다른 권한이 필요한 경우
// - 사용자별 개인 파일
// - 부서별 공유 파일
// - 외부 파트너와 특정 파일만 공유

// 예: 사용자별 프로필 이미지
await bucket.file(`profiles/${userId}/avatar.jpg`).save(imageBuffer, {
  predefinedAcl: "publicRead", // 이 파일만 공개
});

await bucket.file(`documents/${userId}/private.pdf`).save(docBuffer, {
  predefinedAcl: "private", // 이 파일은 비공개
});
```

### 4. 하이브리드 접근법 (권장)

```javascript
// IAM으로 기본 권한 설정 + ACL으로 세밀한 제어
class FileUploadService {
  constructor() {
    // IAM으로 서비스 계정 권한 설정됨
    this.storage = new Storage({ projectId: "piip-intra" });
    this.bucket = this.storage.bucket("piip-intra-content-staging");
  }

  async uploadProfileImage(userId, imageBuffer) {
    const file = this.bucket.file(`profiles/${userId}/avatar.jpg`);

    await file.save(imageBuffer, {
      predefinedAcl: "publicRead", // ACL로 공개 설정
      metadata: {
        cacheControl: "public, max-age=31536000",
        contentType: "image/jpeg",
      },
    });
  }

  async uploadPrivateDocument(userId, docBuffer) {
    const file = this.bucket.file(`documents/${userId}/private.pdf`);

    await file.save(docBuffer, {
      predefinedAcl: "private", // ACL로 비공개 설정
    });

    // 특정 사용자에게만 권한 부여
    await file.acl.add({
      entity: `user-${userId}@company.com`,
      role: "READER",
    });
  }
}
```

## 핵심 학습 포인트

### 1. GCP의 자동화 우위

- **자동 최적화**: 청크 크기, 압축, 재시도 로직
- **통합 서비스**: IAM + ACL + CDN + 압축이 모두 연동
- **관리 편의성**: 설정할 게 적고 기본값이 합리적

### 2. 권한 관리 계층구조

```
Project Level (IAM)
└── Bucket Level (IAM + Bucket Policy)
    └── Object Level (ACL)
        └── Signed URL (임시 권한)
```

### 3. 실용적 권한 설계

- **99%는 IAM으로 해결**: 서비스 계정, 개발자 권한
- **1%만 ACL 사용**: 사용자별 파일, 외부 공유
- **Signed URL**: 임시 업로드/다운로드 권한

### 4. 보안 베스트 프랙티스

```javascript
// ✅ 좋은 패턴
// 1. 최소 권한 원칙
serviceAccount: "storage.objectCreator"; // Admin 아님

// 2. 조건부 권한
condition: "request.time.getHours() >= 9";

// 3. 객체별 세밀한 제어
predefinedAcl: "private"; // 기본은 비공개

// 4. 임시 권한 활용
expires: Date.now() + 15 * 60 * 1000; // 15분만
```

## 베스트 프랙티스

### 공통

1. **Production 환경의 CORS는 최소한으로 설정**
2. **Development 환경에서만 localhost 허용**
3. **환경별 버킷 분리로 보안 정책 격리**
4. **Signed URL 만료 시간 최소화** (15분 이내 권장)

### 권한 관리

5. **IAM 우선, ACL은 예외적으로**
6. **최소 권한 원칙 준수**
7. **조건부 IAM으로 시간/IP 제한**
8. **정기적인 권한 감사**

### AWS vs GCP 선택 기준

- **AWS S3**: 더 세밀한 제어가 필요한 엔터프라이즈
- **GCP Storage**: 빠른 개발과 자동 최적화가 중요한 스타트업

## 추가 고려사항

- Terraform/IaC로 권한 설정 코드화
- **Cloud Audit Logs**로 접근 로그 모니터링
- **VPC Service Controls**로 네트워크 레벨 보안 강화
- **Customer-Managed Encryption Keys (CMEK)**로 암호화 키 직접 관리
