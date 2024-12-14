## 프론트엔드 개발환경의 이해(웹팩)

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

### 자주 사용하는 로더

#### css-loader

> 웹팩은 모든것을 `모듈`로 바라보기 때문에 자바스크립트 뿐만 아니라 스타일시트도 `import` 구문으로 불러 올수 있다

```js
import "./style.css";
...
body {
  background-color: green;
}
```

> - 웹팩이 css파일을 js 모듈로서 가져오게끔 css파일을 처리해주는 것이 `css-loader`

```js
  module: {
    rules: [
      {
        test: /\.css$/, // .css 확장자로 끝나는 모든 파일
        use: ["css-loader"], // 방금 만든 로더를 적용한다
      },
    ],
  },
```

> - 웹팩 설정에 로더를 추가
> - 웹팩은 엔트리 포인트부터 시작해서 모듈을 검색하다가 CSS 파일을 찾으면 `css-loader`로 처리할 것
> - `use.loader`에 로더 경로를 설정하는 대신 배열에 로더 이름을 문자열로 전달해도 된다

> index.html에서 background가 변하지 않은 것을 확인할 수 있는데, main.js파일 안에 문자열 형태로 명시되어 있다..
>
> - html 코드가 DOM이라는 모습으로 변환되어야 브라우저에서 문서가 보이듯 css 코드도 CSSOM이라는 형태로 바꿔야 브라우저에서 변경 확인 가능
> - 1. 그렇게 하려면 html파일에서 css코드를 직접 불러오거나
> - 2. 인라인 스크립트로 넣어줘야
> - 아직 그런 처리를 하지 않고 js파일에만 css코드가 있어서 브라우저에서 확인이 불가

#### style-loader

> 위 문제를 해결하기 위해서 나온것이 `style-loader`다
>
> - 모듈로 변경된 스타일 시트는 돔(`CSSOM`)에 추가되어야만 브라우져가 해석할 수 있다
> - `css-loader`로 처리하면 자바스크립트 코드로만 변경되었을 뿐 돔에 적용되지 않았기 때문에 스트일이 적용되지 않았다.
> - `style-loader`는 자바스크립트로 변경된 스타일을 `동적으로` 돔에 추가하는 로더이다. CSS를 번들링하기 위해서는 `css-loader와 style-loader`를 함께 사용한다

```js
...
 use: [ "css-loader", "style-loader"]
...
```

> - <mark>배열로 설정하면 뒤에서부터 앞으로 순서대로 로더가 동작한다.
> - 위 설정은 모든 .css 확장자로 끝나는 모듈을 읽어 들여 1)`css-loader`를 적용하고 그 다음 2)`style-loader`를 적용한다.

#### file-loader

> CSS 뿐만 아니라 소스코드에서 사용하는 모든 파일을 모듈로 사용하게끔 할 수 있다.
>
> - 파일을 모듈 형태로 지원하고 웹팩 아웃풋에 파일을 옮겨주는 것이 `file-loader`의 역할
> - 가령 `CSS`에서 `url()` 함수에 이미지 파일 경로를 지정할 수 있는데 웹팩은 `file-loader`를 이용해서 이 파일을 처리

```js
body {
  background-image: url(bg.jpeg);
}
...
module.exports = {
  module: {
    rules: [
      {
        test: /\.jpeg$/, // .jpeg 확장자로 마치는 모든 파일
        loader: "file-loader", // 파일 로더를 적용한다
      },
    ],
  },
}
```

> - 웹팩은 엔트리 포인트인 `app.js`가 로딩하는 `style.css` 파일을 읽을 것이다
> - 그리고 이 스타일시트는 `url()` 함수로 `bg.jpeg`를 사용하는데 <mark>이때 로더를 동작시킨다
> - 웹팩이 `.jpeg` 파일을 발견하면 `file-loader`를 실행할 것이다
> - 로더가 동작하고 나면 아웃풋에 설정한 경로로 이미지 파일을 복사
> - 파일명이 해쉬코드로 변경되는데, `캐시 갱신`을 위한 처리(동일명의 파일일 경우 이전 요청이 지속될 수도)
> - 그러나 웹팩으로 빌드한 이미지 파일은 `output`인 `dist` 폴더 아래로 이동했기 때문에 이미지 로딩에 실패

