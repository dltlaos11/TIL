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
  module: {
    rules: [
      // {
      //   test: /\.js$/, // .js 확장자로 끝나는 모든 파일
      //   use: [path.resolve("./myloader.js")], // 방금 만든 로더를 적용한다
      // },
      {
        test: /\.css$/, // .css 확장자로 끝나는 모든 파일
        use: ["style-loader", "css-loader"], // 방금 만든 로더를 적용한다
      },
    ],
  },
};
