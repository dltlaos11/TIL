const Sequelize = require("sequelize");
const env = process.env.NODE_ENV || "development";
const fs = require("fs");
const path = require("path");
const config = require("../config/config")[env];

const db = {};
const sequelize = new Sequelize(
  config.database,
  config.username,
  config.password,
  config
);

db.sequelize = sequelize;

const basename = path.basename(__filename); // index.js, 절대경로
// process.cwd() : 현재 프로세스가 실행되는 위치, '/Users/okpanda/git/TIL/Node/nodebird'
// path.basename(process.cwd()): nodebird

fs.readdirSync(__dirname) // 현재 폴더의 모든 파일을 조회
  .filter((file) => {
    // 숨김 파일, 테스트 파일, index.js, js 확장자가 아닌 파일 필터링
    return (
      file.indexOf(".") !== 0 &&
      !file.includes("test") &&
      file !== basename &&
      file.slice(-3) === ".js"
    );
  })
  .forEach((file) => {
    // 해당 파일의 모델 불러와서 init
    const model = require(path.join(__dirname, file)); // cjs
    console.log(file, model.name);
    db[model.name] = model;
    model.init(sequelize);
  });

Object.keys(db).forEach((modelName) => {
  // associate 호출
  if (db[modelName].associate) {
    db[modelName].associate(db);
  }
});

module.exports = db;
