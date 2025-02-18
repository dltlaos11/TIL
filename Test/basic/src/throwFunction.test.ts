import { error, customeError, CustomError } from "./throwFunction";

test("error가 잘 난다", () => {
  expect(() => error()).toThrow(Error);
  expect(() => customeError()).toThrow(CustomError);
  // expect(customeError()).toThrow(CustomError); ❌, 함수로 감싸서 실행을 해줘야 () => customeError()
});

test("error가 잘 난다(try/catch)", () => {
  try {
    error();
  } catch (err) {
    expect(err).toStrictEqual(new Error()); // toThrow가 아니라 toStrictEqual. err은 객체
  }
});
