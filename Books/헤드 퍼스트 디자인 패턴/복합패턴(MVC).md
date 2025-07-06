# MVC 복합 패턴과 디자인 패턴들

## 1. MVC 복합 패턴의 구성

MVC는 **Observer, Strategy, Composite 패턴**이 조합된 **복합 패턴(Compound Pattern)**입니다.

### 전체 아키텍처

```
📊 Model (Subject)
    ↓ Observer Pattern
👁 View (Observer + Composite)
    ├── ListView (Composite)
    │   ├── ItemView1 (Leaf)
    │   ├── ItemView2 (Leaf)
    │   └── SubListView (Composite)
    │       ├── SubItemView1 (Leaf)
    │       └── SubItemView2 (Leaf)
    └── StatusView (Leaf)

🎮 Controller
    ├── Strategy 1 (정렬 전략)
    ├── Strategy 2 (필터 전략)
    └── Strategy 3 (검증 전략)
```

## 2. Observer 패턴 - Model과 View 간 통신

### 기본 구조

```java
// Subject (Model)
public class TodoModel extends Observable {
    private List<Todo> todos = new ArrayList<>();

    public void addTodo(Todo todo) {
        todos.add(todo);
        notifyObservers(); // 📢 모든 Observer에게 알림
    }

    public void updateTodo(int id, String newText) {
        // 비즈니스 로직 수행
        Todo todo = findTodoById(id);
        todo.setText(newText);
        notifyObservers(); // 📢 변경 알림
    }
}

// Observer (View)
public abstract class ViewComponent implements Observer {
    protected TodoModel model;

    public ViewComponent(TodoModel model) {
        this.model = model;
        model.addObserver(this); // Observer 등록
    }

    @Override
    public abstract void update(Observable o, Object arg);
}
```

### Push vs Pull 방식

#### Push 방식의 문제점

```java
// ❌ Push 방식 - 상태를 직접 전달
public class TodoModel extends Observable {
    public void addTodo(Todo todo) {
        todos.add(todo);
        // 전체 todos 리스트를 모든 Observer에게 전달
        notifyObservers(todos); // 문제점들 발생
    }
}
```

**Push 방식의 단점:**

1. **결합도 증가**: View가 Model의 내부 구조에 의존
2. **불필요한 데이터 전송**: 대용량 객체 전체 전송
3. **보안 문제**: 민감한 정보 노출 위험
4. **메모리 비효율성**: 객체 참조로 인한 메모리 누수
5. **확장성 문제**: 새로운 View 타입 추가 시 어려움

#### Pull 방식의 장점

```java
// ✅ Pull 방식 - 필요한 데이터만 요청
public class TodoModel extends Observable {
    public void addTodo(Todo todo) {
        todos.add(todo);
        notifyObservers(); // 변경 사실만 알림
    }

    // View가 필요한 데이터만 요청할 수 있는 메서드들
    public List<Todo> getTodos() { return new ArrayList<>(todos); }
    public int getTodoCount() { return todos.size(); }
    public Todo getTodoById(int id) { return findTodoById(id); }
}

public class TodoCountView extends ViewComponent {
    @Override
    public void update(Observable o, Object arg) {
        // 개수만 필요한 View는 개수만 가져옴
        int count = model.getTodoCount();
        countLabel.setText(String.valueOf(count));
    }
}
```

## 3. Composite 패턴 - 계층적 View 구조

### DFS와 유사한 재귀 구조

Composite 패턴에서의 재귀는 **DFS(깊이 우선 탐색)**와 매우 유사한 방식으로 작동합니다.

#### DFS 재귀와의 비교

```java
// DFS 재귀
void dfs(Node node) {
    if (node == null) return; // 명시적 종료 조건

    visit(node); // 현재 노드 처리

    for (Node child : node.children) {
        dfs(child); // 자식 노드들을 재귀적으로 탐색
    }
}

// Composite 패턴의 재귀
public class Flock implements Quackable {
    ArrayList<Quackable> quackers = new ArrayList<>();

    public void quack() {
        for (Quackable quacker : quackers) {
            quacker.quack(); // 재귀적으로 호출
        }
        // 리스트가 비어있으면 자연스럽게 종료 (암묵적 종료 조건)
    }
}
```

