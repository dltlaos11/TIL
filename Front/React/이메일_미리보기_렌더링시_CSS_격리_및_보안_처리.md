# 이메일 미리보기 렌더링시 CSS 격리 및 보안 처리

## 문제 상황

- React 컴포넌트에서 `dangerouslySetInnerHTML`을 사용한 이메일 미리보기 기능 구현
- 특정 이메일(Microsoft Word 생성) 미리보기 시 다른 DOM 요소에 밑줄(`text-decoration: underline`)이 의도치 않게 적용되는 문제 발생
- 이메일 콘텐츠의 CSS가 전역적으로 영향을 미치는 보안 및 UI 격리 이슈

## 학습한 내용

### 1. dangerouslySetInnerHTML의 동작 메커니즘

- React가 HTML 문자열을 브라우저의 `innerHTML` API로 직접 DOM에 삽입
- 포함된 `<style>` 태그는 전역적으로 적용됨 (스코핑 없음)
- CSS 우선순위 충돌로 인해 의도하지 않은 스타일 적용 가능

### 2. Microsoft Word 이메일의 특성

```html
<!-- Word에서 생성된 이메일의 문제적 CSS -->
<style>
  @font-face {
    font-family: 바탕;
  }
  a:link,
  span.MsoHyperlink {
    color: blue;
    text-decoration: underline;
  }
</style>
```

- 복잡한 폰트 정의와 전역 링크 스타일 포함
- `.MsoNormal`, `.WordSection1` 등 Word 특수 클래스 사용
- 전역 CSS 선택자로 인한 스타일 오염

### 3. 다층 보안 및 격리 전략

#### A. 문자열 레벨 정화 (1차 방어)

```javascript
const sanitizeEmailContent = (htmlContent) => {
  return htmlContent
    .replace(/<style[^>]*>[\s\S]*?<\/style>/gi, "") // 스타일 태그 제거
    .replace(/<script[^>]*>[\s\S]*?<\/script>/gi, "") // 스크립트 제거
    .replace(/\s*on\w+\s*=\s*["'][^"']*["']/gi, "") // 이벤트 핸들러 제거
    .replace(/class\s*=\s*["']Mso[^"']*["']/gi, ""); // Word 클래스 제거
};
```

#### B. CSS 스코핑 및 격리 (2차 방어)

```css
const safeCss = `
<style>
    /* 강력한 격리 */
    .email-preview-popover .email-preview-wrapper {
        all: initial !important;  /* 모든 스타일 리셋 */
    }

    /* 내부 스타일 무력화 */
    .email-preview-popover .email-preview-wrapper style {
        display: none !important;
    }

    /* 링크 완전 제어 */
    .email-preview-popover .email-preview-wrapper a,
    .email-preview-popover .email-preview-wrapper span.MsoHyperlink {
        pointer-events: none !important;
        color: #1890ff !important;
        text-decoration: underline !important;
    }
</style>
`
```

#### C. 구조적 분리

```javascript
const getEmailPreviewStyles = () => ({
  container: {
    // React 인라인 스타일 - 기본 디자인
    fontFamily: "...",
    fontSize: "13px",
    // ...
  },
  safeCss: `...`, // HTML 문자열 - CSS 스코핑 + 보안
});
```

## 핵심 배운 점

- **CSS 격리의 중요성**: 외부 콘텐츠 렌더링 시 스타일 격리가 필수
- **!important의 전략적 사용**: 보안 목적의 CSS에서는 우선순위 강제가 필요
- **다층 방어**: 문자열 정화 → CSS 스코핑 → 안전한 렌더링의 단계적 접근
- **React 스타일 한계**: 인라인 스타일로는 pseudo-class나 복잡한 선택자 처리 불가

## 성과

✅ 이메일 미리보기 시 외부 DOM 요소 스타일 오염 문제 해결  
✅ Microsoft Word 이메일의 복잡한 CSS 안전하게 격리  
✅ XSS 및 스타일 인젝션 공격 방어 체계 구축  
✅ 재사용 가능한 이메일 콘텐츠 정화 함수 개발

## 추가 고려사항

- CSP(Content Security Policy) 헤더 적용 검토
- 이메일 콘텐츠 크기 제한 및 성능 최적화
- 접근성(a11y) 고려한 미리보기 UI 개선
