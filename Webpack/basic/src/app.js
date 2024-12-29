// import "./style.css";
// import nyancat from "./nyancat.png";
import Axios from "axios";

document.addEventListener("DOMContentLoaded", async () => {
  //   document.body.innerHTML = `
  //         <img src="${nyancat}" />
  //     `;
  const res = await Axios.get("/api/keywords");

  document.body.innerHTML = (res.data || []).map((user) => {
    return `<div>${user.keyword}</div>`;
  });
});
// document, 브라우저에서 제공하는 DOM의 최상위 객체 중 하나
