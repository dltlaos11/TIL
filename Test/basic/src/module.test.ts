jest.mock("./module"); // 모듈 파일의 모든 메서드에 spyOn적용,
jest.mock("axios");
import { obj } from "./module";
import axios from "axios";

test("모듈을 전부 모킹", () => {
  // jest.replaceProperty(obj, "prop", "replaced");
  console.log(obj);
});

test("axios를 전부 모킹", () => {
  console.log(axios);
});
