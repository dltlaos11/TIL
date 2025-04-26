# 디자인 패턴

## 팩토리

> 팩토리 메서드 패턴 vs 추상 팩토리 패턴

> - 팩토리 메서드 패턴
>
> > - 피자 가게(PizzaStore)가 단일 메서드(createPizza())를 통해 하나의 제품(피자)을 생성합니다.
> > - 각 지역별 피자 가게(예: NYPizzaStore, ChicagoPizzaStore)가 이 메서드를 구현하여 자신의 스타일에 맞는 피자를 생성합니다.
> > - 상속을 통한 구현: 기본 PizzaStore 클래스를 상속받아 지역별 피자 가게를 만듭니다.
> > - 초점이 단일 객체(피자)의 생성에 있습니다.

> - 추상 팩토리 패턴
>
> > - PizzaIngredientFactory 인터페이스가 관련된 여러 제품(도우, 소스, 치즈 등)을 생성하는 여러 메서드를 포함합니다.
> > - 각 지역별 재료 공장이 전체 제품군을 생성합니다 (예: NYPizzaIngredientFactory는 뉴욕 스타일 전체 재료를).
> > - 객체 구성을 통한 구현: 피자 객체가 재료 공장을 받아 필요한 재료를 공급받습니다.
> >   초점이 관련된 제품군(피자 재료 세트)의 생성에 있습니다.

> - 실제 적용 차이
>   - 코드에서 볼 수 있듯이, 추상 팩토리 패턴을 사용하면 피자 자체보다 피자의 구성 요소들에 초점을 맞추게 됩니다. 이를 통해:
>
> a. 지역별로 서로 다른 재료 세트를 일관되게 사용할 수 있습니다
> b. 새로운 지역/스타일 추가가 용이해집니다 (새 재료 공장만 추가하면 됨)
> c. 재료들이 함께 변경되어야 할 때 쉽게 관리됩니다

> - 헤드 퍼스트 디자인 패턴 책에서는 위 두 패턴을 결합하여 최종적으로 재료 팩토리(추상 팩토리)를 피자 가게(팩토리 메서드)에 통합하는 방식으로 발전시킵니다.

