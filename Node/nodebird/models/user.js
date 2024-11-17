const Sequelize = require("sequelize");

module.exports = class User extends Sequelize.Model {
  static init(sequelize) {
    return super.init(
      {
        email: {
          type: Sequelize.STRING(40),
          allowNull: true,
          unique: true,
        },
        nick: {
          type: Sequelize.STRING(15),
          allowNull: false,
        },
        password: {
          type: Sequelize.STRING(100),
          allowNull: true,
        },
        provider: {
          type: Sequelize.ENUM("local", "kakao"),
          // email로 로그인하면 local, 카카오로 로그인하면 kakao
          allowNull: false,
          defaultValue: "local",
        },
        snsId: {
          type: Sequelize.STRING(30),
          allowNull: true,
          // validate: {} 저장하기 전에 검사 가능
        },
      },
      {
        sequelize,
        timestamps: true, // createdAt, updatedAt
        underscored: false, // true => created_at, updated_at
        modelName: "User", // for js
        tableName: "users", // for db table
        paranoid: true, // deletedAt 유저 삭제일, soft delete
        charset: "utf8", // 이모티콘 사용하고 싶다면 utf8mb4
        collate: "utf8_general_ci", // 저장된 문자의 정렬 방식
      }
    );
  }

  static associate(db) {
    db.User.hasMany(db.Post);
    db.User.belongsToMany(db.User, {
      foreignKey: "followingId",
      as: "Followers",
      through: "Follow",
    });
    db.User.belongsToMany(db.User, {
      foreignKey: "followerId",
      as: "Followings",
      through: "Follow",
    });
  }
};