### 개별 객체와 복합 객체의 동일한 취급

#### 패턴 적용 전 - 구분해서 처리

```java
// 개별 오리들을 각각 다르게 처리
MallardDuck mallard = new MallardDuck();
RedheadDuck redhead = new RedheadDuck();

// 각각 따로 quack() 호출
mallard.quack();
redhead.quack();

// 그룹으로 처리하려면 별도 로직 필요
ArrayList<Duck> ducks = new ArrayList<>();
for (Duck duck : ducks) {
    duck.quack(); // 반복문으로 따로 처리
}
```

#### 패턴 적용 후 - 동일하게 처리

```java
// 공통 인터페이스 (Component)
public interface Quackable {
    public void quack();
}

// 잎 노드 (Leaf) - 개별 오리들
public class MallardDuck implements Quackable {
    public void quack() {
        System.out.println("Quack"); // 여기서 실제 종료!
    }
}

// 복합 노드 (Composite) - 오리 그룹
public class Flock implements Quackable {
    ArrayList<Quackable> quackers = new ArrayList<>();

    public void add(Quackable quacker) {
        quackers.add(quacker);
    }

    public void quack() {
        // 모든 하위 요소들에게 위임
        for (Quackable quacker : quackers) {
            quacker.quack(); // 재귀적으로 호출
        }
    }
}

// 클라이언트 코드 - 개별이든 그룹이든 동일하게 처리
Quackable mallard = new MallardDuck();
Quackable flock = new Flock();

flock.add(mallard);
flock.add(new RedheadDuck());

// 개별 객체든 복합 객체든 동일한 방식으로 사용
mallard.quack();  // 개별 오리
flock.quack();    // 오리 그룹 - 내부의 모든 오리가 울음
```

### Observer + Composite 동작 흐름

```java
// 계층적 View 구조에서 Observer 패턴 적용
public class TodoListView extends ViewComponent {
    private List<ViewComponent> childViews = new ArrayList<>();

    public void addChildView(ViewComponent view) {
        childViews.add(view);
    }

    @Override
    public void update(Observable o, Object arg) {
        // 🔄 모든 하위 View에게 업데이트 전파 (Composite)
        for (ViewComponent child : childViews) {
            child.update(o, arg); // 재귀적 호출
        }

        // 자신도 업데이트
        this.refresh();
    }
}
```

**실행 흐름:**

```
Model 변경
    ↓
notifyObservers() 호출 (Observer)
    ↓
등록된 모든 Observer에게 알림
    ↓
CompositeView.update() 호출
    ↓
├── 하위 View1.update() 호출 (잎 노드)
├── 하위 View2.update() 호출 (잎 노드)
└── 하위 CompositeView.update() 호출 (복합 노드)
        ↓
    재귀적으로 그 하위들에게도 전파...
```

## 4. Strategy 패턴 - 런타임 행동 변경

### Controller에서의 전략 패턴 활용

```java
// Strategy 인터페이스들
public interface SortStrategy {
    List<Todo> sort(List<Todo> todos);
}

public interface FilterStrategy {
    List<Todo> filter(List<Todo> todos);
}

// 구체적인 전략 구현
public class DateSortStrategy implements SortStrategy {
    public List<Todo> sort(List<Todo> todos) {
        return todos.stream()
                   .sorted(Comparator.comparing(Todo::getCreatedDate))
                   .collect(Collectors.toList());
    }
}

public class PrioritySortStrategy implements SortStrategy {
    public List<Todo> sort(List<Todo> todos) {
        return todos.stream()
                   .sorted(Comparator.comparing(Todo::getPriority))
                   .collect(Collectors.toList());
    }
}

public class CompletedFilterStrategy implements FilterStrategy {
    public List<Todo> filter(List<Todo> todos) {
        return todos.stream()
                   .filter(Todo::isCompleted)
                   .collect(Collectors.toList());
    }
}
```

