const express = require("express");
const {
  renderProfile,
  renderJoin,
  renderMain,
} = require("../controllers/page");
// 라우터의 마지막 미들웨어를 컨트롤러

const router = express.Router();

router.use((req, res, next) => {
  res.locals.user = null;
  res.locals.followerCount = 0;
  res.locals.followingCount = 0;
  res.locals.followingIdList = [];
  next(); // 미들웨어끼리 넥스트를 통해서 다음 미들웨어로 넘어감
  // next없으면 아래 라우터 실행 안됨
});
// res.locals: 라우터에서 공통적으로 쓸 수 있는 변수

router.get("/profile", renderProfile);

router.get("/join", renderJoin);

router.get("/", renderMain);

module.exports = router;
