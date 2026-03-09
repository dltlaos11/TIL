# Next.js SSR/CSR 실행 컨텍스트 & 라우팅 정리

## 1. React Hook 실행 컨텍스트

```
컴포넌트 함수 실행 (SSR + CSR 모두)
├── useState(initializer)     ← SSR: 초기값 계산
├── useMemo(fn, deps)         ← SSR: 메모이제이션 계산
├── useContext()              ← SSR: 컨텍스트 읽기
├── useEffect(callback, deps)
│   ├── deps 배열 평가        ← SSR: 컴포넌트 함수의 일부이므로 평가됨
│   └── callback 실행         ← CSR only (Hydration 이후)
└── return JSX                ← SSR: HTML 문자열로 변환
```

---

## 2. Router 싱글톤 에러 원인

```js
import Router from "next/router"; // 클라이언트에서만 초기화되는 싱글톤

useEffect(() => {
  setTabActiveKey(Router.query?.tab || "BUSINESS_CONNECTION");
}, [Router.query?.tab]);
//  ^^^^^^^^^^^^^^^^
//  deps 배열 → SSR 시 컴포넌트 함수와 함께 평가
//  Router는 아직 미초기화 상태 → "No router instance found" 에러
```

- `useEffect` **콜백**은 CSR에서만 실행되므로 안전
- 하지만 **deps 배열**은 컴포넌트 함수 본문의 일부 → SSR 시 평가됨
- `Router` 싱글톤은 Node.js 환경에서 미초기화 → 접근 시 에러

---

## 3. useRouter()가 안전한 이유

```js
const router = useRouter(); // Next.js가 SSR 컨텍스트에서도 안전한 객체 제공

useEffect(() => {
  setTabActiveKey(router.query?.tab || "BUSINESS_CONNECTION");
}, [router.query?.tab]);
//  ^^^^^^^^^^^^^^^^
//  SSR 시 router.query = {} → undefined → 'BUSINESS_CONNECTION' (안전)
```

|          | `Router` 싱글톤       | `useRouter()` hook             |
| -------- | --------------------- | ------------------------------ |
| SSR 접근 | 에러                  | 빈 객체 `{}` 반환              |
| 반응성   | 없음 (같은 객체 참조) | 라우트 변경 시 리렌더링 트리거 |
| 용도     | 컴포넌트 외부         | 컴포넌트 내부                  |

---

## 4. 최종 해결: URL = Source of Truth

```js
const router = useRouter();
const tabActiveKey = router.query?.tab || "BUSINESS_CONNECTION";
// useState + useEffect 완전 제거
// URL이 바뀌면 router.query가 바뀌고 → 리렌더링 → tabActiveKey 자동 반영
```

---

## 5. router.push 두 인자의 역할

```js
router.push(
  { pathname: router.pathname, query: { id, tab: key } },
  // ↑ 첫 번째 인자: Next.js 내부용
  //   - pathname: pages/ 기준 파일 경로 (현재 '/customers/business-connections/show')
  //   - query: getInitialProps({ query })에 전달될 객체
  //   - Next.js가 어느 파일을 렌더링할지 결정하는 데 사용

  `/customers/business-connections/${id}?tab=${key}`,
  // ↑ 두 번째 인자 (as): 실제 URL
  //   - 브라우저 주소창에 표시되는 URL
  //   - 새로고침/직접 입력 시 server.js 라우트 패턴과 매칭되어야 함
  //   - 이 둘이 불일치하면 새로고침 시 404 발생

  { shallow: true },
  // ↑ getInitialProps 재호출 없이 URL만 변경 (탭 전환 시 데이터 재요청 방지)
);
```

---

## 6. server.js Custom Server 패턴

```js
// Next.js 파일 기반 라우팅의 한계:
// pages/show.js 파일은 URL /customers/business-connections/show 에만 매핑됨
// /customers/business-connections/123 → 자동 매핑 불가

// Custom Server로 해결:
server.get("/customers/business-connections/:id", (req, res) => {
  const query = { ...req.query, id: req.params.id };
  //             ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  //             req.query: URL의 쿼리스트링 (?tab=INVOICE 등)
  //             req.params.id: /:id 패턴에서 추출한 값
  //             → 합쳐서 getInitialProps에 전달

  app.render(req, res, "/customers/business-connections/show", query);
  //                    ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  //                    pages/ 기준 파일 경로 (실제 파일 위치)
  //                    [id].js 없이 show.js가 동적 라우팅 역할 수행
});
```

**새로고침 시 전체 흐름**:

```
브라우저: /customers/business-connections/123?tab=INVOICE
    ↓
server.js: /:id 패턴 매칭 → query = { id: '123', tab: 'INVOICE' }
    ↓
app.render → show.js SSR 실행
    ↓
getInitialProps({ query: { id: '123', tab: 'INVOICE' } })
    ↓
useRouter()가 동일한 query 포함한 router 객체 제공
    ↓
tabActiveKey = router.query?.tab → 'INVOICE'
```

**Express는 필수가 아니었음**: Node.js 기본 `http` 모듈로도 구현 가능.

```js
const { createServer } = require("http");

createServer((req, res) => {
  if (req.url.startsWith("/post/")) {
    const id = req.url.split("/")[2];
    return app.render(req, res, "/post", { id });
  }
  handle(req, res);
});
```

단, URL 파싱을 직접 해야 하므로 Express가 많이 쓰인 이유:

1. URL 패턴 처리 편함 (`/post/:id`)
2. 미들웨어 체계
3. 기존 Express 서버에 Next.js 붙이기 용이
4. SEO용 pretty URL 처리

**`[id].js` 파일 기반 동적 라우팅은 Next.js 9에서 이미 도입됨**: 현재 프로젝트가 Custom Server를 쓰는 이유는 버전 때문이 아니라, 기존 server.js 방식으로 구축된 레거시 구조를 유지하기 때문.
