const GRIMPAN_CONSTRUCTOR_SYMBOL = Symbol();

Symbol("abc") === Symbol("abc"); // false

class Grimpan {
  static instance;
  constructor(canvas, symbol) {
    if (symbol !== GRIMPAN_CONSTRUCTOR_SYMBOL) {
      throw new Error("canvas 엘리멘트를 입력하세요");
    }
    if (!canvas || !(canvas instanceof HTMLCanvasElement)) {
      throw new Error("canvas 엘리멘트를 입력하세요");
    }
  }
  initialize() {}
  initializeMenu() {}
  static getInstacne() {
    if (!this.instance) {
      this.instance = new Grimpan(
        document.querySelector("#canvas"),
        GRIMPAN_CONSTRUCTOR_SYMBOL
      );
    }
    return this.instance;
  }
}
export default Grimpan;
