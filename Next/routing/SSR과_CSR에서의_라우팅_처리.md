# SSR과 CSR에서의 라우팅 처리

## 🤔 왜 SSR과 CSR 둘 다 라우팅 처리가 필요한가?

### 핵심 이유

**사용자가 앱에 진입하는 방식이 다르기 때문**

- **SSR**: 서버에서 첫 페이지 로드 시 처리
- **CSR**: 클라이언트에서 SPA 네비게이션 시 처리

---

## 🖥️ SSR 라우팅

### 언제 필요한가?

- 브라우저 주소창에 직접 URL 입력
- 페이지 새로고침 (F5)
- 외부 링크에서 진입
- 검색엔진 크롤러 접근
- 북마크로 접근

### 동작 방식

서버에서는 브라우저의 히스토리 API를 사용할 수 없음
→ **HTTP 응답 헤더와 상태코드**를 이용해 브라우저에게 리다이렉트 명령

```javascript
// Next.js에서 SSR 리다이렉트
export async function getServerSideProps({ req, res }) {
  const sessionId = getCookie("session_id", req);

  if (!sessionId) {
    return {
      redirect: {
        destination: `/signin?redirecturl=${encodeURIComponent(req.url)}`,
        permanent: false,
      },
    };
  }

  return { props: {} };
}
```

```javascript
// 저수준 HTTP 리다이렉트
ctx.res.writeHead(303, { Location: "/signin" });
ctx.res.end();
```

---

## 🎨 CSR 라우팅

### 언제 필요한가?

- `router.push()` 또는 `<Link>` 사용한 페이지 이동
- 동적인 조건부 라우팅
- 사용자 액션 후 리다이렉트
- 실시간 인증 상태 변화 대응

### 동작 방식

**SPA 라우터**를 사용해 페이지 전체 새로고침 없이 빠른 라우팅

```javascript
// CSR에서 인증 체크 후 라우팅
const handleNavigation = async () => {
  const isAuth = await checkAuthAndRedirect(router);
  if (isAuth) {
    router.push("/dashboard/profile");
  }
};
```

---

## 🔄 실제 시나리오

### 시나리오 1: 직접 URL 접근

```
사용자 행동: https://myapp.com/dashboard 직접 입력
```

1. **SSR 단계** (서버에서 실행)

   - 인증 체크
   - 미인증 시 로그인 페이지로 리다이렉트

2. **CSR 단계** (클라이언트에서 실행)
   - 이미 인증된 상태로 페이지 렌더링

### 시나리오 2: SPA 내부 네비게이션

```
사용자가 이미 로그인된 상태에서 다른 페이지로 이동
```

1. **CSR에서만 처리**
   - 클라이언트에서 인증 체크
   - 인증 통과 시 페이지 이동 (SSR 없음)

---

## ❌ 한쪽만 구현했을 때의 문제점

### SSR만 있는 경우

```javascript
// 토큰이 만료되었는데 모르고 이동
router.push("/dashboard"); // 페이지는 로드되지만 API 호출 시 401 에러
```

**결과**: 사용자가 페이지는 보지만 데이터 로딩 실패

### CSR만 있는 경우

```javascript
// 직접 URL 접근 시
function Dashboard() {
  useEffect(() => {
    // 페이지가 이미 렌더링된 후에 체크
    checkAuthAndRedirect(router);
  }, []);

  return <div>Dashboard Content</div>; // 인증되지 않은 사용자도 잠깐 볼 수 있음
}
```

**결과**:

- 보안 취약점 (잠깐이라도 보호된 콘텐츠 노출)
- 깜빡임 현상 (페이지 로드 → 리다이렉트)
- SEO 문제

---

## 🔧 최적화된 통합 패턴

### 공통 로직 추출

```javascript
// utils/auth.js
export const checkAuthAndRedirect = async (context) => {
  const isServer = typeof window === "undefined";
  const sessionId = isServer
    ? getCookie("session_id", context.req)
    : getCookie("session_id");

  if (!sessionId) {
    const currentPath = isServer ? context.req.url : context.asPath;
    const redirectUrl = `/signin?redirecturl=${encodeURIComponent(
      currentPath
    )}`;

    if (isServer) {
      // SSR: redirect 객체 반환
      return {
        redirect: {
          destination: redirectUrl,
          permanent: false,
        },
      };
    } else {
      // CSR: 직접 라우팅
      context.push(redirectUrl);
      return false;
    }
  }

  return true;
};
```

### HOC로 중복 제거

```javascript
// components/withAuth.js
export const withAuth = (WrappedComponent) => {
  const AuthComponent = (props) => {
    const router = useRouter();
    const [isChecking, setIsChecking] = useState(true);

    useEffect(() => {
      checkAuthAndRedirect(router).then((isAuth) => {
        setIsChecking(false);
      });
    }, [router]);

    if (isChecking) return <Loading />;
    return <WrappedComponent {...props} />;
  };

  // SSR 체크도 포함
  AuthComponent.getServerSideProps = async (context) => {
    const authResult = await checkAuthAndRedirect(context);
    if (authResult.redirect) return authResult;

    if (WrappedComponent.getServerSideProps) {
      return await WrappedComponent.getServerSideProps(context);
    }

    return { props: {} };
  };

  return AuthComponent;
};
```

---

## 📍 Next.js Router 속성들

### router.pathname vs router.asPath

- **pathname**: 페이지의 파일 경로 (`/about`)
- **asPath**: 브라우저 주소창의 전체 경로 (`/about?name=John#section1`)

### router.push URL 객체 속성들

```javascript
router.push({
  pathname: "/post/[id]", // 이동할 경로
  query: { id: "123" }, // 쿼리 파라미터
  hash: "#comments", // 해시 프래그먼트
  locale: "en", // 로케일
});
```

---

## 🎯 결론

**양쪽 모두 필요한 이유:**

1. **SSR**: 첫 진입점 보안 + SEO + 사용자 경험
2. **CSR**: 앱 내부 네비게이션 + 실시간 상태 변화 대응
3. **조합**: 완벽한 보안 + 매끄러운 UX + 성능 최적화

**핵심**: 실행 환경이 다르기 때문에 라우팅 방식도 다르게 처리해야 함

- **SSR**: HTTP 응답으로 브라우저에게 "이동하라" 명령
- **CSR**: JavaScript 라우터로 직접 이동

---

## 📚 추가 학습 포인트

- **UX 개선을 위한 redirect URL 패턴**
- **쿠키 vs 세션 스토리지 활용법**
- **보안 고려사항 (Open Redirect 방지)**
- **Next.js Middleware 활용**
