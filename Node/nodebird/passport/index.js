const passport = require("passport");
const local = require("./localStrategy");
const kakao = require("./kakaoStrategy");
const User = require("../models/user");

module.exports = () => {
  passport.serializeUser((user, done) => {
    // user === exUesr
    done(null, user.id);
  });
  // {세션쿠키: 유저아이디} => 메모리에 저장

  passport.deserializeUser((id, done) => {
    User.findOne({ where: { id } })
      .then((user) => done(null, user)) // req.user, req.session
      // connect.sid 쿠키로 세션에서 찾을 때 req.session 생성
      .catch((err) => done(err));
  });

  local();
  kakao();
};
