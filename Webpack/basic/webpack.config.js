const path = require("path");
// const MyWebpackPlugin = require("./myplugin");
const webpack = require("webpack");
const banner = require("./banner.js");
const HtmlWebpackPlugin = require("html-webpack-plugin");
const { CleanWebpackPlugin } = require("clean-webpack-plugin");
const MiniCssExtractPlugin = require("mini-css-extract-plugin");
const apiMocker = require("connect-api-mocker");
const OptimizeCSSAssetsPlugin = require("optimize-css-assets-webpack-plugin");
const TerserPlugin = require("terser-webpack-plugin");
const CopyPlugin = require("copy-webpack-plugin");

const mode = process.env.NODE_ENV || "development"; // 기본값을 development로 설정

module.exports = {
  // mode: "development",
  mode,
  optimization: {
    minimizer:
      mode === "production"
        ? [
            new OptimizeCSSAssetsPlugin(),
            new TerserPlugin({
              terserOptions: {
                compress: {
                  drop_console: true, // 콘솔 로그를 제거한다
                },
              },
            }),
          ]
        : [],
    splitChunks: {
      chunks: "all",
    },
  }, // 최적화 옵션
  externals: {
    axios: "axios",
  },
  entry: {
    main: "./src/app.js",
    model: "./src/model.js",
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
        use: [
          process.env.NODE_ENV === "production"
            ? MiniCssExtractPlugin.loader // 프로덕션 환경
            : "style-loader", // 개발 환경
          "css-loader",
        ],
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
            // publicPath: "./dist/", // file-loader와 동일
            name: "[name].[ext]?[hash]", // file-loader와 동일
            limit: 20000, // 20kb 미만 파일만 data url로 처리
          },
        },
      },
      {
        test: /\.js$/,
        exclude: /node_modules/,
        loader: "babel-loader", // 바벨 로더를 추가
      },
    ],
  },
  plugins: [
    new webpack.BannerPlugin(banner),
    new webpack.DefinePlugin({}),
    new HtmlWebpackPlugin({
      template: "./src/index.html", // 템플릿 경로를 지정
      templateParameters: {
        // 템플릿에 주입할 파라매터 변수 지정
        env: process.env.NODE_ENV === "development" ? "(개발용)" : "",
      },
      minify:
        process.env.NODE_ENV === "production"
          ? {
              collapseWhitespace: true, // 빈칸 제거
              removeComments: true, // 주석 제거
            }
          : false,
      hash: true, // 정적 파일을 불러올때 쿼리문자열에 웹팩 해쉬값을 추가한다
    }),
    new CleanWebpackPlugin(),
    ...(process.env.NODE_ENV === "production"
      ? [new MiniCssExtractPlugin({ filename: `[name].css` })]
      : []),
    new CopyPlugin([
      {
        from: "./node_modules/axios/dist/axios.min.js",
        to: "./axios.min.js", // 목적지 파일에 들어간다
      },
    ]),
  ],
  devServer: {
    overlay: true,
    stats: "errors-only",
    before: (app, server, compiler) => {
      // app.get("/api/keywords", (req, res) => {
      //   res.json([
      //     { keyword: "이탈리아" },
      //     { keyword: "세프의요리" },
      //     { keyword: "제철" },
      //     { keyword: "홈파티" },
      //   ]);
      // });
      app.use(apiMocker("/api", "mocks/api"));
    },
    proxy: {
      "/api": "http://localhost:8081", // 프록시
    },
    hot: true,
  },
};
