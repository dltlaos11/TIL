### Background

> - 문법 수준에서 모듈을 지원하기 시작한 것은 `ES2015`
> - `import/export` 구문이 없었던 모듈 이전 상황

> - `math.js`에 `sum`함수를 만들고 `math.js`가 로딩되면 `app.js`는 이름 공간에서 `sum`을 찾은 뒤 이 함수를 실행한다. 문제는 `sum`이 전역 공간에 노출된다는 것. 다른 파일에서도 `sum`이란 이름을 사용한다면 충돌한다.

#### IIFE(즉시실행함수) 방식의 모듈

> - 문제를 예방하기 위해 스코프를 사용
> - 함수 스코프를 만들어 외부에서 안으로 접근하지 못하도록 공간을 격리
> - 스코프 안에서는 자신의 `NameSpace`가 존재

```js
var math = math || {}; // math 네임스페이스

(function () {
  function sum(a, b) {
    return a + b;
  }
  math.sum = sum; // 네이스페이스에 추가
})();
```

> - `sum`이란 이름은 즉시실행함수 안에 감추어졌기 때문에 외부에서는 같은 이름을 사용 가능
> - 전역에 등록한 `math`라는 `NameSpace` 스코프만 지킨다면

#### 다양한 모듈 스펙

> 이러한 방식으로 자바스크립트 모듈을 구현하는 대표적인 명세가 `AMD`와 `CommonJS`.

> - `CommonJS` 는 자바스크립트를 사용하는 모든 환경에서 모듈을 하는 것이 목표
> - `exports` 키워드로 모듈을 만들고 `require()` 함수로 불러 들이는 방식
>   > e.g. 서버 사이드 플래폼인 Node.js

```js
exports function sum(a, b) { return a + b; }
...
const math = require("./math.js")
```

> `AMD(Asynchronous Module Definition)`는 외부에서 js파일을 비동기로 로딩되는 환경에서 모듈을 사용하는 것이 목표
>
> - 브라우져 환경이다.

> `UMD(Universal Module Definition)`는 `AMD`기반으로 `CommonJS` 방식까지 지원하는 통합 형태

::이렇게 각 커뮤니티에서 각자의 스펙을 제안하다가 `ES2015`에서 표준 모듈 시스템을 내 놓았다. 지금은 `바벨`과 `웹팩`을 이용해 `모듈 시스템`을 사용하는 것이 일반적

```js
export function sum(a, b) {
  return a + b;
}
...
import * as math from "./math.js"
```

export 구문으로 모듈을 만들고 import 구문으로 가져올 수 있다.

```sh
npx lite-server
```

> - 현재 폴더로 간단한 서버생성 가능

#### 브라우저의 모듈 지원

> - 모든 브라우져에서 모듈 시스템을 지원하지는 않는다
> - 크롬 브라우져만 (버전 61부터 모듈시스템을 지원 한다)

```html
<script type="module" src="app.js"></script>
```

> - `type="module"`
> - `app.js`는 모듈을 사용 가능

> 브라우저에 무관하게 모듈을 사용하고 싶다면 <mark>웹팩</mark>을 사용해야

### 엔트리/아웃풋

> 웹팩은 여러개 파일을 하나의 파일로 합쳐주는 번들러(`bundler`)
>
> - 하나의 시작점(`entry point`)으로부터 의존적인 모듈을 전부 찾아내서 하나의 결과물을 만들어 냄
> - `app.js`부터 시작해 `math.js` 파일을 찾은 뒤 하나의 파일로 만드는 방식

> 번들 작업을 하는 `webpack` 패키지와 웹팩 터미널 도구인 `webpack-cli`를 설치

```sh
npm install -D webpack webpack-cli
```

> - 설치 완료하면 node_modules/.bin 폴더에 실행 가능한 명령어가 생김
> - `--mode`, `--entry`, `--output` 세 개 옵션만 사용하면 코드를 묶을 수 있다
>   > - `--entry`는 시작점 경로를 지정하는 옵션
>   > - `--output`은 번들링 결과물을 위치할 경로

```sh
node_modules/.bin/webpack --mode development --entry ./src/app.js --output dist/main.js
```

> - `dist/main.js`에 번들된 결과가 저장

```html
<script src="dist/main.js"></script>
```

> - 이 코드를 `index.html`에 로딩하면 번들링 전과 똑같은 결과를 만든다.
>   많은 옵션을 통해 명령어를 입력하기 번거로우니 `webpack.config.js` 생성

```js
const path = require("path");

module.exports = {
  mode: "development",
  entry: {
    main: "./src/app.js",
  },
  output: {
    filename: "[name].js",
    path: path.resolve("./dist"),
  },
};
```

> - ouput에 설정한 `[name]`은 entry에 추가한 main이 문자열로 들어오는 방식(동적)
>   > - output.path는 `절대 경로`를 사용하기 때문에 path 모듈의 resolve() 함수를 사용해서 계산. (path는 노드 코어 모듈 중 하나로 경로를 처리하는 기능을 제공)
>   >   `

> - 웹팩 실행을 위한 NPM 커스텀 명령어를 추가

```json
  "scripts": {
    "build": "webpack"
  },
```

> 엔트리는 js 모듈이 여러개의 의존 관계속 시작점
> 엔트리를 기준으로 모든 모듈들을 찾아서 하나의 파일로 번들링한 결과물을 아웃풋에 저장

### 로더

#### 로더의 역할

> - 웹팩은 모든 파일을 `모듈`로 바라본다
>   > - 자바스크립트로 만든 모듈 뿐만아니라 스타일시트, 이미지, 폰트까지도 전부 모듈로 본다
> - 때문에 `import` 구문을 사용하면 자바스크립트 코드 안으로 가져올수 있다

> 이것이 가능한 이유는 `웹팩의 로더` 덕분
>
> - 1. 로더는 타입스크립트 같은 다른 언어를 `자바스크립트 문법으로` 변환해 주거나
> - 2. 이미지를 data URL 형식의 `문자열로` 변환
> - 3. 뿐만아니라 CSS 파일을 자바스크립트에서 `직접 로딩할수 있도록` 해줌

#### 커스텀 로더 만들기

> - root 위치에 myloader.js 파일 추가

```js
module.exports = function myloader(content) {
  console.log("myloader가 동작함");
  return content;
};
```

> - 로더를 사용하려면 웹팩 설정파일의 `module` 객체에 추가

```js
module: {
  rules: [{
    test: /\.js$/, // .js 확장자로 끝나는 모든 파일
    use: [path.resolve('./myloader.js')] // 방금 만든 로더를 적용한다
  }],
}
```

> - `module.rules` 배열에 모듈을 추가하는데 `test`와 `use`로 구성된 객체를 전달
>   > - `test`에는 로딩에 적용할 파일을 지정. 파일명 뿐만아니라 파일 패턴을 `정규표현식`으로 지정할수 있는데 위 코드는 .js 확장자를 갖는 모든 파일을 처리하겠다는 의미
>   > - `use`에는 이 패턴에 해당하는 파일에 적용할 로더를 설정하는 부분. 방금 만든 `myloader` 함수의 경로를 지정한다.

> - `npm run build`로 웹팩을 실행해보면 log를 확인 가능
> - 2개의 js파일이 있기에 모든 js파일마다 로더가 한 번씩 실행되도록 했기에 2번의 로그가 나옴

> 웹팩의 로더는 각 파일을 처리하기 위한 역할
>
> - `rules` 배열 객체 인자 `test`로 처리 할 패턴을 명시하고
> - 이 패턴에 걸리는 파일들을 `use`인자로 설정한 로더 함수를 통해 실행된다
