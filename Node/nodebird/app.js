const express = require("express");
const cookieParser = require("cookie-parser");
const morgan = require("morgan"); // req, res logging
const path = require("path"); // node inner module
const session = require("express-session"); // login session
const nunjucks = require("nunjucks"); // template Engine
const dotenv = require("dotenv");
const { sequelize } = require("./models");
const passport = require("passport");

dotenv.config(); // set process.env 사용 가능
const pageRouter = require("./routes/page");

const app = express();
const passportConfig = require("./passport");
app.set("port", process.env.PORT || 8001);
app.set("view engine", "html");
nunjucks.configure("views", {
  express: app,
  watch: true,
}); // nunjucks 통해서 .html 렌더링

sequelize
  .sync({ force: false })
  .then(() => {
    console.log("데이터베이스 연결 성공");
  })
  .catch((err) => {
    console.error(err);
  });
// force: true -> 테이블 재생성, force: false -> 테이블 재생성 안함
// 배포시에는 데이터 손실을 피하기 위해 false 혹은 alter: true 적용

app.use(morgan("dev")); // development: dev, production: combined
app.use(express.static(path.join(__dirname, "public")));
// app.js 기준, lecture/public, 해당 폴더를 static으로 변경
// 정적 파일들(CSS, JavaScript, 이미지 파일 등)을 클라이언트에게 제공할 수 있도록 설정.
// 클라이언트가 해당 파일들을 요청할 때 서버가 직접 파일을 읽고 응답하는 과정을 간소화(보안저긍로 허용)
app.use(express.json()); // json req
app.use(express.urlencoded({ extended: false })); // form req
app.use(cookieParser(process.env.COOKIE_SECRET));
app.use(
  session({
    resave: false,
    saveUninitialized: false,
    secret: process.env.COOKIE_SECRET, // cookieParser와 동일하게
    cookie: {
      httpOnly: true, // js로 접근 불가
      secure: false, // if https -> https
    },
  })
);
app.use(passport.initialize());
app.use(passport.session());

app.use("/", pageRouter);

app.use((req, res, next) => {
  const error = new Error(`${req.method} ${req.url} 라우터가 없습니다.`);
  error.status = 404;
  next(error);
});

app.use((err, req, res, next) => {
  res.locals.message = err.message;
  res.locals.error = process.env.NODE_ENV !== "production" ? err : {};
  // 배포모드가 아니면 에러를 넣어주지만, 배포모드일 때는 에러를 안 넣어줌
  // 에러메시지를 노출안함으로써 보안적으로 좋음
  // 배포모드 일 때는 에러 로그를 서비스에 넘김
  res.status(err.status || 500);
  res.render("error"); // nunjucks가 views폴더안의 파일에 확장자가 .html이기에, 응답으로 보내줌
});

app.listen(app.get("port"), () => {
  console.log(app.get("port"), "번 포트에서 대기중");
});
