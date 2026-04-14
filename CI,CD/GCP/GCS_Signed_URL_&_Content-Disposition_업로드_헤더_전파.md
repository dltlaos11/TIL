# GCS Signed URL & Content-Disposition 업로드 헤더 전파

> 날짜: 2026-04-14
> 주제: GCS Signed URL V4, Content-Disposition 헤더, url vs signedUrl 구조 설계

---

## 배경

파일 업로드 시 CORS 에러가 발생했다. 원인을 추적하면서 GCS Signed URL의 동작 원리와 `Content-Disposition` 헤더의 역할, 그리고 코드 내 url/signedUrl 구조 설계를 이해하게 되었다.

---

## 1. GCS Signed URL V4 — 추가 파라미터 금지

GCS Signed URL V4는 서명(signature) 범위에 쿼리 파라미터까지 포함한다.

```
https://storage.googleapis.com/bucket/file?X-Goog-Signature=abc&X-Goog-Credential=...
```

- 서명 생성 시 사용된 URL과 **완전히 동일한 URL**로만 요청 가능
- `?t=Date.now()` 같은 캐시버스터 파라미터를 붙이면 서명 불일치 → `SignatureDoesNotMatch` 에러

**V2는 상대적으로 관대**하여 추가 파라미터에 덜 엄격하지만, V4는 엄격하게 검증한다.

---

## 2. Content-Disposition — 업로드 메타데이터로서의 역할

`Content-Disposition` 헤더를 GCS에 PUT 업로드 시 함께 보내면, GCS는 이를 파일 메타데이터로 저장한다.

```
Content-Disposition: attachment; filename*=UTF-8''%ED%95%9C%EA%B8%80%ED%8C%8C%EC%9D%BC.pdf
```

**효과**: 이후 다운로드 요청 시 GCS가 이 메타데이터를 `Content-Disposition` 응답 헤더로 내보내 브라우저가 올바른 파일명으로 저장한다.
**특히 한글/특수문자 파일명**을 올바르게 처리하는 데 중요하다.

### 주의: CORS preflight 문제

`axios.put(signedUrl, file, { headers: { 'Content-Disposition': ... } })`처럼 CORS simple request 허용 헤더(`Accept`, `Content-Type` 등)에 포함되지 않는 헤더를 사용한 요청은 브라우저가 실제 PUT 전에 **preflight(OPTIONS) 요청**을 먼저 보낸다.

GCS 버킷 CORS 설정의 `allowedHeader`에 `Content-Disposition`이 없으면 GCS가 preflight를 거절 → 브라우저가 실제 PUT을 아예 전송하지 않는다.

- 브라우저 콘솔에는 CORS 에러로 표시되고 DevTools에서 "Provisional headers are shown" 메시지가 뜬다
- 실제 PUT이 전송되지 않았으므로 서버 로그에는 아무것도 남지 않음

→ **해결**: GCS 버킷 CORS 설정에 `Content-Disposition`을 `allowedHeader`로 추가해야 한다 (인프라 작업).

---

## 3. url vs signedUrl — 코드 설계 의도 이해

```js
// AttachmentItem.js
const getDownloadHref = (dataSourceProp) => {
  if (dataSourceProp?.signedUrl) return dataSourceProp.signedUrl; // signedUrl 우선, 그대로 사용
  const u = dataSourceProp?.url;
  if (!u) return u;
  const sep = u.includes("?") ? "&" : "?";
  return `${u}${sep}t=${Date.now()}`; // 일반 url에만 캐시버스터 추가
};
```

| 속성        | 의미                            | t= 추가 가능?                            |
| ----------- | ------------------------------- | ---------------------------------------- |
| `signedUrl` | GCS 서명된 URL (만료 시간 포함) | **불가** — 서명 범위에 파라미터 포함됨   |
| `url`       | GCS public URL (서명 없음)      | **가능** — 서명이 없으므로 파라미터 무관 |

### 왜 두 가지가 공존하는가?

- **signedUrl 방식**: 파일 접근에 서명 검증이 필요한 경우 (비공개 버킷 등)
  - URL 자체에 만료 시간이 내장 → `t=` 불필요 (이미 캐시 무효화됨)
  - 파일명 수정 UI 제공 불가 (URL이 고정됨)

- **일반 url 방식**: public-read 버킷의 공개 URL
  - 영구 URL이므로 브라우저 캐시 방지를 위해 `t=Date.now()` 추가
  - `updateAttachmentFilename` 같은 파일명 수정 기능 제공 가능

### 설계 일관성

`receivedEmailAutomation` 같은 경우 파일명 수정 UI가 없다.
signedUrl을 사용하기 때문에 파일명 수정이 불가능한 설계 → 의도된 동작이다.

반대로 일반 url을 사용하는 경우에는 `updateAttachmentFilename` 호출이 가능하다.

---

## 4. HTTP 헤더 대소문자 — case-insensitive

HTTP 스펙(RFC 7230)상 헤더 이름은 대소문자를 구분하지 않는다.

```
content-disposition == Content-Disposition == CONTENT-DISPOSITION
```

GCS CORS 설정에서도 마찬가지로 대소문자 무관하게 매칭된다.

---

## 요약

1. GCS Signed URL V4에 쿼리 파라미터를 추가하면 서명 불일치 에러
2. `Content-Disposition` 업로드 시 GCS 메타데이터로 저장 → 다운로드 파일명 보장
3. GCS CORS 설정에 `Content-Disposition` allowedHeader 없으면 preflight 실패 → PUT 전송 안 됨
4. `signedUrl`은 그대로, `url`에만 캐시버스터(`t=`) 추가
