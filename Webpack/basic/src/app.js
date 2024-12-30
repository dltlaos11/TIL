import "./style.css";
// import nyancat from "./nyancat.png";
import Axios from "axios";
import model from "./model";
import form from "./form";

document.addEventListener("DOMContentLoaded", async () => {
  const formEl = document.createElement("div");
  formEl.innerHTML = form.render();
  document.body.appendChild(formEl);

  //   const res = await Axios.get("/api/keywords");
  const res = await model.get();

  const keywordsContainer = document.createElement("div");
  keywordsContainer.innerHTML = (res || []).map((user) => {
    return `<div>${user.keyword}</div>`;
  });

  document.body.appendChild(keywordsContainer);
});
// document, 브라우저에서 제공하는 DOM의 최상위 객체 중 하나

if (module.hot) {
  console.log("hot module open");

  module.hot.accept("./model", async () => {
    console.log("accept");
    await model.get();
  });
}
