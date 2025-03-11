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
