# map, filter, reduce 🤔
## map 🟢

```javascript
const log = console.log;

const products = [
    { name: '반팔티', price: 15000},
    { name: '긴팔티', price: 20000},
    { name: '핸드폰케이스', price: 15000},
    { name: '후드티', price: 30000},
    { name: '바지', price: 25000}
]
// key, value

let names = [];
for (const p of products) {
    names.push(p.name);
}
log(names); // ["반팔티", "긴팔티", "핸드폰케이스", "후드티", "바지"]

let prices = [];
for (const p of products) {
    prices.push(p.price);
}
log(prices); // [15000, 20000, 15000, 30000, 25000]
// map 함수는 위 코드들의 중복을 대신한다 🔘

const map = (f, iter) => {
    let res = [] ;
    for (const a of iter) {
        res.push(f(a));
        // 어떤 값을 수집할 것인지 f함수에게 위임한다.
    }
    return res;
};
//----------------------- 동일 ------------------------------
// function map(f, iter) {
//     let res = [] ;
//     for (const a of iter) {
//         res.push(f(a));
//         // 어떤 값을 수집할 것인지 f함수에게 위임한다.
//     }
//     return res;
// };
//-----------------------------------------------------------
// iter는 어떤 데이터든 받을 수 있도록, map함수가 받는 값이 이터러블 프로토콜을 따른다. 
log(map(p => p.name, products)); // ["반팔티", "긴팔티", "핸드폰케이스", "후드티", "바지"]
log(map(p => p.price, products)); // [15000, 20000, 15000, 30000, 25000]
```
함수형 프로그래밍에서는 ```map```이라는 함수에 보조 함수 ```p => p.name```를 통해서 ```products```배열 혹은 이터러블 안에 있는 어떤 값에 1:1로 매핑되는 어떠한 값을(```p.name```) 수집하겠다고 보조함수와 배열 혹은 이터러블을 전달하는 식으로 사용한다 !!😀
<br> 그리고 map함수는 <mark>고차함수</mark>이기도 하다. 함수를 값으로 다루면서 내가 원하는 시점에 안에서 인자를 적용하는 그런 함수이기도 하다 !! 🧐 
* * * 
## 이터러블 프로토콜을 따른 map의 다형성1 🟢
map함수는 이터러블 프로토콜을 따르고 있기 떄문에 다형성이 굉장히 높다 !!
```javascript
log(document.querySelectorAll('*')); // NodeList(7) [html, head, script, script, body, script, script]
log(document.querySelectorAll('*').map(el => el.nodeName)); // ❌ TypeError:

log([1,2,3].map(a=>a+1)); // [2, 3, 4] array에 map을 통해서 값을 수집할 수 있다.

// Why ❌?? 🤔🤔
// document.querySelectorAll('*')는 array를 상속받은 객체가 아니기 떄문이다 ! 그래서 프로토타입에(__proto__) map함수가 구현되어 있지 않다. 개발자 모드에서 __proto__에 없는 것을 확인할 수 있다.

// 그러나 앞에서 만들었던 map함수는 이 코드가 동작한다..!!🤷‍♂️
log(map(el => el.nodeName, document.querySelectorAll('*'))); // ["HTML", "HEAD", "SCRIPT", "SCRIPT", "BODY", "SCRIPT", "SCRIPT"]
// 그 이유는 document.querySelectorAll('*')가 "이터러블 프로토콜"을 따르고 있기 떄문이다. 

const it = document.querySelectorAll('*')[Symbol.iterator]();
log(it); // Array Iterator {} 이터레이터가 나오며
log(it.next()); // { value: html, done: false }
log(it.next()); // { value: head, done: false }
log(it.next()); // { value: script, done: false }
log(it.next()); // { value: script, done: false }
log(it.next()); // { value: body, done: false } 
// next를 통해서 내부 값을 순회

// 우리가 만든 map함수에서는 "이터러블 프로토콜"을 따르는 for..of문을 사용했기 떄문에 순회가 가능한것 !
// map함수는 array뿐만 아니라 "이터러블 프로토콜"을 따르는 많은 함수들을 모두 사용가능하다는 것이다 !!😀

function *gen() {
    yield 2;
    if (false) yield 3;
    yield 4;
}
log(map(a => a * a, gen())); // [4, 16] 
// 다형성이 엄청나다는 것을 확인 가능.."이터러블 프로토콜"을 따르는 이미 만들어진 이터러블인 모든 값들도 map을 사용할 수 있지만 위 코드 문장(재너레이터 함수의 결과) 역시도 map이 가능..
```
JS에 있는 것이 아니라 브라우저에서 사용되는 값이며 Web Api인 ```document.querySelectorAll('*')``` (helper, 헬퍼함수) 
<br> 이런 함수들이 ECMA 스크립트에 "이터러블 프로토콜"을 따르고 있기 때문에 앞으로도 같은 방식으로 만들어 질 것이다.
<br> "이터러블 프로토콜"을 따르는 함수들을 사용하는 것은 앞으로 많은 다른 헬퍼 함수들과의 조합성이 좋아진다는 이야기이기도 하다 !
<br> <mark>즉, 프로토타입 기반이나 클래스 기반으로 어떤 뿌리를 가진 어떤 카테고리 안에 있는 값만 어떤 함수를 사용할 수 있는 기법보다 훨씬 더 유연하고 다형성이 높아진다</mark>

