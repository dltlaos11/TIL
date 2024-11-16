exports.renderProfile = (req, res) => {
  // 서비스를 호출
  res.render("profile", { title: "내 정보 - NodeBird" });
};

exports.renderJoin = (req, res) => {
  res.render("join", { title: "회원가입 - NodeBird" });
};

exports.renderMain = (req, res, next) => {
  const twits = [];
  res.render("main", {
    title: "NodeBird",
    twits,
  });
};

// 라우터 -> 컨트롤러 -> 서비스
// 1. 컨트롤러는 요청과 응답이 뭔지 알지만
// 2. 서비스는 요청과 응답을 모름
// 계층적 호출, [라우터 컨트롤러 서비스],
