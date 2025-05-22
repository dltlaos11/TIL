# Next.js 커스텀 서버에서 내장 서버로 마이그레이션

## 문제 상황

기존에 Express.js 기반의 커스텀 서버(server.js)를 사용하여 Next.js 애플리케이션을 운영하고 있었으나, Next.js 13의 내장 기능만으로도 충분히 대체 가능함을 알게 되었다.

## 마이그레이션 방법

### 1. 프록시(Proxy) 설정 변경

**기존 방식 (커스텀 서버)**

```javascript
server.use(
  "/signedUrlFromStorage",
  createProxyMiddleware({
    target: "https://xxxxxxxxxx.co.kr",
    changeOrigin: true,
    pathRewrite: {
      "^/signedUrlFromStorage": "/signedUrlFromStorage",
    },
  })
);
```

**Next.js 13 방식 (next.config.js)**

```javascript
module.exports = {
  async rewrites() {
    return [
      {
        source: "/signedUrlFromStorage/:path*",
        destination: "https://xxxxxxxxxx.co.kr/signedUrlFromStorage/:path*",
      },
    ];
  },
};
```

### 2. 정적 파일 서빙

- `/robots.txt` 등의 파일은 `public/` 디렉터리로 이동
- Next.js가 자동으로 정적 파일을 서빙
- 별도의 Express static 설정 불필요

### 3. 라우팅 및 페이지 렌더링

- 커스텀 서버에서 `app.render()`로 각 URL을 매핑하던 방식 제거
- Next.js 13의 파일 기반 라우팅 활용
- 예시: `/pages/cases/file-wrappers/index.js` → `/cases/file-wrappers` 자동 매핑

### 4. HTTPS 리다이렉트

- Next.js 자체에는 http→https 리다이렉트가 내장되어 있지 않음
- 배포 환경(Vercel, Nginx, CloudFront 등)에서 처리하거나
- `middleware.js`로 직접 구현 가능

### 5. SSR 캐싱

- LRUCache를 통한 SSR 캐싱은 Next.js 내장 기능으로 직접 지원되지 않음
- 대신 ISR(Incremental Static Regeneration), SSG, CDN 캐싱 등 활용
- 필요시 middleware 또는 edge function에서 일부 구현 가능

## NODE_ENV 환경변수 처리

### 자동 설정되는 환경변수

- `next dev` 실행 시 → `NODE_ENV=development` 자동 설정
- `next build` 실행 시 → `NODE_ENV=production` 자동 설정
- `next start` 실행 시 → `NODE_ENV=production` 자동 설정

### package.json 스크립트 예시

```json
{
  "scripts": {
    "dev": "next dev", // NODE_ENV=development 명시 불필요
    "build": "next build", // NODE_ENV=production 자동 설정
    "start": "next start" // NODE_ENV=production 자동 설정
  }
}
```

### 주의사항

- `APP_ENV`같은 커스텀 환경변수는 여전히 명시적으로 설정해야 함
- Next.js 표준 명령어 사용 시 `NODE_ENV` 중복 지정은 불필요

## 마이그레이션의 장점

1. **유지보수성 향상**: Next.js 표준 방식 사용으로 업그레이드 용이
2. **서버리스 배포 가능**: Vercel 등 서버리스 플랫폼 배포 지원
3. **성능 최적화**: Next.js 내장 최적화 기능 활용
4. **코드 간소화**: 커스텀 서버 코드 제거로 복잡도 감소

## 결론

커스텀 서버에서 하던 대부분의 작업(프록시, 정적 파일 서빙, 라우팅)은 Next.js 13의 내장 기능과 `next.config.js` 설정만으로 충분히 대체 가능하다. 특별한 요구사항(복잡한 SSR 캐싱, 세션 관리 등)이 없다면 커스텀 서버를 제거하고 Next.js 기본 서버를 사용하는 것이 권장된다.
