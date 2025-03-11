interface Obj {
  name: string;
  getName(): string;
}

function main(obj: Obj) {}

const obj = {
  name: "hello",
  xyx: "abc",
  getName() {
    return this.name;
  },
};
main(obj);
// main({
//     name: "hello",
//     xyx: "abc",
//   })

abstract class AC {
  public hello: string;

  constructor(hello: string) {
    this.hello = hello;
  }
}
// const ac = new AC("world");
const ac: AC = {
  hello: "world",
};

function main2(obj: AC) {}
main2({
  hello: "world",
});

interface Obj2 extends AC {
  acv: string;
} // hello, acv 속성을 가지고 있어야 함

abstract class A {
  //   name: string;
  //   constructor(name: string) {
  //     this.name = name;
  //   }
  constructor(public name: string) {}
  abstract makeSound(): void;
}

class Dog extends A {
  // 추상 메서드를 구현
  constructor(public override name: string) {
    super(name);
  }
  makeSound(): void {
    console.log("Woof! Woof!");
  }
}

abstract class A3 {
  constructor(private readonly name: string) {}
}

interface Printer {
  print(): void;
}

interface Scanner {
  scan(): void;
}
class B implements Printer, Scanner {
  print() {}
  scan() {}
}
// class B2 extends A, AC {
// }

class Printer {
  print() {
    throw new Error("하위 클래스에서 구현");
  }
}
class Scannr {
  scan() {
    throw new Error("하위 클래스에서 구현");
  }
}
class PrinterScaner extends Scannr {
  print() {
    throw new Error("하위 클래스에서 구현");
  }
}
class Z extends PrinterScaner {
  override print() {
    console.log("print");
  }
  override scan() {
    console.log("scan");
  }
}
