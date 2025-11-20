# 국제화(i18n)에서의 CSS 폰트 적용 방법 정리

## 1. 기본 개념: 폰트 우선순위

```css
font-family: "Noto Sans KR", "Noto Sans SC", sans-serif;
```

- **왼쪽부터 우선순위** 적용
- 브라우저가 **글자별로 자동 선택** (언어 감지 X, 글리프 지원 여부 O)
- `안녕하세요 你好` → 한글은 KR 폰트, 중국어는 SC 폰트 자동 적용

## 2. 폰트 파일 관리 방식

### A. CDN 방식 (개발/테스트용)

```css
@import url("https://fonts.googleapis.com/css2?family=Noto+Sans+KR&family=Noto+Sans+SC");
```

### B. 로컬 파일 방식 (Production 권장)

```
/static/
├── fonts/
│   ├── notosanskr/
│   │   ├── noto-sans-kr.woff2
│   │   └── noto-sans-kr.ttf
│   └── notosanssc/
│       ├── noto-sans-sc.woff2
│       └── noto-sans-sc.ttf
└── css/
    └── fonts.css
```

## 3. CSS 폰트 정의 (fonts.css)

```css
@font-face {
  font-family: "Noto Sans KR";
  src: url("../fonts/notosanskr/noto-sans-kr.woff2") format("woff2"), url("../fonts/notosanskr/noto-sans-kr.ttf")
      format("truetype");
  font-weight: 400;
  font-display: swap;
}

@font-face {
  font-family: "Noto Sans SC";
  src: url("../fonts/notosanssc/noto-sans-sc.woff2") format("woff2"), url("../fonts/notosanssc/noto-sans-sc.ttf")
      format("truetype");
  font-weight: 400;
  font-display: swap;
}
```

## 4. Next.js 적용 방법

### \_document.js

```javascript
<Head>
  <link rel="stylesheet" href="/static/css/fonts.css" />
</Head>
```

### 전역 CSS 적용

```css
body {
  font-family: "Noto Sans KR", "Noto Sans SC", sans-serif;
}
```

## 5. TinyMCE 에디터 설정

```javascript
const editorInitConfig = {
  content_style: `
    body { 
      font-family: 'Noto Sans KR', 'Noto Sans SC', sans-serif; 
    }
    h2, h3, h4 { 
      font-family: 'Noto Sans KR', 'Noto Sans SC', sans-serif; 
    }
  `,
  font_formats:
    "Noto Sans KR=noto sans kr;" +
    "Noto Sans SC=noto sans sc;" +
    "Arial=arial,helvetica,sans-serif;",
};
```

## 6. 폰트 포맷 이해

| 포맷      | 크기            | 브라우저 지원 | 용도        |
| --------- | --------------- | ------------- | ----------- |
| **WOFF2** | 작음 (50% 압축) | 최신 브라우저 | 성능 최적화 |
| **TTF**   | 큼 (원본)       | 모든 브라우저 | 호환성 보장 |

```css
/* 브라우저 선택 로직 */
src: url("font.woff2") format("woff2"), /* 1순위: 최신 브라우저 */
    url("font.ttf") format("truetype"); /* 2순위: 구형 브라우저 */
```

## 7. 폰트 로딩 상태 관리 (선택사항)

### FontFaceObserver 사용

```javascript
import FontFaceObserver from "fontfaceobserver";

const observer = new FontFaceObserver("Noto Sans KR");
observer.load().then(() => {
  console.log("폰트 로드 완료!");
  // UI 업데이트
});
```

### 네이티브 API 사용

```javascript
document.fonts.ready.then(() => {
  console.log("모든 폰트 로드 완료!");
});
```

## 8. 최종 권장 구조

```
프로젝트/
├── static/
│   ├── fonts/          # 폰트 파일들
│   └── css/
│       └── fonts.css   # @font-face 정의
├── pages/
│   └── _document.js    # 폰트 CSS 링크
└── components/
    └── Editor.js       # TinyMCE 설정
```

## 핵심 포인트

1. **Production에서는 로컬 폰트 파일 사용** (안정성)
2. **WOFF2 + TTF 조합으로 호환성 확보**
3. **font-family 순서로 언어별 자동 적용**
4. **@import 대신 <link> 사용** (성능)
5. **폰트 로딩 완료 후 UI 업데이트** (UX)