### Controller에서 전략 사용

```java
public class TodoController {
    private SortStrategy sortStrategy;
    private FilterStrategy filterStrategy;
    private TodoModel model;
    private TodoView view;

    // 런타임에 전략 변경 가능
    public void setSortStrategy(SortStrategy strategy) {
        this.sortStrategy = strategy;
    }

    public void setFilterStrategy(FilterStrategy strategy) {
        this.filterStrategy = strategy;
    }

    public void displayTodos() {
        List<Todo> todos = model.getTodos();

        // 선택된 전략에 따라 다른 행동 수행
        todos = sortStrategy.sort(todos);      // 전략에 따른 정렬
        todos = filterStrategy.filter(todos);  // 전략에 따른 필터링

        view.showTodos(todos);
    }
}

// 런타임에 전략 변경
controller.setSortStrategy(new DateSortStrategy());         // 날짜순 정렬
controller.setFilterStrategy(new CompletedFilterStrategy()); // 완료된 항목만
controller.displayTodos();

// 다른 전략으로 변경
controller.setSortStrategy(new PrioritySortStrategy());      // 우선순위순 정렬
controller.setFilterStrategy(new ActiveFilterStrategy());    // 미완료 항목만
controller.displayTodos();
```

## 5. DuckSimulator 예제에서의 패턴 활용

### Strategy 패턴 - Duck의 행동

```java
// Duck 클래스에서 전략 패턴 사용
public abstract class Duck {
    FlyBehavior flyBehavior;     // 날기 전략
    QuackBehavior quackBehavior; // 울음 전략

    public void performFly() {
        flyBehavior.fly(); // 전략에 따른 날기 행동
    }

    public void performQuack() {
        quackBehavior.quack(); // 전략에 따른 울음 행동
    }

    // 런타임에 행동 변경 가능
    public void setFlyBehavior(FlyBehavior fb) {
        flyBehavior = fb;
    }

    public void setQuackBehavior(QuackBehavior qb) {
        quackBehavior = qb;
    }
}
```

### Observer 패턴 - 울음소리 관찰

```java
// Observer 인터페이스
public interface Observer {
    public void update(QuackObservable duck);
}

// 구체적인 Observer
public class Quackologist implements Observer {
    public void update(QuackObservable duck) {
        System.out.println("Quackologist: " + duck + " just quacked.");
    }
}

// Observable한 오리
public class MallardDuck implements Quackable, QuackObservable {
    Observable observable;

    public MallardDuck() {
        observable = new Observable(this);
    }

    public void quack() {
        System.out.println("Quack");
        notifyObservers(); // 울 때마다 관찰자들에게 알림
    }

    public void registerObserver(Observer observer) {
        observable.registerObserver(observer);
    }

    public void notifyObservers() {
        observable.notifyObservers();
    }
}
```

### Decorator 패턴 - 기능 확장

```java
// QuackCounter로 울음소리 카운팅 기능 추가
public class QuackCounter implements Quackable {
    Quackable duck;
    static int numberOfQuacks = 0;

    public QuackCounter(Quackable duck) {
        this.duck = duck;
    }

    public void quack() {
        duck.quack();         // 원본 기능 수행
        numberOfQuacks++;     // 새로운 기능 추가
    }

    public static int getQuacks() {
        return numberOfQuacks;
    }
}
```

### Composite 패턴 - 오리 그룹 관리

