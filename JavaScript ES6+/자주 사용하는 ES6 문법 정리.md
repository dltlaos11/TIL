# 자주 사용하는 ES6 문법 정리

> ## 들어가기 앞서 🤔
jQuery를 활용한 ES5 문법으로 JavaScript 코드를 작성하였지만 이제는 최신 트랜드에 맞게 ES6 문법으로 JavaScript 코드를 작성하는 요구사항이 많아짐.

> ## ES6(ECMAScript6)는 무엇일까 ? 😮
ECMAScript 2015로도 알려져 있는 ECMAScript 6는 ECMAScript 표준의 가장 최신 버전. ES6는 새로운 언어 기능이 포함된 주요 업데이트이며, 2009년도에 표준화된 ES5 이후로 언어 기능에 대한 첫 업데이트이기도 하다. 현재 주요 JavaScript 엔진들에서 ES6 기능들을 구현하고 있음. ES란, ECMAScript의 약자이며 자바스크립트의 표준, 규격을 나타내는 용어이다. 뒤에 숫자는 버전을 뜻하고 ES5는 2009년 ES6는 2015년에 출시 !

> ## ES6은 아래와 같은 새로운 기능들을 포함 🟢
- const&let
- Arrow functions(화살표 함수)
- Template Literals(템플릿 리터럴)
- Default parameters(기본 매개 변수)
- Array and Object destructing(배열 및 객체 비구조화)
- Import and export(가져오기 및 내보내기)
- Promises(프로미스)
- Rest parameter and Spread operator(나머지 매개 변수 및 확산 연산자)
- Classes(클래스)

> ## ES6 문법 📗
### **const&let**
```const```는 변수 선언을 위한 ES6의 새로운 키워드, ES5에서 사용되던 ```var``` 보다 강력하고 일단사용되면 다시 할당할 수 없다. 즉, 객체와 함께 사용할 때를 제외하고는 <mark>변경 불가능한 변수.</mark>

### **hoisting**
JavaScript에서 호이스팅(hoisting)이란, 인터프리터가 변수와 함수의 메모리 공간을 선언 전에 미리 할당하는 것을 의미합니다. ```var```로 선언한 변수의 경우 호이스팅 시 ```undefined```로 변수를 초기화합니다. 반면 ```let```과 ```const```로 선언한 변수의 경우 호이스팅 시 변수를 초기화하지 않습니다.
<br><br>
```Javascript
catName("클로이"); // 함수 선언

function catName(name) {
  console.log("제 고양이의 이름은 " + name + "입니다");
} //함수 자체

/*
결과: "제 고양이의 이름은 클로이입니다"
*/
```
함수를 선언하기 전에 먼저 호출했을 때의 예제, 함수 호출이 함수 자체보다 앞서 존재하지만, 동작 !
호이스팅은 다른 자료형과 변수에도 잘 작동. <mark>변수를 선언하기 전에 먼저 초기화하고 사용할 수 있다.</mark>
<br><br>
```Javascript
console.log(num); // 호이스팅한 var 선언으로 인해 undefined 출력
var num; // 선언
num = 6; // 초기화
```
JavaScript는 초기화를 제외한 선언만 호이스팅. 변수를 먼저 사용하고 그 후에 선언 및 초기화가 나타나면, 사용한는 시점의 변수는 기본 초기화 상태(```var``` 선언 시 ```undefined```, 그 외에는 초기화하지 않음)

### **Array and object destructing(배열 및 객체 비구조화)**
>비구조화를 통해 배열 또는 객체의 값을 새 변수에 더 쉽게 할당할 수 있다.

**이전문법 🚶‍♀️**
```Javascript
// ES5 문법
const contacts = {
	famillyName: '이',
	name: '영희',
	age: 22
};

let famillyName = contacts.famillyName;
let name = contacts.name;
let myAge = contacts.age;

console.log(famillyName);
console.log(name);
console.log(age);
// **출력**
// 이
// 영희
// 22
```
**ES6 문법 사용  🏃‍♀️**
```Javascript
// ES6 문법
const contacts = {
	famillyName: '이',
	name: '영희',
	age: 22
};

let { familyName, name, age } = contacts;

console.log(familyName);
console.log(name);
console.log(age);
// 출력
// 이
// 영희
// 22
```
ES5에서는 각 변수에 각 값을 할당해야한다. ES6에서는 객체의 속성을 얻기 위해 값을 중괄호 안에 넣는다.

<mark>**참고**</mark> : 속성 이름과 동일하지 않은 변수를 할당하면 ```undefined```가 반환. 예를 들어, 속성의 이름이 ```name```이고 ```username``` 변수에 할당하면 ```undefined```를 반환

우리는 항상 속성의 이름과 동일하게 변수 이름을 지정해야 한다. 그러나 변수의 이름을 바꾸려면 콜론을 ```:``` 대신 사용할 수 있다.
```Javascript
// ES6 문법
const contacts = {
	famillyName: '이',
	name: '영희',
	age: 22
};

let { familyName, name: otherName, age} = contacts;

console.log(otherName);
//영희
```
<br>
배열의 경우 객체와 동일한 구문을 사용. 중괄호를 대괄호로 바꾸면 된다.

