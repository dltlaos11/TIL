import "./style.css";
import nyancat from "./nyancat.png";

document.addEventListener("DOMContentLoaded", () => {
  document.body.innerHTML = `
        <img src="${nyancat}" />
    `;
});
// document, 브라우저에서 제공하는 DOM의 최상위 객체 중 하나

/*
// file-loader, style,css-loader test
import "./style.css"; 
 */

// import * as math from "./math.js";

// console.log(math.sum(1, 2));

// // sum(1, 2); // 3
// // console.log(sum(1, 2));

// // console.log(math.sum(1, 2));