```java
// 1. 팩토리 메서드 패턴
// 예시: 피자 가게에서 지역별로 다른 스타일의 피자를 만듭니다

// 제품 인터페이스
interface Pizza {
    void prepare();
    void bake();
    void cut();
    void box();
    String getName();
}

// 구체적인 제품들
class NYStyleCheesePizza implements Pizza {
    public NYStyleCheesePizza() {
        System.out.println("뉴욕 스타일 치즈 피자 생성");
    }

    public void prepare() { System.out.println("NY 스타일로 준비 중..."); }
    public void bake() { System.out.println("350도에서 25분간 굽습니다."); }
    public void cut() { System.out.println("대각선으로 자릅니다."); }
    public void box() { System.out.println("공식 뉴욕 피자 상자에 담습니다."); }
    public String getName() { return "뉴욕 스타일 치즈 피자"; }
}

class ChicagoStyleCheesePizza implements Pizza {
    public ChicagoStyleCheesePizza() {
        System.out.println("시카고 스타일 치즈 피자 생성");
    }

    public void prepare() { System.out.println("시카고 스타일로 준비 중..."); }
    public void bake() { System.out.println("425도에서 30분간 굽습니다."); }
    public void cut() { System.out.println("사각형으로 자릅니다."); }
    public void box() { System.out.println("공식 시카고 피자 상자에 담습니다."); }
    public String getName() { return "시카고 스타일 딥디쉬 치즈 피자"; }
}

// 팩토리 메서드를 포함한 생산자 추상 클래스
abstract class PizzaStore {
    // 팩토리 메서드
    protected abstract Pizza createPizza(String type);

    // 템플릿 메서드
    public Pizza orderPizza(String type) {
        Pizza pizza = createPizza(type);

        pizza.prepare();
        pizza.bake();
        pizza.cut();
        pizza.box();

        return pizza;
    }
}

// 구체적인 생산자 클래스들
class NYPizzaStore extends PizzaStore {
    @Override
    protected Pizza createPizza(String type) {
        if (type.equals("cheese")) {
            return new NYStyleCheesePizza();
        }
        // 다른 타입도 구현 가능 (pepperoni, clam, veggie 등)
        return null;
    }
}

class ChicagoPizzaStore extends PizzaStore {
    @Override
    protected Pizza createPizza(String type) {
        if (type.equals("cheese")) {
            return new ChicagoStyleCheesePizza();
        }
        // 다른 타입도 구현 가능
        return null;
    }
}

// 클라이언트 코드
class FactoryMethodExample {
    public static void main(String[] args) {
        PizzaStore nyStore = new NYPizzaStore();
        PizzaStore chicagoStore = new ChicagoPizzaStore();

        Pizza pizza1 = nyStore.orderPizza("cheese");
        System.out.println("에단이 주문한 " + pizza1.getName() + "\n");

        Pizza pizza2 = chicagoStore.orderPizza("cheese");
        System.out.println("조엘이 주문한 " + pizza2.getName() + "\n");
    }
}

// ===========================================================================

// 2. 추상 팩토리 패턴
// 예시: 피자 재료를 지역별로 다르게 구성하여 제공하는 재료 공장

// 여러 제품군의 인터페이스들
interface Dough {
    String toString();
}

interface Sauce {
    String toString();
}

interface Cheese {
    String toString();
}

// 제품군의 구체적인 구현들 (NY 스타일)
class ThinCrustDough implements Dough {
    public String toString() { return "씬 크러스트 도우"; }
}

class MarinaraSauce implements Sauce {
    public String toString() { return "마리나라 소스"; }
}

class ReggianoCheese implements Cheese {
    public String toString() { return "레지아노 치즈"; }
}

// 제품군의 구체적인 구현들 (시카고 스타일)
class ThickCrustDough implements Dough {
    public String toString() { return "두꺼운 크러스트 도우"; }
}

class PlumTomatoSauce implements Sauce {
    public String toString() { return "플럼 토마토 소스"; }
}

class MozzarellaCheese implements Cheese {
    public String toString() { return "모짜렐라 치즈"; }
}

// 추상 팩토리 인터페이스
interface PizzaIngredientFactory {
    Dough createDough();
    Sauce createSauce();
    Cheese createCheese();
    // 다른 재료도 추가 가능 (야채, 페퍼로니, 조개 등)
}

// 구체적인 팩토리 구현
class NYPizzaIngredientFactory implements PizzaIngredientFactory {
    public Dough createDough() {
        return new ThinCrustDough();
    }

    public Sauce createSauce() {
        return new MarinaraSauce();
    }

    public Cheese createCheese() {
        return new ReggianoCheese();
    }
}

class ChicagoPizzaIngredientFactory implements PizzaIngredientFactory {
    public Dough createDough() {
        return new ThickCrustDough();
    }

    public Sauce createSauce() {
        return new PlumTomatoSauce();
    }

    public Cheese createCheese() {
        return new MozzarellaCheese();
    }
}

// 피자 추상 클래스 (리팩토링)
abstract class PizzaWithIngredients {
    String name;
    Dough dough;
    Sauce sauce;
    Cheese cheese;

    // 팩토리로부터 재료를 공급받음
    abstract void prepare();

    void bake() {
        System.out.println("175도에서 25분간 굽습니다.");
    }

    void cut() {
        System.out.println("피자를 사선으로 자릅니다.");
    }

    void box() {
        System.out.println("공식 피자 상자에 피자를 담습니다.");
    }

    void setName(String name) {
        this.name = name;
    }

    String getName() {
        return name;
    }

    public String toString() {
        StringBuilder result = new StringBuilder();
        result.append("---- " + name + " ----\n");
        if (dough != null) {
            result.append(dough + "\n");
        }
        if (sauce != null) {
            result.append(sauce + "\n");
        }
        if (cheese != null) {
            result.append(cheese + "\n");
        }
        return result.toString();
    }
}

// 구체적인 피자 - 재료 팩토리를 사용
class CheesePizza extends PizzaWithIngredients {
    PizzaIngredientFactory ingredientFactory;

    public CheesePizza(PizzaIngredientFactory ingredientFactory) {
        this.ingredientFactory = ingredientFactory;
    }

    void prepare() {
        System.out.println(name + " 준비 중...");
        dough = ingredientFactory.createDough();
        sauce = ingredientFactory.createSauce();
        cheese = ingredientFactory.createCheese();
    }
}

// 리팩토링된 피자 가게
class PizzaStoreWithIngredients {
    protected PizzaWithIngredients createPizza(String type) {
        PizzaWithIngredients pizza = null;
        PizzaIngredientFactory ingredientFactory = createIngredientFactory();

        if (type.equals("cheese")) {
            pizza = new CheesePizza(ingredientFactory);
            pizza.setName(getStoreName() + " 치즈 피자");
        }
        // 다른 타입의 피자도 여기에 추가 가능

        return pizza;
    }

    // 지역에 맞는 재료 공장을 생성
    protected abstract PizzaIngredientFactory createIngredientFactory();

    // 가게 이름 반환
    protected abstract String getStoreName();

    public PizzaWithIngredients orderPizza(String type) {
        PizzaWithIngredients pizza = createPizza(type);

        pizza.prepare();
        pizza.bake();
        pizza.cut();
        pizza.box();

        return pizza;
    }
}

// 구체적인 뉴욕 피자 가게 (리팩토링)
class NYPizzaStoreWithIngredients extends PizzaStoreWithIngredients {
    protected PizzaIngredientFactory createIngredientFactory() {
        return new NYPizzaIngredientFactory();
    }

    protected String getStoreName() {
        return "뉴욕 스타일";
    }
}

// 구체적인 시카고 피자 가게 (리팩토링)
class ChicagoPizzaStoreWithIngredients extends PizzaStoreWithIngredients {
    protected PizzaIngredientFactory createIngredientFactory() {
        return new ChicagoPizzaIngredientFactory();
    }

    protected String getStoreName() {
        return "시카고 스타일";
    }
}

// 클라이언트 코드
class AbstractFactoryExample {
    public static void main(String[] args) {
        PizzaStoreWithIngredients nyStore = new NYPizzaStoreWithIngredients();
        PizzaStoreWithIngredients chicagoStore = new ChicagoPizzaStoreWithIngredients();

        PizzaWithIngredients pizza1 = nyStore.orderPizza("cheese");
        System.out.println("에단이 주문한 " + pizza1.getName());
        System.out.println(pizza1);

        PizzaWithIngredients pizza2 = chicagoStore.orderPizza("cheese");
        System.out.println("조엘이 주문한 " + pizza2.getName());
        System.out.println(pizza2);
    }
}
```