```java
// Flock 클래스로 오리들을 그룹화
public class Flock implements Quackable {
    ArrayList<Quackable> quackers = new ArrayList<>();

    public void add(Quackable quacker) {
        quackers.add(quacker);
    }

    public void quack() {
        // 모든 오리가 울도록 함
        for (Quackable quacker : quackers) {
            quacker.quack();
        }
    }
}

// 사용 예시
Flock flockOfDucks = new Flock();
flockOfDucks.add(new MallardDuck());
flockOfDucks.add(new RedheadDuck());

// 중첩된 그룹도 가능
Flock flockOfMallards = new Flock();
flockOfMallards.add(new MallardDuck());
flockOfMallards.add(new MallardDuck());

flockOfDucks.add(flockOfMallards); // 그룹 안에 그룹

// 개별 오리든 그룹이든 동일하게 처리
flockOfDucks.quack(); // 모든 오리가 울음
```

### Abstract Factory 패턴 - 객체 생성

```java
// 오리 팩토리
public abstract class AbstractDuckFactory {
    public abstract Quackable createMallardDuck();
    public abstract Quackable createRedheadDuck();
    public abstract Quackable createDuckCall();
    public abstract Quackable createRubberDuck();
}

// 카운팅 기능이 있는 오리 팩토리
public class CountingDuckFactory extends AbstractDuckFactory {
    public Quackable createMallardDuck() {
        return new QuackCounter(new MallardDuck());
    }

    public Quackable createRedheadDuck() {
        return new QuackCounter(new RedheadDuck());
    }

    // ... 다른 오리들도 카운팅 기능 추가
}
```

## 6. 복합 패턴의 장점

MVC에서 여러 패턴을 조합함으로써 얻는 이점:

### 1. 관심사의 분리

```java
// 각 패턴이 서로 다른 책임을 담당
Model (Subject)     → 비즈니스 로직과 데이터 관리
View (Observer)     → UI 표현과 사용자 인터랙션
Controller          → 흐름 제어와 전략 선택
Strategy            → 알고리즘의 캡슐화
Composite           → 계층적 구조 관리
```

### 2. 유연성과 확장성

```java
// 새로운 View 타입 추가 - Observer 패턴의 이점
model.addObserver(new MobileView());
model.addObserver(new WebView());
model.addObserver(new DesktopView());

// 새로운 정렬 방식 추가 - Strategy 패턴의 이점
controller.setSortStrategy(new CustomSortStrategy());

// 복잡한 UI 구조 구성 - Composite 패턴의 이점
mainView.add(headerView);
mainView.add(contentView);
contentView.add(listView);
listView.add(itemView1);
listView.add(itemView2);
```

### 3. 재사용성

```java
// 각 컴포넌트가 독립적으로 재사용 가능
SortStrategy dateSort = new DateSortStrategy();
// 다른 Controller에서도 동일한 전략 사용 가능

ViewComponent todoView = new TodoItemView();
// 다른 복합 View에서도 재사용 가능
```

### 4. 테스트 용이성

```java
// 각 패턴별로 독립적인 단위 테스트 가능
@Test
public void testObserverPattern() {
    MockView mockView = new MockView();
    model.addObserver(mockView);
    model.updateData();
    assertTrue(mockView.wasUpdated());
}

@Test
public void testStrategyPattern() {
    List<Todo> result = sortStrategy.sort(testData);
    assertEquals(expectedOrder, result);
}
```

## 정리

**MVC 복합 패턴의 핵심:**

1. **Observer 패턴**: Model-View 간 느슨한 결합과 자동 동기화
2. **Composite 패턴**: 계층적 View 구조에서 일관된 처리
3. **Strategy 패턴**: Controller의 알고리즘 선택과 런타임 변경
4. **Pull 방식**: Push 방식보다 결합도가 낮고 효율적
5. **재귀 구조**: DFS와 유사한 방식으로 트리 구조 순회
6. **복합 패턴의 시너지**: 단일 패턴으로는 해결하기 어려운 복잡한 문제를 우아하게 해결

이러한 패턴들의 조합이 현대 프레임워크들의 기반이 되어 **React의 컴포넌트 트리**, **Vue의 반응형 시스템**, **Angular의 의존성 주입** 등으로 발전!
