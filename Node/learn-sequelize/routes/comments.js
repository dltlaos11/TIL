const express = require("express");
const { Comment, User } = require("../models");

const router = express.Router();

router.post("/", async (req, res, next) => {
  try {
    // const comment = await Comment.create({
    //   commenter: req.body.id,
    //   comment: req.body.comment,
    // });
    // console.log(comment);
    // res.status(201).json(comment);
    const user = await User.findone({ where: { id: req.body.id } });
    const comment = await Comment.create({
      comment: req.body.comment,
    });
    const userComment = await user.addComment(comment);
    console.log(comment);
    res.status(201).json(userComment);
  } catch (err) {
    console.error(err);
    next(err);
  }
});

router
  .route("/:id")
  .patch(async (req, res, next) => {
    try {
      const result = await Comment.update(
        {
          comment: req.body.comment,
        },
        {
          where: { id: req.params.id },
        }
      );
      res.json(result);
    } catch (err) {
      console.error(err);
      next(err);
    }
  })
  .delete(async (req, res, next) => {
    try {
      const result = await Comment.destroy({ where: { id: req.params.id } });
      res.json(result);
    } catch (err) {
      console.error(err);
      next(err);
    }
  });

module.exports = router;