* * *
## 이터러블 프로토콜을 따른 map의 다형성2 🟢
Map이라는 값이 있는데 앞에서 살펴봤었던 map()함수와 달리 JS에서 key, value 쌍을 표현하는 Map이라는 값이 있다. 그 값은 이터러블이다.

```javascript
const log = (a) => console.log(a);
let m = new Map();
m.set('a', 10);
m.set('b', 20);
const it = m[Symbol.iterator]();
log(it.next()); // { value: Array(2), done: false } value: ["a", 10]
log(it.next()); // { value: Array(2), done: false }
log(it.next()); // { value: undefined, done: true }
// key와 value를 entry로 표현해주고 있다.
// 엔트리란? 🧐 Object Entries returns object as Array of [key,value] Array 라고 한다.
// 엔트리로 표현이 되므로 m을 map() 함수의 이터러블 값으로 사용할 수 있다는 의미

log(map(([k, a]) => [k, a * 2], m)); // 보조함수를 전달했을 떄 value가 array로 들어오기 떄문에 구조분해를 해서 key와 value를 나눠서 받도록 한다 😎, 엔트리를 return하도록 하면
// result : [ Array(2), Array(2) ]
// 0: (2) ["a", 20]
// 1: (2) ["b", 40]

log(new Map(map(([k, a]) => [k, a * 2], m))); // 이렇게 다시 Map 객체를 만들 수가 있다.
// result: Map(2) { "a" => 20, "b" => 40 }
// __prop__: Map
// [[Entruies]]: Array(2)

```
<br>

## filter 🟢
* * *
<br>

```javascript
const products = [
    { name: '반팔티', price: 15000},
    { name: '긴팔티', price: 20000},
    { name: '핸드폰케이스', price: 15000},
    { name: '후드티', price: 30000},
    { name: '바지', price: 25000}
];

const filter = (f, iter) => {
    let res = [];
    for (const a of iter) {
        if (f(a)) res.push(a);
    }
    return res;
}
// filter 함수 인자값은 iterable 프로토콜을 따르도록
// 값의 범위를 지정하는 조건은 if문에서 "평가"되도록 보조함수에게 위임한다 !
// 

let under20000 = [];
for (const p of products) {
    if (p.price < 20000) under20000.push(p);
}

log(under20000); // [{...}, {...}]
log(...under20000); 
// 전개연산자
// { name: "반팔티", price: 15000}
// { name: "핸드폰케이스", price: 15000}

log(...filter(p => p.price < 20000, products))
// 전개연산자
// { name: "반팔티", price: 15000}
// { name: "핸드폰케이스", price: 15000}
 
log(filter(n => n%2, [1, 2, 3, 4])); // [1, 3]
log(filter(n => n % 2, function *(){
    yield 1;
    yield 2;
    yield 3;
    yield 4;
    yield 5;
} ())); // [1, 3, 5]
```
<br>