```js
   {
       test: /\.(jpeg|png|gif|svg)$/, // .jpeg 확장자로 마치는 모든 파일
      loader: "file-loader", // 파일 로더를 적용한다
      options: {
        publicPath: "./dist/", // prefix를 아웃풋 경로로 지정
        name: "[name].[ext]?[hash]", // 파일명 형식, 캐시 무력화를 위한 해시 값 사용
        // e.g.) ./dist/bg.jpeg?ffb0298fbaec30f9528f8f5fb1f12bde
      },
    },
```

> - `publicPath` 옵션은 `file-loader`가 처리하는 파일을 모듈로 사용할 때 경로 앞에 추가되는 문자열
> - `name` 옵션을 사용했는데 이것은 로더가 파일을 아웃풋에 복사할때 사용하는 파일 이름
>   > - 기본적으로 설정된 해쉬값을 쿼리스트링으로 옮긴 형태
>   > - `./dist/bg.jpeg?ffb0298fbaec30f9528f8f5fb1f12bde`

> `file-loader`의 `options` 인자

> - `[name]`: 원본 파일의 이름
> - `[ext]`: 원본 파일의 확장자
> - `[path]`: 파일의 경로
> - `[folder]`: 파일이 속한 폴더 이름
> - `[contenthash]`: 파일 내용의 해시 값
> - `[hash]`: 파일의 해시 값 (기본적으로 MD5, 길이는 옵션으로 조정 가능)
> - `[emoji]`: 파일 해시를 이모지로 변환한 값

```js
{
  loader: 'file-loader',
  options: {
    name: '[name].[ext]?[contenthash]',
  },
}
```

> - `example.png?abc123`

#### url-loader

> - 사용하는 이미지 갯수가 많다면 네트워크 리소스를 사용하는 부담이 있고 사이트 성능에 영향을 줄 수도 있다
> - 만약 한 페이지에서 작은 이미지를 여러 개 사용한다면 `Data URI Scheme`을 이용하는 방법이 더 나은 경우도 있다
> - 이미지를 `Base64`로 인코딩하여 문자열 형태로 소스코드에 넣는 형식
>   > - 통상적인 주소를 넣는다면 추가적인 네트워크 리소스가 사용될 것

```html
<img
  alt="Red dot"
  src="data:image/png;base64,iVBORw0KGgoAAA
ANSUhEUgAAAAUAAAAFCAYAAACNbyblAAAAHElEQVQI12P4
//8/w38GIAXDIBKE0DHxgljNBAAO9TXL0Y4OHwAAAABJRU
5ErkJggg=="
  style="width:36pt;height:36pt"
/>
```

```js
   {
      test: /\.(png|jpeg)$/,
      use: {
        loader: "url-loader", // url 로더를 설정한다
        options: {
          publicPath: "./dist/", // file-loader와 동일
          name: "[name].[ext]?[hash]", // file-loader와 동일
          limit: 20000, // 20kb 미만 파일만 data url로 처리
        },
      },
    },
```

> - `file-loader`와 옵션 설정이 거의 비슷하고 마지막 `limit` 속성만 추가했다.
> - 모듈로 사용한 파일중 크기가 `20kb` 미만인 파일만 `url-loader`를 적용하는 설정
> - 만약 이보다 크면 `file-loader`가 처리하는데 <mark>옵션 중 `fallback` 기본값이 `file-loader`이기 때문
> - 빌드 결과를 보면 `nyancat.png` 파일이 문자열(`Data url`형태)로 변경되어 있는 것을 확인 할 수 있다. 반면 20kb 이상인 `bg.jpeg`는 여전히 파일로 존재)

