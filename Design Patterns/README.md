# Design Patterns

> [GoF](https://www.google.com/search?kgmid=/m/0b21p&hl=en-KR&q=Design+Patterns:+Elements+of+Reusable+Object-Oriented+Software&shndl=17&source=sh/x/kp/osrp/m5/1&kgs=302e1553e9b16cac) 책에 나오는 23가지 디자인 패턴과 그 외의 디자인 패턴을 JavaScript/TypeScript에 맞게 공부하는 REPO

## UML

> 클래스 간의 관계를 설명하는 다이어그램
>
> - `-`: `private` or `protected`
> - `+`: `public`
> - 실선은 class의 속성, 점선의 경우 속성이 아닌 다른 연결 관계
> - 실선의 빈 화살표는 상속(`extends`) 관계
> - 점선의 빈 화살표는 구현(`implements`) 관계
>   > - interface를 implements하면 안의 인터페이스에 선언된 모든 메서드를 구현해야
>   > - `런타임(동적) 다형성`은 인터페이스에 정의된 메서드를 오버라이드하여 자신의 방식으로 구현됨. 실행 시점에 어떤 클래스의 객체를 참조하느냐에 따라 호출되는 메서드가 결정
>   > - `컴파일(정적) 다형성`은 주로 메서드 오버로딩과 관련이 있으며 컴파일 시점에 호출될 메서드가 결정됨
> - 밑 줄은 클래스의 static 속성
> - 다이몬드 화살표는 집합(약 결합), 합성(강 결합)의 관계, 다이아있는 쪽이 주체
