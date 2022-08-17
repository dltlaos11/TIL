# styled-components & Tailwind
## JavaScript - 여러 줄 문자열, 3가지 방법
### +로 여러 문자열 연결
### Backslash(\)를 이용하여 여러 줄 문자열 작성
### Backtick(``` ` ```)을 사용하여 여러 줄 문자열 작성
## styled-components란?😮
기존 돔을 만드는 방식인 css, scss파일을 밖에 두고, 태그나 id, class이름으로 가져와 쓰지 않고, 동일한 컴포넌트에서 컴포넌트 이름을 쓰듯 스타일을 지정하는 것을 styled-components라고 부른다. <br>
css 파일을 밖에 두지 않고, 컴포넌트 내부에 넣기 때문에, css가 전역으로 중첩되지 않도록 만들어주는 장점이 있다.
### 환경설정⚙️
```javascript
npm install styled-components
```
### 예시🟢
```javascript
import React, { useState } from "react";
import styled from "styled-components";

function Example() {
  const [email, setEmail] = useState("");

  return (
    <ExampleWrap active={email.length}>
      <Button>Hello</Button>
      <NewButton color="blue">Im new Button</NewButton>
    </ExampleWrap>
  );
}

const ExampleWrap = styled.div`
  background: ${({ active }) => {
    if (active) {
      return "white";
    }
    return "#eee";
  }};
  color: black;
`;

const Button = styled.button`
  width: 200px;
  padding: 30px;
`;

// Button 컴포넌트 상속
const NewButton = styled.Button`
  // NewButton 컴포넌트에 color가는 props가 있으면 그 값 사용, 없으면 'red' 사용
  color: ${props => props.color || "red"};
`;

export default Example;
```
### styled-components 만들기
- ```const 컴포넌트명 = styled.태그명`스타일넣기` ``` 문법으로 만들어진다.
- 만들고자하는 컴포넌트의 render 함수 밖에서 만든다.

### 스타일에 props 적용하기
- styled-components를 사용하는 장점 중 하나가 변수에 의해 스타일을 바꿀 수 있다는 점이다.
- 위 예시를 보면 ```email``` 이라는 state값에 따라 ```ExampleWrap``` 에 prop으로 내려준 ```active```라는 값이 ```true``` or ```false``` 로 바뀌게 된다.
- styled-component는 내부적으로 props를 받을 수 있고, 그 props에 따라 스타일을 변경할 수 있다.

## Mixin css props
- css props는 자주 쓰는 css 속성을 담는 변수이다.
- ```const 변수명 = css`스타일` ``` 로 사용
```javascript
const flexCenter = css`
  display: flex;
  justify-content: center;
  align-items: center;
`;

const FlexBox = div`
  ${flexCenter}
`;
```
참고: https://kyounghwan01.github.io/blog/React/styled-components/basic/#%E1%84%89%E1%85%B3%E1%84%90%E1%85%A1%E1%84%8B%E1%85%B5%E1%86%AF-%E1%84%89%E1%85%A1%E1%86%BC%E1%84%89%E1%85%A9%E1%86%A8

## tailwind-styled-component🟣
### 환경설정
```javascript
npm i -D tailwind-styled-components
import tw from "tailwind-styled-components" // 파일에서 적용
```
## 예시
```javascript
const Survey = () => {
  let data =
    "내용\n내용\n내용\n내용\n내용\n내용\n내용\n내용\n내용\n내용\n내용\n내용\n내용\n내용\n내용\n내용\n내용\n내용\n내용\n내용\n내용\n내용\n내용\n내용\n내용\n내용\n내용\n내용\n내용\n내용\n내용\n내용\n내용\n내용\n내용\n \
    내용\n내용\n내용\n내용\n내용\n내용\n내용\n내용\n내용\n내용\n내용\n내용\n내용\n내용\n내용\n내용\n내용\n내용\n내용\n내용\n내용\n내용\n내용\n내용\n내용\n내용\n내용\n내용\n내용\n내용\n내용\n내용\n내용\n내용\n내용";
  const Circle = tw.div`
    w-100
    h-100
    bg-black
    text-white
  `;
  return (
    <>
      <div className="relative min-h-[1000px]">
        <p>This works</p>
        {data.split("\n").map((line) => {
          return (
            <span>
              {line}
              <br />
            </span>
          );
        })}
      </div>
      <Circle>One</Circle>
    </>
  );
};
```
