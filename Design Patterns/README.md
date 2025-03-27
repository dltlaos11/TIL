# Design Patterns

> [GoF](https://www.google.com/search?kgmid=/m/0b21p&hl=en-KR&q=Design+Patterns:+Elements+of+Reusable+Object-Oriented+Software&shndl=17&source=sh/x/kp/osrp/m5/1&kgs=302e1553e9b16cac) 책에 나오는 23가지 디자인 패턴과 그 외의 디자인 패턴을 JavaScript/TypeScript에 맞게 공부하는 REPO

## UML

> 클래스 간의 관계를 설명하는 다이어그램
>
> - `-`: `private` or `protected`
> - `+`: `public`
> - 실선은 class의 속성, 점선의 경우 속성이 아닌 다른 연결 관계
> - 실선의 빈 화살표는 상속(`extends`) 관계
>   > - 코드 재사용, 일관성
>   > - 단일 상속, 강한 결합( => 단점)
> - 점선의 빈 화살표는 구현(`implements`) 관계
>   > - interface를 implements하면 안의 인터페이스에 선언된 모든 메서드를 구현해야
>   > - 유연성, 약한 결합
>   > - `런타임(동적) 다형성`은 인터페이스에 정의된 메서드를 오버라이드하여 자신의 방식으로 구현됨. 실행 시점에 어떤 클래스의 객체를 참조하느냐에 따라 호출되는 메서드가 결정
>   > - `컴파일(정적) 다형성`은 주로 메서드 오버로딩과 관련이 있으며 컴파일 시점에 호출될 메서드가 결정됨
>   >   > - 인터페이스를 통해 다형성을 구현하면, 코드의 유연성과 확장성이 크게 향상된다. 인터페이스를 사용하면 다양한 객체를 같은 방식으로 다룰 수 있어, 코드의 일관성과 재사용성을 높일 수 있다.
>   > - 구현 강제( => 단점)
> - 밑 줄은 클래스의 static 속성
> - 다이몬드 화살표는 집합(약 결합), 합성(강 결합)의 관계, 다이아있는 쪽이 주체

## 프로젝트 세팅

> - index.ts -> compile js
> - npm init -y
> - npm i typescript
> - npx tsc --init -> tsconfig.json
>   > - "target": "es2023" -> 최신 버전 문법
>   > - "module": "ES2022" -> 브라우저 최신버전 js모듈 사용
>   > - "noImplicitOverride": true -> override 키워드
>   > - "outDir": "./dist"
> - npx tsc --watch -> 자동으로 컴파일

## 사전에 알아두면 좋은 TS/JS 지식

> 추상 클래스, 인터페이스, 구조적 타이핑
>
> ```ts
> interface Obj {
>   name: string;
>   getName(): string;
> }
>
> function main(obj: Obj) {}
>
> const obj = {
>   name: "hello",
>   xyx: "abc",
>   getName() {
>     return this.name;
>   },
> };
> main(obj);
> // main({
> //     name: "hello",
> //     xyx: "abc",
> //   })
> ```
>
> - 객체 리터럴을 그 자체로 넣으면 에러가 나는데 변수를 넣으면 에러가 발생하지 않음
>   > - 잉여 속성 검사(Excess Property Checks)의 특성
>   > - 객체 리터럴은 잉여 속성 검사를 하고 변수는 잉여 속성 검사를 하지 않음 ✅
> - interface의 속성은 모두 갖고있어야
> - interface에선 private, protected가 안돼고 public이라 생각하면 됨
>   > - 쓰고 싶다면 `추상 클래스`를 사용해야 함
>
> ```ts
> abstract class AC {
>   public hello: string;
>
>   constructor(hello: string) {
>     this.hello = hello;
>   }
> }
> // const ac = new AC("world");
> const ac: AC = {
>   hello: "world",
> };
>
> function main2(obj: AC) {}
> main2({
>   hello: "world",
> });
> ```
>
> - class인데 new를 통해 선언하지 않고 객체 리터럴만 넣어도 대입이 가능
>   > - Java와 다른 주요한 Ts의 특징
> - Ts에서는 객체가 클래스(`생성자`)든 `객체 리터럴`이든 상관없이 모양이 똑같으면 같은 타입으로 친다
>   > - 구조적 타이핑 혹은 덕 타이핑(Duck Typing)이라고 부름
>   > - Java에서는 명목적 타이핑(Nominal Typing)이라고 해서 반드시 같은 클래스여야 하지만 Ts에서는 구조적 타이핑이라는 특성 때문에 모양만 똑같으면 class든 interface든 같은 타입으로 취함 ✅
>
> ```ts
> abstract class AC {
>   public hello: string;
>
>   constructor(hello: string) {
>     this.hello = hello;
>   }
> }
> interface Obj2 {
>   hello: string;
> }
> interface Obj3 extends AC {
>   acv: string;
> } // hello, acv 속성을 가지고 있어야 함
> ```
>
> - Obj2와 AC는 같은 타입(구조적 타이핑)
> - interface는 extends로 확장 가능
>
> 다른 언어에서는 인터페이스를 선언한 다음에 클래스에서 implements하는데 Ts에선 인터페이스를 선언하지 않는 경우가 많다
>
> > - 구조적 타이핑이라는 특성 때문에 굳이 인터페이스를 따로 선언하지 않고 추상 클래스로도 인터페이스 선언이 가능
> >   > - 추상 클래스를 사용하면 `로직`을 안에 넣을 수 있다 ✅
> >   > - 추상 클래스는 js로 컴파일되면 class로 변환됨
>
> ```ts
> abstract class A {
>   name: string;
>   constructor(name: string) {
>     this.name = name;
>   }
> }
> abstract class A2 {
>   constructor(public name: string) {
>     // this.name = name;
>   }
> }
>
> abstract class A3 {
>   constructor(private readonly name: string) {}
> }
> ```
>
> - A2처럼 1줄로 선언하면 A의 3줄의 코드와 동일
>
> ```ts
> interface Printer {
>   print(): void;
> }
>
> interface Scanner {
>   scan(): void;
> }
> class B implements Printer, Scanner {
>   print() {}
>   scan() {}
> }
> class B2 extends A, AC {} // ❌
> ```
>
> - SOLID의 ISP원칙
> - 추상 클래스는 다중 상속이 안됨
>   > - Js, Ts는 하나의 클래스만 상속할 수 있는 단일 상속 언어
>   > - 추상 클래스를 쓰되, 다중 구현이 필요한 경우에만 인터페이스 사용 ⭕
>
> ```ts
> abstract class A {
>   //   name: string;
>   //   constructor(name: string) {
>   //     this.name = name;
>   //   }
>   constructor(public name: string) {}
>   abstract makeSound(): void;
> }
>
> class Dog extends A {
>   // 추상 메서드를 구현
>   constructor(public override name: string) {
>     super(name);
>   }
>   makeSound(): void {
>     console.log("Woof! Woof!");
>   }
> }
> ```
>
> > - 추상 클래스의 서브클래스는 추상 메서드만 구현하면 되고, 일반 메서드는 필요에 따라 재정의
>
> ts에서 interface가 js로 컴파일되면서 interface는 사라지게 되는데, 다중 구현을 한 경우라면 아래와 같이 변환됨.
>
> ```ts
> interface Printer {
>   print(): void;
> }
>
> interface Scanner {
>   scan(): void;
> }
> class B implements Printer, Scanner {
>   print() {}
>   scan() {}
> }
> // js로 컴파일 되는 경우 💾
> class Printer {
>   print() {
>     throw new Error("하위 클래스에서 구현");
>   }
> }
> class Scannr {
>   scan() {
>     throw new Error("하위 클래스에서 구현");
>   }
> }
> class PrinterScaner extends Scannr {
>   print() {
>     throw new Error("하위 클래스에서 구현");
>   }
> }
> class Z extends PrinterScaner {
>   override print() {
>     console.log("print");
>   }
>   override scan() {
>     console.log("scan");
>   }
> }
> ```

## 객체를 생성할 때 사용할 수 있는 다양한 생성 패턴(Creational Pattern)

> 디자인 패턴은 크게 3가지 분류로 나뉨
>
> > - 생성(Creational), 행동(Behavioral), 구조(Structural) 패턴

### 싱글턴(Singleton) - 앱 내에서 단 하나만 존재해야 할 때

> 하나의 인스턴스만 존재함을 보장
>
> - 생성자도 private으로(자바스크립트에서는 symbol 사용해서 생성자 호출 막기)
> - 단일 책임 원칙 위반!
> - 강결합으로 인해 테스트하기 어려움
>
> ```ts
> let instance: Grimpan;
> class Grimpan {
>   constructor(canvas: HTMLElement | null) {
>     if (!canvas || !(canvas instanceof HTMLCanvasElement)) {
>       throw new Error("canvas 엘리멘트를 입력하세요");
>     }
>
>     if (instance) {
>       instance = this;
>     }
>     return instance;
>   }
>
>   initialize() {}
>   initializeMenu() {}
> }
>
> const g1 = new Grimpan(document.querySelector("#canvas"));
> const g2 = new Grimpan(document.querySelector("#canvas"));
> console.log(g1 === g2); // true
> ```
>
> - instance를 밖에서 선언하면 new를 통해 선언하여도 하나의 객체 공유가 가능하긴 함
>   > - 좋은 방법은 아님 instance가 클래스 안에 존재하지 않음
>
> ```ts
> class Grimpan {
> constructor(canvas: HTMLElement | null) {
> if (!canvas || !(canvas instanceof HTMLCanvasElement)) {
>   throw new Error("canvas 엘리멘트를 입력하세요");
>  }
> }
>
> initialize() {}
>  initializeMenu() {}
> }
>
> export default new Grimpan(document.querySelector("#canvas"));
> // Grimpan을 인스턴스화해서 export
> ...
> import g1 from "./grimpan.js";
> import g2 from "./grimpan.js";
>
> console.log(g1 === g2); // true
> ```
>
> - browser에서 import할 때는 .js 확장자를 붙여야 한다.
>   > - `<script type="module" src="./dist/index.js">` module타입을 쓰고 있기에 브라우저 기본 모듈에서 동작
> - js 모듈은 기본적으로 싱글톤
>
> ```ts
> class Grimpan {
> private static instance: Grimpan;
>  private constructor(canvas: HTMLElement | null) {
>  if (!canvas || !(canvas instanceof HTMLCanvasElement)) {
>      throw new Error("canvas 엘리멘트를 입력하세요");
>   }
>  }
>
> initialize() {}
> initializeMenu() {}
>
> static getInstacne() {
>    if (!this.instance) {
>     this.instance = new Grimpan(document.querySelector("#canvas"));
>   }
>    return this.instance;
> }
> }
>
> export default Grimpan;
> ...
> import Grimpan from "./grimpan.js";
>
> console.log(Grimpan.getInstacne() === Grimpan.getInstacne());
> // new Grimpan(document.getElementById('canvas')) ❌
> ```
>
> - 싱글턴 코드, 어떤 객체가 있는데 그 객체가 반드시 하나만 생성이 돼어야 한다.
> - 외부에서 접근이 가능해야함. -> user가 Grimpan에 접근할 수 있어야하고 접근을 하면 항상 같은 그림판 단 하나의 객체를 바라봄
> - private constructor로 새로운 객체 생성 방지
>
> 싱글톤 패턴은 객체가 하나만 생성됨을 보장하는 장점이 있지만, 단점도 존재.
>
> > - private 메서드들이나 instance라서 테스트하기가 어렵다.
> >   > - private constructor를 유닛 테스트하려고 하면 getInstance를 하고 new를 호출해서 간접접으로 테스트할 수 있는데 private메서드로 인해 한계가 존재
> > - getInstance 메서드가 SRP 원칙을 위반한다는 얘기가 있음
> >   > - 어떤 함수나 메서드, 클래스는 하나의 책임만 가져야 함. -> `변경의 이유가 하나 뿐이어야 한다.`
> >   > - getInstance함수는 `Grimpan의 생성`과 `하나인 것을 보장`하는 2가지의 역할을 수행하고 있는것
> > - 또 하나의 단점으로는 호출하는 과정에서 강결합이 생길 수 있다.
>
> ```ts
> import Grimpan from "./grimpan.js";
>
> function main() {
>   Grimpan.getInstacne().initialize();
> }
> main();
> ```
>
>  <img src="https://private-user-images.githubusercontent.com/10962668/387730235-e81c7f9d-53e7-4b42-ab17-732734c6cbae.png?jwt=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJnaXRodWIuY29tIiwiYXVkIjoicmF3LmdpdGh1YnVzZXJjb250ZW50LmNvbSIsImtleSI6ImtleTUiLCJleHAiOjE3NDIxMDczNDEsIm5iZiI6MTc0MjEwNzA0MSwicGF0aCI6Ii8xMDk2MjY2OC8zODc3MzAyMzUtZTgxYzdmOWQtNTNlNy00YjQyLWFiMTctNzMyNzM0YzZjYmFlLnBuZz9YLUFtei1BbGdvcml0aG09QVdTNC1ITUFDLVNIQTI1NiZYLUFtei1DcmVkZW50aWFsPUFLSUFWQ09EWUxTQTUzUFFLNFpBJTJGMjAyNTAzMTYlMkZ1cy1lYXN0LTElMkZzMyUyRmF3czRfcmVxdWVzdCZYLUFtei1EYXRlPTIwMjUwMzE2VDA2MzcyMVomWC1BbXotRXhwaXJlcz0zMDAmWC1BbXotU2lnbmF0dXJlPTlmOGZlMGRlNTQzYTExMmJjNzEzYzY5YTRmNDc4MGQxMDY1NzQzZjEwOTdkMzhjNzc0YmVjY2M5MDQwOGZkZGQmWC1BbXotU2lnbmVkSGVhZGVycz1ob3N0In0.tzPw4lpSq8NhtPP0y6YUCQKJ_weyveWIA5dmAB6E1Ak" />
>
> - main함수와 Grimpan 객체가 강하게 결합되어 있는 상태
>
> ```ts
> import Grimpan from "./grimpan.js";
> import Editor from "./editor.js";
>
> function main(instance: any) {
>   instance.initialize();
> }
> main(Grimpan.getInstacne());
> // main(TestGrimpan.getInstacne()); for Test
> main(Editor.getInstacne());
> ```
>
> - 약결합 상태
> - main을 다양하게 재사용 가능 -> 약결합의 장점
> - 매개변수로 뽑던지 constructor에서 this의 속성으로 넣던지
> - 인스턴스를 외부에서 주입 받는것 -> Dependency Injection 패턴
>   > - 약결합은 테스트하기에도 용이
> - 싱글톤은 보통 강결합이 되는 경우가 많음 -> main과 Grimpan의 강결합, main의 재사용 ❌
>
> ```js
> const GRIMPAN_CONSTRUCTOR_SYMBOL = Symbol();
>
> Symbol("abc") === Symbol("abc"); // false
>
> class Grimpan {
>   static instance;
>   constructor(canvas, symbol) {
>     if (symbol !== GRIMPAN_CONSTRUCTOR_SYMBOL) {
>       throw new Error("canvas 엘리멘트를 입력하세요");
>     }
>     if (!canvas || !(canvas instanceof HTMLCanvasElement)) {
>       throw new Error("canvas 엘리멘트를 입력하세요");
>     }
>   }
>   initialize() {}
>   initializeMenu() {}
>   static getInstacne() {
>     if (!this.instance) {
>       this.instance = new Grimpan(
>         document.querySelector("#canvas"),
>         GRIMPAN_CONSTRUCTOR_SYMBOL
>       );
>     }
>     return this.instance;
>   }
> }
> export default Grimpan;
> ```
>
> - js에서 private constructor를 Symbol를 통해 구현

### SOLID 원칙

> `Single Responsibility Principle(SRP)`
>
> - 단일 책임 원칙
>
> > - 한 객체는 하나의 책임만 가져야 한다
> > - 책임 = 변경의 이유
> > - 객체가 너무 많아지므로 지키지 않는 경우도 많음
>
> `Open Closed Principle(OCP)`
>
> - 개방 폐쇄 원칙
>
> > - 확장에 대해서는 열려 있고, 변경에 대해서는 닫혀 있어야 한다.
> > - 새로운 기능을 추가할 때 기존 코드가 수정되면 안 된다.
>
> ```ts
> function main(type) {
>   if (type === "a") {
>     doA();
>   } else if (type === "b") {
>     doB();
>   } else if (type === "c") {
>     doC();
>   } else {
>   }
> }
> ```
>
> - type d가 추가된다면 기존 코드에 else if문이 추가되면서 기존 코드가 수정됨
>   > - OCP 위반
>
> ```ts
> interface Doable {
>   do(): void;
> }
>
> function main(type: Doable) {
>   type.do();
> }
>
> // class A implements Doable {
> //   do() {}
> // }
> // class B implements Doable {
> //   do() {}
> // }
> const a = { do() {} }; // 객체 리터럴로 생성한 고유한 객체이므로 싱글턴으로 봐도 무방(상속, 다형성은 쓰기 어렵겠지만)
> const b = { do() {} };
> const c = { do() {} };
> const d = { do() {} };
> main(d);
> ```
>
> - d가 추가 될 경우, 기존 코드 `수정없이` 추가 가능 -> 변경에 닫혀있음
> - 확장에는 열려있다 -> 새로운 것은 지속적으로 추가 가능
>
> `Liskov Substitution Principle(LSP)`
>
> - 리스코프 치환 원칙
>
> > - 자식 클래스는 부모 클래스의 역할을 대체할 수 있어야 한다
> > - 부모 클래스의 자리에 자식 클래스를 넣고 타입 에러가 나나 확인해보면 됨
>
> ```ts
> class Animal {
>   isAnimal() {
>     return true;
>   }
> }
>
> class Bird extends Animal {
>   fly() {
>     return "I' can fly";
>   }
>   isBird() {
>     return true;
>   }
> }
> class Penguin extends Bird {
>   override fly() {
>     // ❌
>     throw new Error("I can not fly");
>   }
> }
> console.log(new Bird().fly()); // I can fly
> console.log(new Penguin().fly()); // throw error
> console.log(new Bird().fly().at(1)); // '
> console.log(new Penguin().fly().at(1)); // ❌, Type Error
> ```
>
> - 자식(펭귄)의 클래스에서 fly()를 throw하면 never타입, 부모에서는 string타입
> - 부모의 타입을 자식이 다르게 정의해 버리는 경우 LSP를 위반
> - 부모 클래스를 자식 클래스로 갈아꼈을때 에러가 발생한다면 LSP위반
>   > - 여기서 말하는 에러는 타입에러 ✅
>
> `Interface Segregation Principle(ISP)`
>
> - 인터페이스 분리 원칙
>
> > - 클래스는 자신이 사용하지 않는 인터페이스는 구현하지 말아야 한다
> > - 인터페이스의 단일 책임 원칙
> > - 인터페이스를 쪼개서 여러 개로 만들고, 필요한 만큼 implements
>
> ```ts
> interface Quackable {
>   quack(): string;
> }
> interface Flyable {
>   fly(): string;
> }
> class Bird extends Animal implements Quackable, Flyable {
>   quack() {
>     return "quack";
>   }
>   fly(): string {
>     return "fly";
>   }
>   isBird() {
>     return true;
>   }
> }
> class Penguin extends Bird implements Flyable {
>   override fly() {
>     return "fly";
>   }
> }
> ```
>
> - LSP문제에서 Bird의 fly()를 삭제하면 문제는 해결, 모든 동물이 날 수 있는건 아니기에
> - 인터페이스를 먼저 만들어서 타입 정의 후 구현 순으로 가야
> - `인터페이스 여러 개가 범용 인터페이스 하나보다 낫다`
>
> `Dependency Inversion Principle(DIP)`
>
> - 의존성 역전 원칙, `Dependency Injection(DI)`라고도 부름
>   > - DI와 DIP의 차이는 DIP를 구현하는 방법 중 하나가 DI라는 패턴이라고 보면 됨
>   > - 의존 관계 역전 원칙이 있고 그것을 구현하는 방법 중 하나가 `매개변수나 생성자를 통해서 의존성을 주입받는 하나의 방법`이라고 보면 됨
> - <b>추상화에 의존해야지, 구체화에 의존하면 안된다.</b>
>   > - 추상화: interface, abstract class
>
> ```ts
> interface Doable {
>   do(): void;
> }
>
> function main(type: Doable) {
>   type.do();
> }
> ```
>
> - interface를 매개변수로 받아서 해당 interface의 do를 사용하는 방식이 DIP의 한 종류
>
> > - 추상성이 높은 클래스와 의존 관계를 맺는다
> > - 상속 대신 합성을 하자
> > - interface, abstract class를 매개변수로 받자
>
> ```ts
> import Grimpan from "./grimpan.js";
>
> function main() {
>   Grimpan.getInstacne().initialize();
> }
> main(); // ❌ 강결합 지양
> ```
>
> ```ts
> export abstract class AGrimpan{}
> class Grimpan extends AGrimpan{} // 구체화된 그림판이 아니라 추상적인 그림판 type을 매개변수의 타입을 받음
> ...
> import Grimpan from "./grimpan.js";
> import Editor from "./editor.js";
>
> function main(instance: AGrimpan) {
>   instance.initialize();
> }
> main(Grimpan.getInstacne());
> main(Editor.getInstacne()); // ⭕ 약결합 지향, DI 패턴
> ```
>
> - 강결합 된게 아니라 DI를 통해서 함수를 호출하는 쪽에서 필요로 하는것을 알아서 바꿔 쓸수 있게끔 해주는게 의존 관계 역전 법칙
> - <b>매개변수나 생성자를 통해서 외부 객체를 주입받고 외부 객체의 타입을 `interface, abstract class`로 하는 것</b>은 `의존관계역전법칙(DIP)`를 구현하는 방법 중 하나`(DI)`.
>   > - 또 다른 방법으로는 `서비스 로케이터 패턴`이 존재
> - 함수나 클래스 안에서 외부 함수 클래스를 가져올 때는 매개변수나 생성자로 또는 Setter를 사용해서 받는 방법이 있음
>
> ```ts
> interface IObj {}
> class Obj implements IOBj {}
> class A {
>   constructor(obj?: IObj) {}
>   setObj(obj: IObj) {}
> }
> new A(new Obj()); // 생성자를 통해 주입받는 방식
> new A().setObj(new Obj()); // Setter를 통해 주입받는 방식
> ```
>
> - interface 타입의 매개변수를 통해 더 확장성 있는 클래스나 함수를 사용 가능
> - 모든 디자인 패턴이 SOLID 원칙을 지키는 것은 아님

### 심플 팩토리(Simple Factory) - 크롬, IE 그림판

> 객체를 반환하는 함수
>
> > - 팩토리 패턴은 타입 같은 것을 받아서 타입에 따라서 다른 객체를 반환 해줌
> > - 주로 조건문에 따라 다른 객체를 반환함
> > - 단일 책임 원칙 위반!
> > - 개방 폐쇄 원칙 위반!
>
> ```ts
> import ChromeGrimpan from "./ChromeGrimpan.js";
> import IEGrimpan from "./IEGrimpan.js";
>
> function grimpanFactory(type: string) {
>   if (type === "ie") {
>     return IEGrimpan.getInstance();
>   } else if (type === "chrome") {
>     return ChromeGrimpan.getInstance();
>   } else if (type === "safari") {
>     return SafariGrimpan.getInstance();
>   } else {
>     throw new Error("일치하는 type이 없습니다");
>   }
> }
>
> function main() {
>   grimpanFactory("ie");
>   grimpanFactory("chrome");
>   grimpanFactory("safari");
> }
>
> main();
> ```
>
> - SOLID 위반
> - 그림판을 만드는 방법(getInstance 매개변수 추가 등)이 바뀌었을 때랑 그림판에 타입을 추가할(else if문 추가) 때 변경의 이유가 2가지이기 때문에 SRP위반
> - 객체 생성, 타입을 판단해서 if로 분기
> - 디자인 패턴은 if문을 줄이는데 많이 사용되기도
> - 위 방법보다는 팩토리 메서드를 추천, Simple Factory는 가장 간단한 형태의 팩토리 패턴으로 GoF 팩토리 패턴에 안들어감. 기반이 되는 느낌

### 팩토리 메서드(Factory Method) - 사파리 그림판이 추가되는 경우

> 상위 클래스가 인터페이스 역할, 하위 클래스에서 구체적인 구현
>
> - 하위 클래스를 다양하게 만들어 OCP, SRP 충족
> - 상속을 통해서도 다른 객체를 생성할 수 있음
>   ![Image](https://github.com/user-attachments/assets/136dbb55-67de-4748-b56f-0cb61894c86c)
>
> ```ts
> export default abstract class Grimpan {
> protected constructor(canvas: HTMLElement | null) {
>  if (!canvas || !(canvas instanceof HTMLCanvasElement)) {
>    throw new Error("canvas 엘리먼트를 입력하세요");
>  }
> }
>
> abstract initialize(): void;
> abstract initializeMenu(): void;
>
> static getInstance() {}
> }
> ...
> import Grimpan from "./AbstractGrimpan";
>
> abstract class AbstractGrimpanFactory {
>   static createGrimpan(): Grimpan {
>     throw new Error("하위 클래스에서 구현하셔야 합니다.");
>   }
> }
>
> export default AbstractGrimpanFactory;
> ```
>
> - 일반 클래스가 abstract 클래스를 상속 가능
> - abstract class에 protected 멤버를 정의하면, 해당 멤버는 하위 클래스에서 접근 및 재정의가 가능
> - 추상 클래스(인터페이스도 가능 다만 실제 구현(로직)이 못 들어감)는 Grimpan의 클래스 타입을 명시
> - `abstract static createGrimpan()`은 안됨, `static createGrimpan()`으로
>   > - throw로 LSP를 위반할 수 있지만 추상 단독으로 쓰이진 않으니 허용
> - `Grimpan`과 `AbstractGrimpanFactory`는 인터페이스 역할을 하고
>
> ```ts
> import Grimpan from "./AbstractGrimpan.js";
>
> class ChromeGrimpan extends Grimpan {
>   private static instance: ChromeGrimpan;
>
>   override initialize() {}
>   override initializeMenu() {}
>
>   static override getInstance() {
>     if (!this.instance) {
>       this.instance = new ChromeGrimpan(document.querySelector("canvas"));
>     }
>     return this.instance;
>   }
> }
>
> export default ChromeGrimpan;
> ```
>
> - `ChromeGrimpan`은 추상 클래스를 상속 받음으로써 `구체적인 구현` 역할
>
> ```ts
> import ChromeGrimpan from "./ChromeGrimpan.js";
> import IEGrimpan from "./IEGrimpan.js";
> import AbstractGrimpanFactory from "./AbstractGrimpanFactory.js";
>
> class ChromeGrimpanFactory extends AbstractGrimpanFactory {
>   static override createGrimpan() {
>     return ChromeGrimpan.getInstance();
>   }
> }
>
> class IEGrimpanFactory extends AbstractGrimpanFactory {
>   static override createGrimpan() {
>     return IEGrimpan.getInstance();
>   }
> }
>
> function main() {
>   // const grimpan = new ChromeGrimpanFactory.createGrimpan();
>   const grimpan = ChromeGrimpanFactory.createGrimpan();
>   grimpan.initialize();
>   grimpan.initializeMenu();
> }
>
> main();
> ```
>
> - if문을 없애는 방법으로 동격으로 할지 상속(`ChromeGrimpanFactory`를 상속)으로 생성할지 선택가능
> - abstract class가 interface보다 좋은 점은
>
> ```ts
> ...
> protected constructor(canvas: HTMLElement | null) {
>  if (!canvas || !(canvas instanceof HTMLCanvasElement)) {
>   throw new Error("canvas 엘리먼트를 입력하세요");
> }
> }
> ...
> ```
>
> - ChromeGrimpan, IEGrimpan에 공통되는 구현부가 있는 경우 상속으로 없앨수있음
>
> ```ts
> import Grimpan from "./AbstractGrimpan.js";
>
> class ChromeGrimpan implements Grimpan {
>   private static instance: ChromeGrimpan;
>   private constructor(canvas: HTMLElement | null) {
>     if (!canvas || !(canvas instanceof HTMLCanvasElement)) {
>       throw new Error("canvas 엘리먼트를 입력하세요");
>     }
>   }
>
>   initialize() {}
>   initializeMenu() {}
>
>   static getInstance() {
>     if (!this.instance) {
>       this.instance = new ChromeGrimpan(document.querySelector("canvas"));
>     }
>     return this.instance;
>   }
> }
>
> export default ChromeGrimpan;
> ```
>
> - Grimpan을 추상 클래스에서 interface로 작성한 경우 위와 같이 추상클래스에 있던 구현부를 직접 작성해야 하고 static도 제거가 됨
>   > - interface에 있던 메서드도 호출해야하고
> - js에는 `abstract class, interface`가 없으니 클래스에 throw가 들어있는 형태로 인터페이스 대용으로 많이 사용. 아래에서 변환을 하면 ~
>
> ```ts
> import Grimpan from "./AbstractGrimpan";
>
> abstract class AbstractGrimpanFactory {
>   static createGrimpan(): Grimpan {
>     throw new Error("하위 클래스에서 구현하셔야 합니다.");
>   }
> }
>
> export default AbstractGrimpanFactory;
> ```
>
> - abstract static이 안돼기 때문에 아래와 같은 형태가 현재는 안됨
>
> ```ts
> function main(factory: typeof AbstractGrimpanFactory) {
>   // const grimpan = new ChromeGrimpanFactory.createGrimpan();
>   const grimpan = factory.createGrimpan();
>   grimpan.initialize();
>   grimpan.initializeMenu();
> }
>
> main(IEGrimpanFactory);
> ```
>
> - `결국 어딘가에서는 브라우저에 대한 분기 처리를 해야하는데, 그걸 최대한 클라이언트(사용하는 측)가 할 수 있게 미루는 게 좋다. 그래서 main 함수 내부에서 하기보다 main 함수를 쓰는 쪽에서 작성해야`
>
> - `extends AbstractGrimpanFactory`가 공통으로 상속받고 매개변수를 넣어주면 위와 같은 형태가 가능하긴함.
>
> AbstractGrimpan을 분리해 놓은 이유
>
> - 팩토리는 단순 객체 생성자 호출만 해야하고, 그림판 초기화 관련 로직은 그림판 객체에 따로 있어야
>   > - SRP

### 추상 팩토리(Abstract Factory) - 여러 객체가 세트로 구성되어 있을 때

> 여러 팩토리의 그룹
>
> - 팩토리 메서드 패턴에서 확장하면 편함
> - 그림판, 메뉴, 히스토리의 세트가 브라우저별로 생성됨(Chrome 메뉴에 IE 히스토리가 생기는 등의 상황을 방지)
>   ![Image](https://github.com/user-attachments/assets/60f5ce94-4437-4672-970f-af8945af992e)
>
> ```ts
> import { ChromeGrimpanFactory } from "./GrimpanFactory.js";
>
> function main() {
>   const factory = ChromeGrimpanFactory;
>   const grimpan = factory.createGrimpan();
>   const grimpanMenu = factory.createGrimpanMenu(grimpan);
>   const grimpanHistory = factory.createGrimpanHistory(grimpan);
>   grimpan.initialize();
>   grimpanMenu.initialize();
>   grimpanHistory.initialize();
> }
>
> main();
> ```
>
> - Abstract Factory 패턴은 관련있는 거(필요한 인스턴스를 싱글톤으로 생성)를 세트로 생성할 수 있고 신기능을 추가할 때마다 기존 코드를 안건드로고도 추가할 수 있음

### 빌더(Builder) - 객체를 생성하는 과정이 복잡할 때

> 복잡한 객체의 단계별 생성
>
> - drawButtonByType 메서드가 director(빌더의 set 메서드의 순서를 정하고 실행하는)의 역할
> - setter에서 개별 속성 validation을 하고, build에서 최종적으로 전체 validation을 한 번 더 하면 좋음.
>   ![Image](https://github.com/user-attachments/assets/db3aa430-fe69-40c7-8d33-ebed7b345dcf)
>
> - 빌더 패턴의 장점은 필수 인자가 뭔지 옵셔널 메서드가 어떻게 작용하는지 구별 가능
> - 마지막의 build 메서드를 통해 완성된 객체임을 확인 가능 -> 애초에 타입 자체가 빌더
> - 객체를 다양한 방법으로 만들 수 있게 하는 경우 외부의 빌더를 사용
>   > - interface로 각 메서드를 작성하고 interface 구현하는 두 가지 이상의 클래스를 작성

### 프로토타입(Prototype)

> 기존 객체를 복사(clone)해서 생성 후 달라지는 부분만 활용
>
> - javascript의 prototype을 활용해 객체를 생성하는 것(Object.create(프로토타입))도 어떻게 보면 프로토타입 타입 패턴임
>   ![Image](https://github.com/user-attachments/assets/2ac7ac32-fb64-4733-a078-8cd82ded5951)
