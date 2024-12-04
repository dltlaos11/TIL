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
