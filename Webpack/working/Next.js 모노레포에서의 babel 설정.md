# Next.js 모노레포에서의 babel 설정\_트랜스파일 과정과 폴리필

## 정확성 확인

네, 제공한 정보는 정확합니다. Next.js에서 `next-transpile-modules` 플러그인을 사용할 경우, 해당 플러그인에 명시된 모듈들은 자체 `babel.config.js`가 아닌 Next.js의 바벨 설정으로 트랜스파일됩니다. 특히 패키지의 `main` 필드가 `src/index.js`를 가리키는 경우 이 과정이 더욱 명확히 확인됩니다.

## 트랜스파일과 폴리필 요약

### 트랜스파일(Transpile)

최신 JavaScript 문법을 이전 버전과 호환되는 코드로 변환하는 과정입니다.

### 폴리필(Polyfill)

최신 JavaScript API나 기능을 이전 버전의 JavaScript 환경에서도 사용할 수 있게 해주는 코드 조각입니다.

## 간단한 예시

### 트랜스파일 예시

**원본 코드 (최신 JavaScript)**:

```javascript
// 화살표 함수, 템플릿 리터럴, 구조 분해 할당 사용
const getFullName = ({ firstName, lastName }) => {
  return `${firstName} ${lastName}`;
};

// 옵셔널 체이닝
const getUserName = (user) => {
  return user?.profile?.name || "Unknown";
};
```

**트랜스파일 후 (ES5)**:

```javascript
"use strict";

// 화살표 함수 → 일반 함수
var getFullName = function getFullName(_ref) {
  var firstName = _ref.firstName;
  var lastName = _ref.lastName;
  // 템플릿 리터럴 → 문자열 연결
  return firstName + " " + lastName;
};

// 옵셔널 체이닝 → 조건 확인 로직
var getUserName = function getUserName(user) {
  return (user && user.profile && user.profile.name) || "Unknown";
};
```

### 폴리필 예시

**최신 API 사용 코드**:

```javascript
// Promise.allSettled()는 ES2020에 도입된 기능
const results = await Promise.allSettled([
  fetch("/api/data1"),
  fetch("/api/data2"),
]);

// Array.prototype.includes는 ES2016에 도입된 기능
const hasItem = [1, 2, 3].includes(2);
```

**폴리필 적용**:

```javascript
// Promise.allSettled 폴리필
if (!Promise.allSettled) {
  Promise.allSettled = function (promises) {
    return Promise.all(
      promises.map((p) =>
        Promise.resolve(p)
          .then((value) => ({ status: "fulfilled", value }))
          .catch((reason) => ({ status: "rejected", reason }))
      )
    );
  };
}

// Array.prototype.includes 폴리필
if (!Array.prototype.includes) {
  Array.prototype.includes = function (searchElement, fromIndex) {
    return this.indexOf(searchElement, fromIndex) !== -1;
  };
}
```

## 트랜스파일과 폴리필의 차이점

| 트랜스파일                                | 폴리필                                    |
| ----------------------------------------- | ----------------------------------------- |
| 문법 변환 (화살표 함수, 템플릿 리터럴 등) | API 구현 (Promise, Array.includes 등)     |
| 코드 구조 변경                            | 누락된 기능 추가                          |
| 바벨(Babel)이 주로 담당                   | 바벨이나 core-js와 같은 라이브러리가 제공 |
| 정적(컴파일 타임) 변환                    | 런타임에 필요한 기능 검사 후 추가         |

## Next.js 모노레포에서의 적용

Next.js 모노레포에서 `next-transpile-modules`를 사용하면:

1. **트랜스파일**: 모든 코드 변환(문법 수준)은 Next.js의 바벨 설정을 통해 일원화됩니다.

2. **폴리필**: Next.js는 기본적으로 필요한 폴리필을 자동으로 포함합니다. 추가 폴리필이 필요한 경우 `next/polyfill`을 임포트하거나 `next.config.js`에서 설정할 수 있습니다.

```javascript
// 폴리필 추가 예시 (next.config.js)
module.exports = {
  webpack: (config, { isServer }) => {
    if (!isServer) {
      config.entry = async () => {
        const entries = await originalEntry();

        // 필요한 폴리필 추가
        if (entries["main.js"]) {
          entries["main.js"].unshift("core-js/stable");
          entries["main.js"].unshift("regenerator-runtime/runtime");
        }

        return entries;
      };
    }

    return config;
  },
};
```

## 요약

Next.js 모노레포에서 `next-transpile-modules`를 사용할 경우, 모든 트랜스파일 과정은 개별 모듈의 `babel.config.js`가 아닌 Next.js의 바벨 설정에 의해 제어됩니다. 이로 인해 코드 변환 과정이 일관되게 유지되며, 개발 효율성이 향상됩니다. 폴리필은 필요한 기능을 `런타임`에 제공하여 최신 JavaScript 기능을 오래된 브라우저에서도 사용할 수 있게 해줍니다. 트랜스파일이 코드의 구문을 변환한다면, 폴리필은 누락된 기능을 추가하는 차이가 있습니다.

> - `Entry Point`가 되는 모듈에서 참조되는 개별 모듈들의 바벨 트랜스파일 과정을 Next.js 애플리케이션의 최상단 설정에서 통합적으로 제어

---

> 모듈이 자체적으로 독립적으로 동작하지 않는다면 `그 모듈 자체의 바벨 설정은 필요하지 않습니다`. 하지만 중요한 예외 상황이 있습니다:

> 1. 테스트 실행: 모듈에서 단위 테스트나 통합 테스트를 실행할 때는 자체 바벨 설정이 필요합니다. Jest나 다른 테스트 러너를 사용할 때 해당 모듈의 바벨 설정을 사용하게 됩니다.
> 2. 독립적 빌드: 해당 모듈을 독립적으로 빌드해서 npm에 배포하거나 다른 프로젝트에서 사용할 경우에도 자체 바벨 설정이 필요합니다.
> 3. 로컬 개발: 모듈을 독립적으로 개발하거나 테스트할 때(예: Storybook 등으로 컴포넌트 개발) 자체 바벨 설정이 사용됩니다.

> - Next.js 앱 내에서 사용될 때는 → Next.js의 바벨 설정만 적용됨
> - 모듈 자체적으로 테스트/빌드/개발될 때는 → 모듈 자체의 바벨 설정이 필요함

따라서 모듈이 단순히 Next.js 앱에서만 사용되고 자체 테스트나 독립적 빌드가 없다면 바벨 설정을 제거해도 됩니다. 하지만 테스트를 실행하거나 다른 방식으로 모듈을 독립적으로 사용한다면 바벨 설정은 유지해야 한다.

> - 확인 필요, 현재는 독립적인 빌드를 하는 모듈은 entry point 모듈에 포함에 안되며 자체 babel을 사용하지만, 참조가 되는 모듈은 babel을 가지고 있음. 테스트나 storybook이 아니라면 필요없어 보임.