> 아이콘처럼 `용량이 작거나` `사용 빈도가 높은 이미지`는 파일을 그대로 사용하기 보다는 `Data URI Scheeme`을 적용하기 위해 `url-loader`를 사용하면 좋을 것

> - `css-loader`: css파일을 js모듈처럼 사용할 수 있도록 css 파일을 처리하는 로더
> - `style-loader`: js 문자열로 되어 있는 `style-sheet` 코드를 html에 주입시켜 브라우저에 스타일이 적용되도록 하는 역할
> - `file-loader`: 이미지 파일을 모듈로 사용할 수 있도록 변환하는 역할, 사용한 파일을 output경로로 이동시킴
> - `url-loader`: 파일을 `base64`로 인코딩해서 그 결과를 js문자열로 변환, 처리할 파일의 크기 제한을 둬서 일정 파일 미만만 처리하고 나머지는 `file-loader`로 유입하는 역할, 아웃풋으로 이동하겠지?

### 플러그인

#### 플러그인의 역할

> 로더가 파일 단위로 처리하는 반면 플러그인은 <mark>번들된 결과물을 처리
>
> - 번들된 자바스크립트를 `난독화` 한다거나 `특정 텍스트를 추출하는 용도`로 사용

#### 커스텀 플러그인 만들기

