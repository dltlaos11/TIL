# proxy 수동 설정(setupProxy)🟢
브라우저에서 출처가 다른 즉 host나 port가 다른 백엔드 서버로 API 요청 시 호출할 떄 발생할 수 있는 CORS 관련 오류를 방지하기 위하여 Proxy를 설정하여 준다. <br> 
교차 출처 리소스 공유(CORS)와 관련된 에러는 api 서버 쪽에서 헤더에 Access-Control-Allow-Origin을 열어주지 않는 이상 브라우저단에서 막아버리기 떄문에 클라이언트언트 단에서 해결하는 방법이다. <br>
간단하게 설정하는 방법과 수동으로 커스터마이징 하는 방법이 있다. 
## 첫번째 방법은 package.json을 통한 설정🟣
```javascript
//package.json

{
    ...,
    ...,
    "proxy": "target으로 하는 url 작성"
}
```
## http-proxy-middleware setupProxy.js를 통한 설정🟣
만약 여러가지 api로부터 CORS 처리를 관리하려면 첫번쨰 방법으로 하면 안된다. 일단 package.json에 해당 프록시 설정을 제거하고 http-proxy-middleware 라이브러리를 설치한다.
```javascript
npm install http-proxy-middleware
```
설치가 끝나면 src에 setupProxy.js파일을 하나 생성한다.
```javascript
//setupProxy.js

const { createProxyMiddleware } = require('http-proxy-middleware');

module.exports = function(app){
    app.use(
    "/api",
    createProxyMiddleware("/api", {
      target: "http://210.119.108.237:3000",
      changeOrigin: true,
      pathRewrite: {
        "^/api": "",
      },
    })
  );
  
  app.use(
    createProxyMiddleware('/다른context', {
      target: 'https://다른호스트',
      pathRewrite: {
        '^/지우려는패스':''
      },
      changeOrigin: true
    })
  )
  ...
};
```
'/다른context'로 시작되는 url을 자동으로 인식하여 프록시 처리해주고, '/다른context'라는 path는 pathRewrite에서 설정한 것처럼 제거가 가능하다. <br>
changeOrigin 설정은 http-proxy 모듈의 설명과 같이 대상 서버 구성에 따라 호스트 헤더가 변경되도록 설정해준다.
```javascript
// auth.service.js
import api from "./axios";

const login = (user_id, password) => {
  return api
    .post("api/api/admin/login", {
      user_id,
      password,
    })
    .then((res) => {
      if (res.data.response.jwt_token) {
        localStorage.setItem("user", JSON.stringify(res.data));
      }
      console.log(res);

      return res.data;
    });
};

const authService = {
  login,
};

export default authService;
```
이렇게 위와 같이 호출하여 관리가 가능하다.
