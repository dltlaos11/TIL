class Grimpan {
  private static instance: Grimpan;
  private constructor(canvas: HTMLElement | null) {
    if (!canvas || !(canvas instanceof HTMLCanvasElement)) {
      throw new Error("canvas 엘리멘트를 입력하세요");
    }
  }

  initialize() {}
  initializeMenu() {}

  static getInstacne() {
    if (!this.instance) {
      this.instance = new Grimpan(document.querySelector("#canvas"));
    }
    return this.instance;
  }
}

export default Grimpan;