> - 웹팩 문서의 [Writing a plugin](https://webpack.js.org/contribute/writing-a-plugin/)을 보면 클래스로 플러그인을 정의 하도록 한다

```js
class MyWebpackPlugin {
  apply(compiler) {
    compiler.hooks.done.tap("My Plugin", (stats) => {
      console.log("MyPlugin: done");
    });
  }
}

module.exports = MyWebpackPlugin;
...
const MyPlugin = require("./myplugin")

module.exports = {
  mode: "development",
  entry: {...},
  output: {...},
  module: {...},
  plugins: [new MyWebpackPlugin()],
}
```

> - 로더와 다르게 플러그인은 클래스로 제작
> - `apply` 함수를 구현하면 되는데 이 코드에서는 인자로 받은 `compiler` 객체 안에 있는 `tap()` 함수를 사용하는 코드
> - 웹팩 설정 객체의 `plugins` 배열에 설정
> - 클래스로 제공되는 플러그인의 생성자 함수를 실행해서 넘기는 방식

> - 그런데 파일이 여러 개인데 로그는 한 번만 찍혔다
> - <b>모듈이 파일 하나 혹은 여러 개에 대해 동작하는 반면 플러그인은 <mark>하나로 번들링된 결과물을 대상으로 동작 한다</b>
> - `dist`폴더의 `main.js`로 결과물이 하나이기 때문에 플러그인이 한 번만 동작한 것

> 그러면 어떻게 번들 결과에 접근할 수 있을까? 웹팩 내장 플러그인 `BannerPlugin` 코드를 참고하자

```js
class MyWebpackPlugin {
  apply(compiler) {
    compiler.hooks.done.tap("My Plugin", (stats) => {
      console.log("MyPlugin: done");
    });

    // compiler.plugin() 함수로 후처리한다
    compiler.plugin("emit", (compilation, callback) => {
      const source = compilation.assets["main.js"].source();
      console.log(source);
      callback();
    });
  }
}

module.exports = MyWebpackPlugin;
```

> - `compiler.plugin()` 함수의 두번재 인자 콜백함수는 `emit` 이벤트가 발생하면 실행되는 것처럼 보인다
> - 번들된 결과가 `compilation` 객체에 들어 있는데 `compilation.assets['main.js'].source()` 함수로 접근
> - 이걸 이용해서 번들 결과 상단에 아래와 같은 배너를 추가하는 플러그인으로 만들어 보자

```js
class MyWebpackPlugin {
  apply(compiler) {
    compiler.plugin("emit", (compilation, callback) => {
      const source = compilation.assets["main.js"].source();
      compilation.assets["main.js"].source = () => {
        const banner = [
          "/**",
          " * 이것은 BannerPlugin이 처리한 결과입니다.",
          " * Build Date: 2024-12-03",
          " */",
          "",
        ].join("\n");
        return banner + "\n" + source;
      };

      callback();
    });
  }
}

module.exports = MyWebpackPlugin;
```

> - 번들 소스를 얻어오는 함수 `source()`를 재정의
> - 번들된 결과에 후처리를 했다.
>   > - dist/main.js의 상단에 후처리(접근)

> 웹팩의 로더는 모듈로 연결되어 있는 각 파일들을 처리해서 하나의 파일로 만들어주는데 그 직전에 <mark>플러그인</mark>이 개입해서 아웃풋으로 만들어질 번들에 <mark>후처리</mark>를 해주는 것이다.

### 자주 사용하는 플러그인

> - 개발하면서 플러그인을 직접 작성할 일은 거의 없다
> - 웹팩에서 직접 제공하는 플러그인을 사용하거나 써드파티 라이브러리를 찾아 사용

#### BannerPlugin

> 결과물에 빌드 정보나 커밋 버전같은 걸 추가할 수 있다
>
> - 노드 모듈 중 `child_process`를 통해 터미널 명령어를 실행할 수 있다

```js
const childProcess = require("child_process");

module.exports = function banner() {
  const commit = childProcess.execSync("git rev-parse --short HEAD");
  const user = childProcess.execSync("git config user.name");
  const date = new Date().toLocaleString();

  return (
    `commitVersion: ${commit}` + `Build Date: ${date}\n` + `Author: ${user}`
  );
};
...
module.exports = {
  ...
  plugins: [
    new webpack.BannerPlugin(banner),
  ],
}
```

> - 생성자 함수에 전달하는 옵션 객체의 `banner` 속성에 문자열을 전달한다
> - 빌드하고 배포했을 때 정적 파일들이 잘 배포됐는지 혹은 캐시에 의해 갱신되지 않는지 확인할 때 사용

#### DefinePlugin

> 같은 소스 코드를 두 환경에 배포하기 위해서는 이러한 환경 의존적인 정보를 소스가 아닌 곳에서 관리하는 것이 좋다
>
> - 웹팩은 이러한 환경 정보를 제공하기 위해 `DefinePlugin`을 제공

```js
const webpack = require("webpack");

export default {
  plugins: [new webpack.DefinePlugin({})],
};
```

> - 빈 객체를 전달해도 기본적으로 넣어주는 값이 있다
> - 노드 환경정보인 `process.env.NODE_ENV` 인데 웹팩 설정의 `mode`에 설정한 값이 여기에 들어간다
> - 이 외에도 웹팩 컴파일 시간에 결정되는 값을 전역 상수 문자열로 어플리케이션에 주입할 수 있다

> <b>빌드 타임에 결정된 값을 어플리이션에 전달할 때는 이 플러그인을 사용하자</b>

#### HtmlWebpackPlugin

> `HtmlWebpackPlugin`은 `HTML` 파일을 후처리하는데 사용하는 써드 파티 패키지
>
> - 빌드 타임의 값을 넣거나 코드를 압축할수 있다
> - 이 플러그인으로 빌드하면 `HTML`파일로 아웃풋에 생성될 것이다
> - 타이틀 부분에 `ejs` 문법을 이용하는데 `<%= env %>` 는 전달받은 `env` 변수 값을 출력
> - `HtmlWebpackPlugin`은 이 변수에 데이터를 주입시켜 동적으로 `HTML` 코드를 생성
> - <b>웹팩으로 빌드한 결과물을 자동으로 로딩하는 코드를 주입해 준다</b>
>   > - 때문에 스크립트 로딩 코드 제거

```js
const HtmlWebpackPlugin = require('html-webpack-plugin');

module.exports {
  plugins: [
    new HtmlWebpackPlugin({
      template: './src/index.html', // 템플릿 경로를 지정
      templateParameters: { // 템플릿에 주입할 파라매터 변수 지정
        env: process.env.NODE_ENV === 'development' ? '(개발용)' : '',
      },
    })
  ]
}
```

> - `NODE_ENV=development` 로 설정해서 빌드하면 빌드결과 "타이틀(개발용)"으로 나온다
> - `NODE_ENV=production` 으로 설정해서 빌드하면 빌드결과 "타이틀"로 나온다

```js
new HtmlWebpackPlugin({
  minify: process.env.NODE_ENV === 'production' ? {
    collapseWhitespace: true, // 빈칸 제거
    removeComments: true, // 주석 제거
  } : false,
}
```

> - 개발 환경과 달리 운영 환경에서는 파일을 압축하고 불필요한 주석을 제거하는 것이 좋다
> - 환경변수에 따라 `minify` 옵션, `NODE_ENV=production npm run build`로 빌드하면 코드 압축, 주석 제거

> - 정적파일을 배포하면 즉각 브라우져에 반영되지 않는 경우가 있다
> - 브라우져 캐쉬가 원인일 경우가 있는데 이를 위한 예방 옵션도 있다

```js
new HtmlWebpackPlugin({
  hash: true, // 정적 파일을 불러올때 쿼리문자열에 웹팩 해쉬값을 추가한다
});
```

> - `hash: true` 옵션을 추가하면 빌드할 시 생성하는 해쉬값을 정적파일 로딩 주소의 쿼리 문자열로 붙여서 `HTML`을 생성한다

#### CleanWebpackPlugin

> `CleanWebpackPlugin`은 빌드 이전 결과물을 제거하는 플러그인
>
> - 빌드 결과물은 아웃풋 경로에 모이는데 과거 파일이 남아 있을수 있다
> - 이전 빌드내용이 덮여 씌여지면 상관없지만 그렇지 않으면 아웃풋 폴더에 여전히 남아 있을 수 있다
> - `module.exports = HtmlWebpackPlugin;`는 `CJS`에서 `Default export`와 같은 역할을 하며, 이 모듈을 불러올 때는 `require`를 사용. 반면, `ES6(ESM)` 모듈에서는 `export default`를 사용하여 동일한 기능을 제공. 두 모듈 시스템은 `Node.js`와 `브라우저 환경`에서 `모듈을 관리하는 방식이 다르기 때문`에, 상황에 맞게 사용해야
> - `const { CleanWebpackPlugin } = require("clean-webpack-plugin");` -> `Named Export`
>   > - 이 방식은 모듈 내에서 여러 개의 값을 내보낼 때 유용

```js
// clean-webpack-plugin.js
class CleanWebpackPlugin {
  // 클래스 정의
}

export { CleanWebpackPlugin };
...
// 다른 파일에서 import
import { CleanWebpackPlugin } from './clean-webpack-plugin';

module.exports = {
  plugins: [new CleanWebpackPlugin()],
}
```

> - `Default Export`와의 차이
>   > - `Default Export`는 모듈당 하나만 있을 수 있으며, `import`할 때 중괄호 없이 가져온다
>   > - `Named Export`는 모듈당 여러 개 있을 수 있으며, `import`할 때 중괄호를 사용하여 가져온다

> 빌드 후 임의로 만든 파일이 삭제되는 것을 확인 가능

#### MiniCssExtractPlugin

> `MiniCssExtractPlugin`은 CSS를 별도의 파일로 뽑아내는 플러그인

> - 스타일시트가 점점 많아지면 하나의 자바스크립트 결과물로 만드는 것이 부담일 수 있다
> - 번들 결과에서 스트일시트 코드만 뽑아서 별도의 CSS 파일로 만들어 역할에 따라 파일을 분리하는 것이 좋다
> - 브라우져에서 큰 파일 하나를 내려받는 것 보다, 여러 개의 작은 파일을 동시에 다운로드하는 것이 더 빠르다

```js
const MiniCssExtractPlugin = require("mini-css-extract-plugin");

module.exports = {
  plugins: [
    ...(process.env.NODE_ENV === "production"
      ? [new MiniCssExtractPlugin({ filename: `[name].css` })]
      : []),
  ],
};
```

> - 개발 환경에서는 CSS를 하나의 모듈로 처리해도 상관없지만 프로덕션 환경에서는 분리하는 것이 효과적
> - 프로덕션 환경일 경우만 이 플러그인을 추가
>   > - 개발 모드에서는 그냥 js 파일 하나로 빌드하는 것이 빠를 것
> - `filename`에 설정한 값으로 아웃풋 경로에 CSS 파일이 생성될 것
> - <b>개발 환경에서는 `css-loader`에의해 자바스크립트 모듈로 변경된 스타일시트를 적용하기위해 `style-loader`를 사용했다</b>

```js
module.exports = {
  module: {
    rules: [
      {
        test: /\.css$/,
        use: [
          process.env.NODE_ENV === "production"
            ? MiniCssExtractPlugin.loader // 프로덕션 환경
            : "style-loader", // 개발 환경
          "css-loader",
        ],
      },
    ],
  },
};
```

> - 반면 프로덕션 환경에서는 <mark>별도의 CSS 파일으로 추출하는 플러그인을 적용했으므로 다른 로더가 필요</mark>
> - `dist/main.css`가 생성되었고 `index.html`에 이 파일을 로딩하는 코드가 추가되었다

> - `Banner` 플러그인은 번들링된 결과물 상단에 빌드 정보를 추가하였고 잘 배포되었는지 확인하는 요도로 많이 사용한다
> - `Define` 플러그인은 빌드 타임에 결정되는 환경 변수를 애플리케이션 단에서 주입하기 위해 사용한다
>   > - e.g.) API 주소
> - `HtmlTemplate` 플러그인은 동적으로 생성되는 js와 css 그리고 빌드 타임에 결정되는 값들을 이 템플릿 파일에 주입해서 html을 빌드시 동적으로 만들어낸다
> - `CleanWebpack` 플러그인은 빌드시 output폴더를 삭제
> - `MiniCssExtract` 플러그인은 번들된 js코드에서 css파일만 따로 뽑아내서 css파일을 만들어낸다

