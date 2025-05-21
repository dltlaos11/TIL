# MobX 4.x → 6.x 마이그레이션과 Next.js 9 → 13 업그레이드

## MobX 4.x → 6.x 마이그레이션

1. **MobX 6.x 데코레이터 변화**

   - MobX 6.x 이상에서는 `makeObservable`만으로 동작 가능
   - 데코레이터(`@observable` 등)를 사용하려면 Babel 플러그인 설정 필요

2. **자동 변환 도구: mobx-undecorate**

   - 모노레포 루트에서 실행: `npx mobx-undecorate "packages/**/*.js"`
   - 변환 내용:
     - 클래스 외부 `decorate(MyStore, {...})` → 생성자 내 `makeObservable(this, {...})`
     - 데코레이터(`@observable`, `@action` 등) 자동 변환
   - 변환 후 반드시 빌드/테스트로 정상 동작 확인 필요

3. **MobX makeObservable 사용 시 주의사항**

   ```javascript
   // 잘못된 예시
   constructor() {
     makeObservable(this, {
       searchInitValues: observable  // 아직 필드가 정의되지 않음!
     });
     this.searchInitValues = this.parseSearchInitValues();
   }

   // 올바른 예시
   constructor() {
     this.searchInitValues = this.parseSearchInitValues();
     makeObservable(this, {
       searchInitValues: observable  // 필드 초기화 후 호출
     });
   }
   ```

   - `makeObservable` 호출 시점에는 해당 필드가 인스턴스에 존재해야 함
   - 모든 인스턴스 필드 초기화 후 `makeObservable` 호출 필요

## 애플리케이션 구조 분석 (Next.js 9 → 13 업그레이드)

1. **Store 구조**

   - 현재 구조: 도메인별 store를 독립적으로 생성하여 `<Provider {...casesStore.getStores()}>`로 전달
   - 최상위 store(PiipIntranetWebappStore)는 정의만 있고 실제 사용되지 않음
   - root store에 모든 도메인 store를 등록/관리하는 구조가 아님

2. **Express + Next.js 구조**
   - 현재: Express 위에 Next.js를 올려서 직접 라우팅 및 `app.render`로 페이지 렌더링
   - **Express가 URL 매핑과 SSR을 위해 필요했던 구조** (Next.js 9 시절)
   - Next.js 9에서는 커스텀 서버가 일반적인 패턴이었으나, Next.js 13+ 에서는 권장되지 않음
   - Next.js 13+에서는 대부분의 기능이 내장되어 Express 커스텀 서버 없이도 대부분 가능
   - **현재는 Express 제거 고려 가능**

## 권장 방향

1. **Store 구조 개선**

   - root store 활용 시: `_app.js`에서 `mobxStore.getStores()`를 Provider에 전달하고 도메인 store를 root store에 등록
   - 또는 현재처럼 도메인별 store만 사용해도 무방 (복잡하지 않은 경우)

2. **Express + Next.js 구조 개선 (Next.js 9 → 13)**

   - Next.js 13+ 에서는 Express 커스텀 서버 제거 고려
   - 프록시, 캐싱, 커스텀 라우팅이 꼭 필요한지 검토
   - **Express가 URL 매핑과 SSR을 위해 사용되었으나, Next.js 13+에서는 내장 기능으로 대체 가능**
   - 필요한 경우에만 Express 유지, 그렇지 않으면 Next.js 내장 기능으로 대체

3. **결론**
   - 구조 단순화가 유지보수와 업그레이드에 유리
   - 현재는 도메인별 store만 사용 중이며 Express 커스텀 서버는 가능하면 제거 고려
