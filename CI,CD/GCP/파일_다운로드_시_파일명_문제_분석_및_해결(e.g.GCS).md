# 파일 다운로드 시 파일명 문제 분석 및 해결(e.g.GCS)

## 문제

파일명을 DB에서 수정한 후 다운로드 시 수정된 파일명이 아닌 **원본 파일명**이 나오는 문제.

- 시크릿 모드(캐시 없음): 수정된 파일명으로 다운로드됨
- 일반 모드: 원본 파일명으로 다운로드됨

---

## 원인 분석

### 브라우저의 다운로드 파일명 결정 순서

`<a href="..." download>` 사용 시 브라우저는 아래 순서로 파일명을 결정한다.

1. `Content-Disposition` 응답 헤더의 `filename` 값
2. URL 경로의 마지막 segment (GCS 원본 파일명)

### 문제의 핵심: 브라우저 HTTP 캐시

GCS는 파일 응답에 `Cache-Control: public, max-age=3600` 헤더를 포함한다.
브라우저는 동일 URL에 대한 응답(Content-Disposition 포함)을 **최대 1시간** 캐시한다.

파일명 수정 흐름:

1. 파일 최초 다운로드 → GCS 응답(Content-Disposition: 원본파일명) → 브라우저 캐시 저장
2. DB에서 파일명 수정 → 백엔드가 GCS 객체 메타데이터(Content-Disposition)도 함께 업데이트
3. 다시 다운로드 → **동일 URL** → 브라우저가 캐시에서 꺼냄 → 여전히 원본 파일명

시크릿 모드에서는 캐시가 없으므로 GCS에 새로 요청 → 수정된 Content-Disposition 수신 → 수정된 파일명으로 다운로드됨.

### Content-Disposition이란

HTTP 응답 헤더로, 브라우저에게 파일 처리 방식과 저장 파일명을 지정한다.

```
Content-Disposition: attachment; filename*=UTF-8''%ED%8C%8C%EC%9D%BC%EB%AA%85.pdf
```

- `attachment`: 다운로드로 처리
- `filename*=UTF-8''...`: RFC 5987 인코딩으로 한글 파일명 지원

GCS는 파일 업로드 시 객체 메타데이터로 Content-Disposition을 저장하며, 이후 다운로드 요청마다 해당 값을 응답 헤더로 반환한다.

---

## 파일 업로드 구조

```
1. 프론트 → 백엔드: createAttachmentWithSignedUrl 뮤테이션 (파일명, contentType, size 전달)
2. 백엔드 → GCS: signed upload URL 생성 + DB에 attachment 레코드 저장
3. 백엔드 → 프론트: { attachment, signedUrl } 반환
4. 프론트 → GCS: signed URL로 직접 파일 PUT 업로드
5. 프론트 → 백엔드: attachment ID 전달 (addAttachments)
```

실제 파일은 백엔드를 거치지 않고 프론트에서 GCS로 직접 업로드된다.
백엔드는 signed URL 발급 및 DB 레코드 관리만 담당한다.

### Content-Disposition 설정 주체

백엔드에서 signed URL 생성 시 GCS 객체 메타데이터에 Content-Disposition을 포함시킨다.
프론트 업로드 헤더에 별도로 추가할 필요 없다. (추가 시 signed URL 서명 검증 실패 가능)

---

## 해결 방법: Cache-Busting

`AttachmentItem.js`의 다운로드 링크 href에 `?t=Date.now()` 파라미터를 추가한다.

URL이 매 렌더마다 달라지므로 브라우저가 캐시 미스로 판단하여 GCS에 새로 요청한다.
→ 수정된 Content-Disposition을 받아 올바른 파일명으로 다운로드된다.

### 변경 파일

`packages/piip-ui-components/src/v2/containers/infomations/AttachmentItem.js`

```javascript
// 변경 전: href 내부에 IIFE로 작성
<a
    href={(() => {
        const u = dataSourceProp?.signedUrl || dataSourceProp?.url
        if (!u) return u
        const sep = u.includes('?') ? '&' : '?'
        return `${u}${sep}t=${Date.now()}`
    })()}
    download>

// 변경 후: 별도 함수로 분리
const getDownloadHref = (dataSourceProp) => {
    const u = dataSourceProp?.signedUrl || dataSourceProp?.url
    if (!u) return u
    const sep = u.includes('?') ? '&' : '?'
    return `${u}${sep}t=${Date.now()}`
}

<a href={getDownloadHref(dataSourceProp)} download>
```

---

## 참고: GCS Signed URL과 추가 파라미터

GCS signed URL은 서명 대상에 포함되지 않은 추가 쿼리 파라미터(`t=...`)는 무시된다.
따라서 cache-busting 파라미터를 붙여도 서명 검증에 영향 없이 정상 동작한다.

---

## 프론트엔드 캐싱 여부 확인 결과

| 항목                          | 존재 여부                                |
| ----------------------------- | ---------------------------------------- |
| localStorage / sessionStorage | 없음                                     |
| Service Worker                | 없음                                     |
| Apollo 캐시 (attachment 쿼리) | 기본 `network-only` 정책으로 캐시 안 함  |
| 브라우저 HTTP 캐시            | **있음 (GCS Cache-Control 헤더에 의해)** |

브라우저 HTTP 캐시가 유일한 캐싱 요소이며, cache-busting으로 해결된다.