### 정리

> - `ECMAScript2015` 이전에는 모듈을 만들기 위해 즉시실행함수와 네임스페이스 패턴을 사용
> - 이후 각 커뮤니티에서 모듈 시스템 스펙이 나왔고
> - 웹팩은 `ECMAScript2015` 모듈시스템을 쉽게 사용하도록 돕는 역할을 한다
> - <mark>엔트리포인트를 시작으로 연결되어 었는 모든 모듈을 하나로 합쳐서 결과물을 만드는 것이 웹팩의 역할</mark>
> - 자바스크립트 모듈 뿐만 아니라 스타일시트, 이미지 파일까지도 모듈로 제공해 주기 때문에 일관적으로 개발 가능

## 프론트엔드 개발환경의 이해(바벨)

### 배경

#### 크로스 브라우징

> 히브리어로 바벨이 `혼돈`을 의미

> - <i>브라우져마다 사용하는 언어가 달라서</i> 프론트엔트 코드는 일관적이지 못할 때가 많다
> - 프론트엔드 개발에서 `크로스브라우징` 이슈는 코드의 일관성을 해치고 초심자를 불안하게 만든다

> - 크로스브라우징의 혼란을 해결해 줄 수 있는 것이 <mark>바벨</mark>
> - `ECMAScript2015+`로 작성한 코드를 모든 브라우져에서 동작하도록 호환성을 지켜준다
>   > - 타입스크립트, JSX처럼 다른 언어로 분류되는 것도 포함한다

