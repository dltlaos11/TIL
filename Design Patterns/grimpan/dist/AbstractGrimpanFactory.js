class AbstractGrimpanFactory {
    static createGrimpan() {
        throw new Error("하위 클래스에서 구현하셔야 합니다.");
        // return Grimpan.getInstance() as unknown as Grimpan;
    }
}
export default AbstractGrimpanFactory;
