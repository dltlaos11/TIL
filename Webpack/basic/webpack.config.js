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
      // {
      //   test: /\.(jpeg|png|gif|svg)$/, // .jpeg 확장자로 마치는 모든 파일
      //   loader: "file-loader", // 파일 로더를 적용한다
      //   options: {
      //     publicPath: "./dist/", // prefix를 아웃풋 경로로 지정
      //     name: "[name].[ext]?[hash]", // 파일명 형식, 캐시 무력화를 위한 해시 값 사용
      //     // e.g.) ./dist/bg.jpeg?ffb0298fbaec30f9528f8f5fb1f12bde
      //   },
      // },
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
    ],
  },
};
