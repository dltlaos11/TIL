import Grimpan from "./AbstractGrimpan";

abstract class AbstractGrimpanFactory {
  static createGrimpan(): Grimpan {
    throw new Error("하위 클래스에서 구현하셔야 합니다.");
    // return Grimpan.getInstance() as unknown as Grimpan;
  }
}

export default AbstractGrimpanFactory;