```filter```함수 역시 이터러블 프로토콜을 따른다.
```javascript
const words = ['spray', 'limit', 'elite', 'exuberant', 'destruction', 'present'];

const result = words.filter(word => word.length > 6);

log(result);
// expected output: Array ["exuberant", "destruction", "present"]
```
<br>

## reduce 🟢

 ```reduce```는 어떤 값(이터러블 값)을 하나의 다른 값으로 축약하는 함수

 ```javascript
 const nums = [1, 2, 3, 4, 5];

 let total = 0;
 for (const n of nums) {
     total = total + n;
 }
 log(total); // 15

 const reduce = (f, acc, iter) => {
    if (!iter) {
        iter = acc[Symbol.iterator](); // acc가 이터레이터가 될 것, 이터러블 값을 이터레이터로 변환
        acc = iter.next().value;
    } // 초깃값이 없는 경우의 reduce
    for (const a of iter) {
        acc = f(acc, a);
    }
    return acc; 
 };
 // 연속적으로 재귀적으로 받은 보조함수를 실행하면서 하나의 값으로 누적해나가는 방식으로..
 // acc 누적값

 const add = (a, b) => a + b;

 log(reduce(add, 0, [1, 2, 3, 4, 5])); // 15

 log(add(add(add(add(add(0, 1), 2), 3), 4), 5)); // 15

 // JS에서 reducde를 acc 값 없이 옵셔널하게 사용할 수 있도록 reduce가 구현되어 있다.
 log(reduce(add, [1, 2, 3, 4, 5])); 
 -> log(reduce(add, 1, [2, 3, 4, 5])); // 내부적으로 reduce가 acc시작하는 값(누적값)을 받은 것처럼 동작한다 

// log(reduce(add, [1, 2, 3, 4, 5]));에서 [1, 2, 3, 4, 5]이터러블을 이터레이터로 만들고 그렇게 만든 이터레이터에서 첫번째 값을 next()로 꺼내서 acc로 옮겨줘서
// log(reduce(add, 1, [2, 3, 4, 5])); 이 가능    
 ```
 <br>

### 매개변수
```callback```<br>
배열의 각 요소에 대해 실행할 함수. 다음 네 가지 인수를 받습니다.<br>
```accumulator```<br>
누산기는 콜백의 반환값을 누적합니다. 콜백의 이전 반환값 또는, 콜백의 첫 번째 호출이면서 initialValue를 제공한 경우에는 initialValue의 값입니다.<br>
```currentValue```<br>
처리할 현재 요소.<br>
```currentIndex``` <mark>Optional</mark><br>
처리할 현재 요소의 인덱스. initialValue를 제공한 경우 0, 아니면 1부터 시작합니다.<br>
```array``` <mark>Optional</mark><br>
reduce()를 호출한 배열.<br>
```initialValue``` <mark>Optional</mark><br>
callback의 최초 호출에서 첫 번째 인수에 제공하는 값. 초기값을 제공하지 않으면 배열의 첫 번째 요소를 사용합니다. 빈 배열에서 초기값 없이 reduce()를 호출하면 오류가 발생합니다.
### 설명

```reduce()```는 빈 요소를 제외하고 배열 내에 존재하는 각 요소에 대해 ```callback``` 함수를 한 번씩 실행하는데, 콜백 함수는 다음의 네 인수를 받는다.

- ```accumulator```
- ```currentValue```
- ```currentIndex```
- ```array```

콜백의 최초 호출 때 ```accumulator```와 ```currentValue```는 다음 두 가지 값 중 하나를 가질 수 있다. 만약 ```reduce()``` 함수 호출에서 ```initialValue```를 제공한 경우, ```accumulator```는 ```initialValue```와 같고 ```currentValue```는 배열의 첫 번째 값과 같다. ```initialValue```를 제공하지 않았다면, ```accumulator```는 배열의 첫 번째 값과 같고 ```currentValue```는 두 번째와 같다.

 ```javascript
const arrayOfNumbers = [1, 2, 3, 4];
 
const sum = arrayOfNumbers.reduce((accumulator, currentValue) => {  
  return accumulator + currentValue;
});
 
console.log(sum); // 10
 ```