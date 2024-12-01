// function sum(a, b) {
//   return a + b;
// } // 전역 공간에 sum이 노출

// var math = math || {}; // math 네임스페이스

// (function () {
//   function sum(a, b) {
//     return a + b;
//   }
//   math.sum = sum; // 네이스페이스에 추가
// })();

export function sum(a, b) {
  return a + b;
}