#### 트랜스파일과 빌드

> - 변환하는 것을 `트랜스파일` 한다라고 표현
> - 변환 전후의 추상화 수준이 다른 `빌드`와는 달리 <mark>`트랜스파일`은 추상화 수준을 유지한 상태로 코드를 변환</mark>
>   > - `타입스크립트 → 자바스크립트`, `JSX → 자바스크립트`처럼 트랜스파일 후에도 여전히 코드를 읽을 수 있다

### 바벨의 기본 동작

> 바벨은 `ECMAScript2015` 이상의 코드를 적당한 <b>하위 버전으로 바꾸는 것이 주된 역할</b>
>
> - 이렇게 바뀐 코드는 레거시 브라우져같은 최신 자바스크립트 코드를 이해하지 못하는 환경에서도 잘 동작한다

> 바벨을 이용해 아래 코드를 레거시 브라우저가 이해할 수 있는 코드로 바꿔 보자

```js
// src/app.js:
const alert = (msg) => window.alert(msg);
```

> - 바벨의 핵심 라이브러리(`@babel/core`) 터미널 도구를 사용하기 위해 커맨드라인 도구(`@babel/cli`)를 설치

> - 설치를 완료후 `node_modules/.bin/babel` 폴더에 추가된 <mark>바벨 명령어</mark>를 사용할 수 있다
> - 또한 `npx`로 설치한 모듈을 바로 실행 가능 `npx babel app.js`

