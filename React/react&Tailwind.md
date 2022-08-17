# react&Tailwind Tip
## 사용자 정의 스타일 추가하는 방법
### 테마 사용자 지정
색상 팔레트, 간격 눈금, 타이포그래피 눈금 또는 중단점과 같은 항목을 변경하려면 ```tailwind.config.js``` 파일의 ```theme``` 섹션에 사용자 지정 항목을 추가할 수 있다.
```javascript 
module.exports = {
  theme: {
    screens: {
      sm: '480px',
      md: '768px',
      lg: '976px',
      xl: '1440px',
    },
    colors: {
      'blue': '#1fb6ff',
      'pink': '#ff49db',
      'orange': '#ff7849',
      'green': '#13ce66',
      'gray-dark': '#273444',
      'gray': '#8492a6',
      'gray-light': '#d3dce6',
    },
    width: {
      100: "100px",
      400: "400px",
      760: "760px",
      780: "780px",
      xxx: "원하는 값 설정 가능px"
    },
    fontFamily: {
      sans: ['Graphik', 'sans-serif'],
      serif: ['Merriweather', 'serif'],
    },
    extend: {
      spacing: {
        '128': '32rem',
        '144': '36rem',
      },
      borderRadius: {
        '4xl': '2rem',
      }
    }
  }
}
```
### 임의 값 사용
일반적으로 제한된 디자인 토큰 세트를 사용하여 잘 만들어진 디자인의 대부분을 구축할 수 있지만 때로는 픽셀을 완벽하게 만들기 위해 이러한 제약을 벗어나야 한다. <br>
```top: 117px``` 와 같은 것이 정말로 필요한 경우 Tailwind의 대괄호 표기법을 사용하여 임의의 값을 가진 클래스를 즉석에서 생성할 수 있다.
```javascript
<div class="top-[117px]">
  <!-- ... -->
</div>
```
배경색, 글꼴 크기, 유사 요소 콘텐츠 등을 포함하여 프레임워크의 모든 것에 대해 작동한다.
```javascript
<div class="bg-[#bada55] text-[22px] before:content-['Festivus']">
  <!-- ... -->
</div>
```
### Arbitrary(변덕스런) properties
Tailwind에 즉시 사용할 수 있는 유틸리티가 포함되어 있지 않은 CSS 속성을 사용해야 하는 경우 대괄호 표기법을 사용하여 완전히 임의의 CSS를 작성할 수도 있다.
```javascript
<div class="[mask-type:luminance]">
  <!-- ... -->
</div>
```
## string 형태의 html을 렌더링하기, newline(\n) 을 BR 태그로 변환하기
### dangerouslySetInnerHTML
React 매뉴얼의 ```Dangerously Set innerHTML``` 페이지에 따르면, React에서는 cross-site scripting (XSS) 공격을 막기 위하여, 렌더링 메소드 내부에서 html 태그가 담겨있는 string 형태를 렌더링하면, 태그가 안 먹히고 문자열 그대로 렌더링되게 됩니다
<br>
React가 경고했음에도 불구하고, 쌩까고 하는 방법이 있습니다. 바로 ```dangerouslySetInnerHTML``` 이다.
```javascript
class App extends React.Component {

  render() {
  let codes = "<b>Will This Work?</b>";
    return (
      <div dangerouslySetInnerHTML={ {__html: codes} }>
      </div>
    );
  }
};

ReactDOM.render(
  <App></App>,
  document.getElementById("root")
);
```
### 더 괜찮은 트릭
문자열을 ‘\n’ 으로 split 하면 각 line이 있는 배열이 생성되고 그 배열을 사용하여 매핑 기능을 통하여 컴포넌트 배열을 새로 생성후 렌더링하면 해결된다.
```javascript
class App extends React.Component {

  
  render() {
    let data = "Try\nenter\nenter\nenter";
    return (
      <div>
        <p>Won't work:</p> 
        {data.replace(/\n/g, '<br/>')} // 정규표현식
        <p>This works</p>
        { 
          data.split('\n').map( line => {
            return (<span>{line}<br/></span>)
          })
        }
      </div>
    );
  }
};

ReactDOM.render(
  <App></App>,
  document.getElementById("root")
);
```