### 1. 상속보다는 구성을 활용하기

**구성(Composition)**은 객체 지향 프로그래밍에서 다른 객체를 포함하는 방식입니다.

#### 상속 vs 구성

- **상속(Inheritance)**: "is-a" 관계 - 하위 클래스가 상위 클래스를 확장함

  ```java
  class Duck extends Bird { ... }  // Duck은 Bird이다(is-a)
  ```

- **구성(Composition)**: "has-a" 관계 - 한 클래스가 다른 클래스의 인스턴스를 포함함

  ```java
  class Duck {
      private FlyBehavior flyBehavior;  // Duck은 FlyBehavior를 가진다(has-a)

      public void performFly() {
          flyBehavior.fly();  // 위임(delegation)
      }
  }
  ```

#### 구성의 장점

- 런타임에 동작을 변경할 수 있음
- 여러 클래스의 기능을 결합할 수 있음
- 상속보다 결합도가 낮음
- 코드 재사용성이 높아짐

### 2. 구상 클래스가 아닌 추상화에 맞춰 프로그래밍

**구상(Concrete)** 클래스는 직접 인스턴스화할 수 있는 구체적인 클래스입니다.

#### 추상화 vs 구상

- **추상화(Abstraction)**: 인터페이스나 추상 클래스처럼 일반적인 개념이나 계약을 정의

  ```java
  interface FlyBehavior {
      void fly();
  }

  abstract class Bird {
      abstract void makeSound();
  }
  ```

- **구상(Concrete)**: 추상화를 실제로 구현한 구체적인 클래스

  ```java
  class FlyWithWings implements FlyBehavior {
      public void fly() {
          System.out.println("날개로 날고 있어요!");
      }
  }

  class Duck extends Bird {
      void makeSound() {
          System.out.println("꽥꽥!");
      }
  }
  ```

#### 추상화에 맞춰 프로그래밍하는 이유

- 코드 변경의 영향 범위가 줄어듦
- 쉽게 확장 가능
- 구현보다 인터페이스에 의존하게 됨
- 유연성 증가

### 추상 팩토리 예제에서의 적용

앞서 본 추상 팩토리 패턴에서:

1. **구성 사용**: `CheesePizza` 클래스는 `PizzaIngredientFactory`를 포함(has-a)합니다.

   ```java
   class CheesePizza extends PizzaWithIngredients {
       PizzaIngredientFactory ingredientFactory; // 구성

       public CheesePizza(PizzaIngredientFactory ingredientFactory) {
           this.ingredientFactory = ingredientFactory;
       }
   }
   ```

2. **추상화에 맞춰 프로그래밍**: 코드가 `NYPizzaIngredientFactory`와 같은 구상 클래스가 아니라 `PizzaIngredientFactory` 인터페이스를 사용합니다.

   ```java
   // 좋은 예: 추상화에 맞춰 프로그래밍
   PizzaIngredientFactory factory = createIngredientFactory();

   // 나쁜 예: 구상 클래스에 의존
   NYPizzaIngredientFactory factory = new NYPizzaIngredientFactory();
   ```