> 바벨은 세 단계의 빌드로 진행한다.
>
> - 1. `파싱(Parsing)`
>      > - 파싱은 코드를 받아서 각 토큰별로 분해한다
>      > - e.g.) `const`, `alert`, `=`, ...
>      > - 코드를 읽고 `추상 구문 트리(AST)`로 변환하는 단계를 `파싱`이라고 한다
>      > - `Babel`은 이 단계에서 `@babel/parser`를 사용하여 소스 코드를 `AST`로 변환
>      > - 이것은 빌드 작업을 처리하기에 적합한 <mark>자료구조</mark>인데 <b>컴파일러 이론에 사용되는 개념</b>
> - 2. `변환(Transforming)`
>      > - `ES6 -> ES5`로 변환하는 단계
>      > - 위 코드를 변환할 때 출력된 결과가 바뀐게 없었으니 `변환`과정은 없었던 것
>      > - 추상 구문 트리를 변경하는 것이 `변환` 단계
>      > - 이 단계에서 `Babel`의 <mark>플러그인</mark>들이 작동하여 특정 문법을 다른 문법으로 변환하거나, 최적화를 수행
>      > - 실제로 코드를 변경하는 작업을 한다
> - 3. `출력 (Printing)`
>      > - 변환된 결과물을 `출력`하는 것을 마지막으로 바벨은 작업을 완료한다
>      > - `@babel/generator`를 사용하여 `AST`를 문자열 형태의 `JavaScript` 코드로 출력

#### AST

> `AST(추상 구문 트리, Abstract Syntax Tree)`는 소스 코드의 구조를 <b>트리 형태</b>로 표현한 것
>
> - 이는 컴파일러나 트랜스파일러가 소스 코드를 이해하고 조작하기 위해 사용하는 핵심 데이터 구조
> - `Babel`에서 `AST`를 지속적으로 언급하는 이유는 다음과 같다
>   > - 1.  코드 구조의 표현:
>   >       > - `AST`는 코드의 문법적 구조를 트리 형태로 나타낸다.
>   >       > - 각 노드는 코드의 요소(예: 변수, 함수, 연산자 등)를 나타내며, 이들 간의 관계를 정의
>   >       > - 예를 들어, `let x = 5;`라는 코드는 AST에서 `변수 선언 노드`와 `값 노드`로 표현된다
>   > - 2. 변환의 기반:
>   >      > - `Babel`은 코드를 변환할 때, <mark>소스 코드를 직접 조작하지 않고</mark> AST를 조작한다. 이는 코드의 구조적 변환을 보다 체계적이고 안전하게 수행할 수 있게 해준다
>   >      > - 변환 플러그인은 AST를 기반으로 특정 문법을 다른 문법으로 바꾸거나, 최적화를 수행
>   > - 3. 언어 중립성:
>   >      > - AST는 특정 프로그래밍 언어에 종속되지 않는 중립적인 표현이다. Babel은 `JavaScript 코드를 AST로 변환한 후, 이를 조작하여 다른 형태의 JavaScript로 변환`하는데, 이 과정은 언어 중립적인 AST 덕분에 가능하다
>   > - 4. 코드 생성:
>   >      > - 변환된 AST는 다시 JavaScript 코드로 변환
>
> `Babel`은 최신 `JavaScript` 문법을 구형 브라우저에서도 실행 가능하도록 변환하는 <mark>트랜스파일러.</mark> 이 변환 과정에서 AST는 핵심적인 역할을 한다. `Babel의 플러그인들`은 <b>AST를 조작하여 원하는 변환을 수행</b>하며, 이러한 AST 조작은 Babel의 변환 과정에서 가장 중요한 부분
> 요약하자면, `AST`는 `Babel`이 <mark>소스 코드를 이해하고 변환하는 데 있어 가장 중요한 데이터 구조</mark>이며, Babel의 모든 변환 과정은 `AST를 기반`으로 이루어진다

