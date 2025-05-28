# redirectURL 쿼리 파라미터 인코딩과 HOC 패턴

## 문제 상황

로그인 페이지로 리다이렉트할 때 원본 URL을 쿼리 파라미터로 전달하는 과정에서 발생하는 문제:

```javascript
// 잘못된 예시
/signin?redirecturl=/automation/emails?status=COMPLETION&subject=주식회사
```

위 URL에서 브라우저는:

- `redirecturl` 값을 `/automation/emails?status=COMPLETION`까지만 인식
- `&subject=주식회사`를 signin의 별도 쿼리 파라미터로 처리
- 결과적으로 로그인 후 원래 페이지로 제대로 돌아가지 않음

## 원인과 해결책

### 원인

쿼리스트링이 포함된 값을 쿼리 파라미터로 전달할 때 URL 인코딩 누락

### 해결책

`encodeURIComponent`와 `decodeURIComponent` 사용

```javascript
// 올바른 예시
/signin?redirecturl=%2Fautomation%2Femails%3Fstatus%3DCOMPLETION%26subject%3D%EC%A3%BC%EC%8B%9D%ED%9A%8C%EC%82%AC
```

## 구현 방법

### 1. SSR에서의 처리 (helpers.js)

```javascript
export const redirectIfNotAuthenticated = async (ctx, path = "/login") => {
  const authenticated = await isAuthenticated(DEFAULT_SESSION_COOKIE_NAME, ctx);
  if (!authenticated) {
    let redirectUrl = path;
    if (ctx && ctx.asPath && path === "/signin") {
      if (!ctx.asPath || ctx.asPath === "/" || ctx.asPath === "/signin") {
        redirectUrl = "/signin";
      } else {
        // 핵심: encodeURIComponent로 인코딩
        redirectUrl = `/signin?redirecturl=${encodeURIComponent(ctx.asPath)}`;
      }
    }
    redirect(redirectUrl, ctx);
    return true;
  }
  return false;
};
```

### 2. CSR에서의 처리 (initApollo.js)

```javascript
if (process.browser) {
  const { pathname, search } = window.location;
  if (pathname !== "/signin") {
    // pathname + search를 함께 인코딩
    const redirecturl = encodeURIComponent(pathname + search);
    window.location.href = `/signin?redirecturl=${redirecturl}`;
  } else {
    window.location.href = "/signin";
  }
}
```

### 3. 로그인 후 복원 (SignInAdminViewModel.js)

```javascript
let redirecturl =
  typeof window !== "undefined"
    ? new URLSearchParams(window.location.search).get("redirecturl")
    : null;

if (redirecturl) {
  // decodeURIComponent로 디코딩
  redirecturl = decodeURIComponent(redirecturl);
  const [pathname, search = ""] = redirecturl.split("?");
  const query = {};

  // 쿼리 파라미터 파싱
  if (search) {
    search.split("&").forEach((kv) => {
      const [k, v] = kv.split("=");
      query[decodeURIComponent(k)] = decodeURIComponent(v);
    });
  }

  return { pathname, query };
} else {
  return { pathname: "/" };
}
```

## HOC 패턴을 통한 인증/데이터 관리

### HOC 구조

```javascript
const withAdminModules = (Component, options = { auth: true }) =>
  withAuth(withApolloContext(Component), options);
```

실행 순서:

1. `withApolloContext`: Apollo Client 인스턴스를 props로 주입
2. `withAuth`: 인증 체크 및 리다이렉트 처리

### withApolloContext의 역할

```javascript
const withApolloContext = (Component) =>
  class extends React.Component {
    static async getInitialProps(ctx) {
      const pageProps = Component.getInitialProps
        ? await Component.getInitialProps(ctx)
        : {};
      return { ...pageProps };
    }

    render() {
      return (
        <ApolloConsumer>
          {(apolloClient) => (
            <Component {...this.props} apolloClient={apolloClient} />
          )}
        </ApolloConsumer>
      );
    }
  };
```

- React Context Pattern 활용
- `ApolloConsumer`를 통해 Apollo Client 인스턴스를 props로 전달
- `getInitialProps` 위임으로 SSR/CSR 데이터 프리패칭 지원

### 전체 아키텍처

```
ApolloProvider (최상위)
    ↓ Context 제공
withAdminModules
    ↓
withAuth (인증 체크)
    ↓
withApolloContext (Apollo Client 주입)
    ↓
Component (apolloClient, auth props 사용 가능)
```

## 핵심 원칙

1. **URL 파라미터 인코딩**: 쿼리스트링을 포함한 값은 반드시 `encodeURIComponent` 사용
2. **디코딩 복원**: 사용 시 `decodeURIComponent`로 원본 복원
3. **HOC 패턴**: 중복되는 로직(인증, 데이터 관리)을 재사용 가능한 고차 컴포넌트로 추상화
4. **Context 활용**: 전역 상태(Apollo Client)를 효율적으로 관리하고 주입

## 학습 포인트

- URL 인코딩의 중요성과 브라우저 URL 파싱 메커니즘 이해
- HOC 패턴을 통한 횡단 관심사(Cross-cutting Concerns) 분리
- React Context와 HOC의 조합으로 깔끔한 의존성 주입 구현