```Javascript
const arr = ['광희', '지수', '영철', 20];

let [value1, value2, value3] = arr;
console.log(value1);
console.log(value2);
console.log(value3);
// **출력**
// 광희
// 지수
// 영철
```
<br>

### **Import and export(가져오기 및 내보내기)**
JavaScript 응용프로그램에서 improt 및 export를 사용하면 성능이 향상. 이를 통해 별도의 재사용 가능한 구성요소를 작성할 수 있다. JavaScript MVC 프레임워크에 익숙한 경우, 대부분의 경우 import 및 export를 사용하여 구성 요소를 처리.

**export**를 사용하면 다른 JavaScript 구성 요소에 사용할 모듈을 내보낼 수 있다. 우리는 그 모듈을 우리의 컴포넌트에 사용하기 위해 가져오기 **import**를 사용 
<br>
<br>

예를 들어, 두 개의 파일이 있다. 첫 번째 파일은 ```detailComponent.js```이고 두 번째 파일은 ```homeComponent.js```다.

```detailComponent.js```에서는 ```detail``` 함수를 내보낼 예정이다.
```Javascript
// ES6
export default function detail(name, age) {
	return `안녕 ${name}, 너의 나이는 ${age}살 이다!`;
}
```
그리고 ```homeComponent.js```에서 이 기능을 사용하려면 ```import```만 사용한다.
```Javascript
import detail from './detailComponent';

console.log(detail('영희', 20));
// 출력 => 안녕 영희, 너의 나이는 20살 이다!
```
둘 이상의 모듈을 가져오려는 경우, 중괄호에 넣기만 하면 된다.
```Javascript
import { detail, userProfile, getPosts } from './detailComponent';

console.log(detail('영희', 20));
console.log(userProfile);
console.log(getPosts);
```
<br>

### **Promises(프로미스)**
Promise는 ES6의 새로운 특징, 비동기 코드를 쓰는 방법. 예를 들어 API에서 데이터를 가져오거나 실행되는데 시간이 걸리는 함수를 가지고 있을 때 사용할 수 있다. Promise는 문제를 더 쉽게 해결할 수 있다.
```Javascript
const myPromise = () => {
		return new Promise((resolve, reject) => {
			resolve('안녕하세요 Promise가 성공적으로 실행했습니다.');
});
};

console.log(myPromise());
// Promise {<resolved>: "안녕하세요 Promise가 성공적으로 실행했습니다."}
```
콘솔을 기록하면 Promise가 반환. 따라서 데이터를 가져온 후 함수를 실행하면 Promise를 사용. Promise는 두 개의 매개 변수를 사용하여 ```resolve```및 ```reject``` 예상 오류를 처리할 수 있다.

<mark>참고</mark> fetch 함수는 Promise자체를 반환 !
```Javascript
const url = 'https://jsonplaceholder.typicode.com/posts';
const getData = (url) => {
	return fetch(url);
};

getData(url).then(data => data.json()).then(result => console.log(result));
```
이제 콘솔을 기록하면 데이터 배열이 반환.

<br>

### **Rest parameter and Spread operator(나머지 매개 변수 및 확산 연산자)**
>Rest parameter는 배열의 인수를 가져오고 새 배열을 반환하는데 사용.

```Javascript
const arr = ['영희', 20, '열성적인 자바스크립트', '안녕', '지수', '어떻게 지내니?'];

// 비구조화를 이용한 값을 얻기
const [ val1, val2, val3, ...rest ] = arr;

const Func = (restOfArr) => {
	return restOfArr.filter((item) => {return item}).join(" ");
};

console.log(Func(rest)); // 안녕 지수 어떻게 지내니?
```
>Spread operator는 Rest parameter와 구문이 동일하지만 Spread operator는 인수뿐만 아니라 ```배열 자체```를 가짐. for 반복문이나 다른 메서드를 사용하는 대신 Spread operator를 사용하여 배열의 값을 가져올 수 있다.

```Javascript
const arr = ['영희', 20, '열성적인 자바스크립트', '안녕', '지수', '어떻게 지내니?'];

const Func = (...anArray) => {
	return anArray;
};

console.log(Func(arr));
// 출력 => ["영희", 20, "열성적인 자바스크립트", "안녕", "지수", "어떻게 지내니?"]
```
<br>

### **Classes(클래스)**
class를 만들려면 ```class``` 키워드 뒤에 두 개의 중괄호가 있는 class 이름을 사용
```Javascript
class myClass{
		constructor() {
		}
}
```
이제 ```new``` 키워드를 사용하여 class 메서드와 속성에 엑세스할 수 있다.
```Javascript
class myClass{
		constructor(name, age){
				this.name = name;
				this.age = age;
		}
}

const user = new myClass('영희', 22);

console.log(user.name); // 영희
console.log(user.age); // 22
```
다른 class에서 상속하려면 ```extends``` 키워드 다음에 상속할 class의 이름을 사용
```Javascript
class myClass {
	constructor(name, age) {
		this.name = name;
		this.age = age;
	}

	sayHello() {
		console.log(`안녕 ${this.name} 너의 나이는 ${this.age}살이다`);
	}
}

//myClass 메서드 및 속성 상속
class UserProfile extends myClass{
		userName(){
	console.log(this.name);	
	}
}

const profile = new UserProfile('영희',22);

profile.sayHello(); // 안녕 영희 너의 나이는 22살이다.
profile.userName(); // 영희
```