이런 방식으로 코드를 작성하면 새로운 종류의 피자나 재료가 추가되어도 기존 코드를 수정할 필요 없이 확장할 수 있습니다.

## 싱글톤

> 헤드 퍼스트 디자인 패턴에서는 실제로 Enum을 사용한 싱글톤 패턴이 자바에서 싱글톤을 구현하는 가장 좋은 방법으로 소개된다. 이 방식은 Joshua Bloch가 "Effective Java"에서도 권장한 방식.

### Enum 싱글톤의 장점

1. **직렬화 문제 해결**: 일반 클래스로 구현한 싱글톤은 직렬화/역직렬화 과정에서 새로운 인스턴스가 생성될 수 있지만, Enum은 자바에서 직렬화를 보장합니다.

2. **리플렉션 공격 방어**: 일반적인 싱글톤은 리플렉션을 통해 private 생성자에 접근하여 여러 인스턴스를 생성할 수 있는 취약점이 있지만, Enum은 이런 공격에 안전합니다.

3. **스레드 안전성 보장**: 자바는 Enum 인스턴스가 JVM 내에서 단 한 번만 초기화되도록 보장합니다.

4. **간결한 코드**: 다른 싱글톤 구현 방식에 비해 코드가 매우 간결합니다.

5. **지연 초기화**: 필요에 따라 Enum 내부에 지연 초기화 패턴을 구현할 수도 있습니다.

### 일반적인 싱글톤 구현 방식과 비교

일반적인 싱글톤 패턴 구현(더블 체크 락킹(`DCL`))은 다음과 같은 문제점이 있습니다:

```java
public class ClassicSingleton {
    private static volatile ClassicSingleton instance;

    private ClassicSingleton() {}

    public static ClassicSingleton getInstance() {
        if (instance == null) {
            synchronized (ClassicSingleton.class) {
                if (instance == null) {
                    instance = new ClassicSingleton();
                }
            }
        }
        return instance;
    }
}
```

> - 이 방식은 코드가 복잡하고, 직렬화나 리플렉션에 대한 추가 방어 코드가 필요. 반면 Enum 싱글톤은 이 모든 문제를 자바 언어 차원에서 해결해 줍니다.
>
> - Enum 싱글톤은 제한적인 상황(상속이 필요한 경우 등)을 제외하면 자바에서 싱글톤을 구현하는 가장 안전하고 간결한 방법입니다.

### Apollo Client

> 일반적으로 애플리케이션에서 싱글톤으로 구현하고 사용됩니다. 이것이 각 도메인의 서비스를 Apollo Client에 주입하거나 Apollo Client를 통해 접근할 수 있게 하는 이유입니다.

Apollo Client를 싱글톤으로 사용하는 주요 이유는:

1. **캐시 일관성**: Apollo Client는 GraphQL 쿼리 결과를 내부 캐시에 저장합니다. 인스턴스가 여러 개라면 캐시가 분산되어 일관성이 깨질 수 있습니다.

2. **네트워크 요청 최적화**: 동일한 쿼리를 여러 곳에서 요청해도 하나의 네트워크 요청으로 처리할 수 있습니다.

3. **상태 관리**: Apollo Client는 GraphQL 데이터에 대한 전역 상태 관리자 역할을 합니다.

4. **설정 일관성**: 인증 토큰, 에러 핸들링 등의 설정을 애플리케이션 전체에서 일관되게 유지할 수 있습니다.

일반적인 구현 방식은 다음과 같습니다:

```javascript
// apolloClient.js
import { ApolloClient, InMemoryCache } from "@apollo/client";

// 싱글톤 인스턴스 생성
const client = new ApolloClient({
  uri: "https://api.example.com/graphql",
  cache: new InMemoryCache(),
});

export default client;
```

그리고 이 싱글톤 인스턴스를 애플리케이션 전체에서 공유합니다:

```javascript
// App.js
import { ApolloProvider } from "@apollo/client";
import client from "./apolloClient";

function App() {
  return <ApolloProvider client={client}>{/* 앱 컴포넌트들 */}</ApolloProvider>;
}
```

> 이런 구조에서 각 도메인별 서비스는 같은 Apollo Client 인스턴스를 사용하여 GraphQL 작업을 처리하게 됩니다. 이는 효과적으로 의존성 주입(DI) 패턴을 구현한 것으로 볼 수 있습니다.
