# nodemon
## nodemon 사용계기
기존에는 서버를 실행시키고 변경이 일어나면 자동으로 화면이 반영 되지 않아 서버를 껐다가 다시 재실행시키는 번거러움이 있었지만 nodemon이 해결해주었다.😀
## nodemon?😮
nodemon은 node monitor의 약자로, 노드가 실행하는 파일이 속한 디렉토리를 감시하고 있다가 파일이 수정되면 자동으로 노드 애플리케이션을 재시작하는 확장 모듈이다. <br>
nodemon을 설치하면 재시작 없이 코드를 자동 반영할 수 있다.👍🏿
## nodemon 설치방법
```
npm install nodemon --save-dev // dev를 사용한 이유는 local에서만 사용하기 위함
```
## 실행방법
설치한 이후 ```package.json```을 확인해보면 다른 모듈과 다르게 ```dependencies```가 아닌 ```devDependencies```에 위치해있다. <br> 
nodemon 모듈을 설치하기 전에는 ```npm start```로 서버를 실행하였지만, 아래와 같이
```
"scripts": {
    "start": "node ./src/index.js",
    "dev": "nodemon ./src/index.js" 🟢
  },
```
dev는 임의로 정한거기 떄문에 원하는 변수명을 넣어도 된다. 이제 ```npm run dev```로 실행을 하면 된다. 수정한 파일 변경확인을 위해서는 (ctrl+s)로 확인 가능하다