### 플러그인

> 기본적으로 바벨은 코드를 받아서 코드를 반환
>
> - 바벨 함수를 정의한다면 이런 모습이 될 것

```js
const babel = (code) => code;
```

> - 바벨은 파싱과 출력만 담당하고 <b>변환 작업은 다른 녀석이 처리하는데</b> 이것을 `플러그인` 이라고 부른다

#### 커스텀 플러그인

> 플러그인을 직접 만들면서 동작이 원리를 살펴 보자

```js
module.exports = function myBabelPlugin() {
  return {
    visitor: {
      Identifier(path) {
        const name = path.node.name;

        // 바벨이 만든 AST 노드를 출력
        console.log("Identifier() name:", name);

        // 변환작업: 코드 문자열을 역순으로 변환
        path.node.name = name.split("").reverse().join("");
      },
    },
  };
};
```

> - 이 객체는 바벨이 파싱하여 만든 추상 구문 트리(AST)에 접근할 수 있는 메소드를 제공한다
> - 그중 `Identifier()` 메소드의 동작 원리를 살펴보는 코드
>   > - `Identifier()` 메소드로 들어온 인자 path에 접근하면 코드 조각에 접근할 수 있는 것 같다
>   > - path.node.name의 값을 변경하는데 문자를 뒤집는 코드

```sh
npx babel app.js --plugins ./mybabelplugin.js
```

> - 커스텀 플러그인이 코드를 받아서 es6를 es5로 변환해보자

```js
module.exports = function myplugin() {
  return {
    visitor: {
      // https://github.com/babel/babel/blob/master/packages/babel-plugin-transform-block-scoping/src/index.js#L26
      VariableDeclaration(path) {
        console.log("VariableDeclaration() kind:", path.node.kind); // const

        if (path.node.kind === "const") {
          path.node.kind = "var";
        }
      },
    },
  };
};
```

> - `path`에 접근해 보면 키워드가 잡히는 걸 알 수 있다
> - `path.node.kind`가 `const` 일 경우 `var`로 변환하는 코드

#### 플러그인 사용하기

> 이러한 결과를 만드는 것이 `block-scoping` 플러그인
>
> - const, let 처럼 블록 스코핑을 따르는 예약어를 함수 스코핑을 사용하는 var 변경

```sh
npx babel app.js --plugins @babel/plugin-transform-block-scoping
```

> 커스텀 플러그인과 같은 결과를 보인다

> 인터넷 익스플로러는 화살표 함수도 지원하지 않는데 `arrow-functions` 플러그인을 이용해서 일반 함수로 변경할 수 있다

```sh

npx babel app.js \
  --plugins @babel/plugin-transform-block-scoping \
  --plugins @babel/plugin-transform-arrow-functions
```

> `ECMAScript5`에서부터 지원하는 엄격 모드를 사용하는 것이 안전하기 때문에 `use strict` 구문을 추가해보자
>
> - `strict-mode` 플러그인을 사용하자