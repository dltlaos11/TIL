# ES6에서의 순회와 이터러블:이터레이터 프로토콜 
## 기존과 달라진 ES6에서의 리스트 순회 🟢
- for i++
- for of
```javascript
<script>const log = console.log;</script>

<script>
    //ES5
    const list = [1, 2, 3];
    for(var i =0; i < list.length; i++) {
        log(list[i]); // 1 2 3
    }
    const str = 'abc';
    for(var i =0; i<str.length; i++) {
        log(str[i]); // a b c
    }
    //ES6
    for(const a of list){
        log(a); // 1 2 3
    }
    for(const a of str){
        log(a); // a b c
    }
</script>
```

## 이터러블/이터레이터 프로토콜 🟢
- 이터러블: 이터레이터를 리턴하는 [Symbol.iterator] () (method)를 가진 값
- 이터레이터: {value, done} 객체를 리턴하는 next()를 가진 값
- 이터러블/이터레이터 프로토콜: 이터러블을 for..of, 전개 연산자 등과 함께 동작하도록한 규칙(JS안에 있는 array, set, map은 내장객체로서 이터러블/이터레이터 프로토콜을 따름)
<img src="https://s3.us-west-2.amazonaws.com/secure.notion-static.com/11316956-8bdc-45dd-b12c-4c6ea338569f/Untitled.png?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Content-Sha256=UNSIGNED-PAYLOAD&X-Amz-Credential=AKIAT73L2G45EIPT3X45%2F20220427%2Fus-west-2%2Fs3%2Faws4_request&X-Amz-Date=20220427T084708Z&X-Amz-Expires=86400&X-Amz-Signature=874cc921154daae0b939710e5c542e0b32b2e245ce49c8029ddb9460e1c84d60&X-Amz-SignedHeaders=host&response-content-disposition=filename%20%3D%22Untitled.png%22&x-id=GetObject"/><br>
array는 이터러블, array는 Symbol.iterator를 가지고 있고 arr[Symbol.iterator] ()의 반환값으로 이터레이터를 가짐. 이터레이터의 next() 메서드 적용시 {value, done} 가지고있는 객체를 리턴, value를 출력하는 것
<img src="https://s3.us-west-2.amazonaws.com/secure.notion-static.com/8627723f-ebee-4261-9ae5-c9a3446f5a55/Untitled.png?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Content-Sha256=UNSIGNED-PAYLOAD&X-Amz-Credential=AKIAT73L2G45EIPT3X45%2F20220427%2Fus-west-2%2Fs3%2Faws4_request&X-Amz-Date=20220427T090634Z&X-Amz-Expires=86400&X-Amz-Signature=c09a99008dc417f5025016c4a88c36c04c7f604c72343a4fb260f95a43b8433a&X-Amz-SignedHeaders=host&response-content-disposition=filename%20%3D%22Untitled.png%22&x-id=GetObject"/><br>
map도 마찬가지

<img src="https://s3.us-west-2.amazonaws.com/secure.notion-static.com/79556b7c-b61a-4817-bdb5-57071eb0a576/Untitled.png?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Content-Sha256=UNSIGNED-PAYLOAD&X-Amz-Credential=AKIAT73L2G45EIPT3X45%2F20220427%2Fus-west-2%2Fs3%2Faws4_request&X-Amz-Date=20220427T090805Z&X-Amz-Expires=86400&X-Amz-Signature=ce272f91c860a35795fc1eaf897dc2caa1725e43c91e29139e9466a73c016ff9&X-Amz-SignedHeaders=host&response-content-disposition=filename%20%3D%22Untitled.png%22&x-id=GetObject"/> <br>
map은 map.keys(), map.entries(), map.values()가 있다. 
<br><br>

## 이터러블/이터레이터 프로토콜 🟢
```javascript
<script>const log = console.log;</script>

<script>
    const iterable = {
        [Symbol.iterator] () { // Symbol.iterator method를 구현하고 있어야 한다.
            let i = 3;
            return {// iterator를 반환해야 한다.
                next() { //iterator는 next()를 method로 가지고 있음.
                    return i == 0 ? { done:true } : { value: i--, done: false }; //next는 value와 done을 가지고 있는 객체를 반환해야 한다.
                },
                [Symbol.iterator](){  // iterator도 iterable이 되도록 🟢
                                      // 사용자 정의 iterable이 well-formed iterator를 반환할 수 있도록 하기 위해서 자기 자신 또한 iterable이면서
                                      // 또 [Symbol.iterator] ()를 실행했을 떄 자기 자신을 return 하도록 해서 계속해서 중간에 다시 한번
                                      // for...of문에 들어간다거나 어디에서든 [Symbol.iterator]()로 iterator로 만들었을 떄 이전까지 진행되던
                                      // 자기 상태에서 계속해서 next()를 할 수 있도록 만들어둔 것이 well-formed iterator/iterable이다. 
                                      return this; // iterable 객체의 반환 값 !
                }
            }
        }
    };
    let iterator = iterable[Symbol.iterator]();
    // log(iterator.next());
    // log(iterator.next());
    // log(iterator.next());
    // log(iterator.next());

    for(const a of iterable) {// iterable에 [Symbol.iterator]()가 구현되어 있기에 for...of문이 가능, 내부적으로 next() 실행
        log(a);
    }
    for(const a of iterator) {// iteator도 iterable이 되도록 만들면 iterator/iterable 둘다 순회가 됨. => well-formed iterator 👩🏼
        log(a);
    }

    // const arr2 = [1, 2, 3];
    // let iter2 = arr2[Symbol.iterator]();
    // // iter2.next(); 2, 3
    // log(iter2[Symbol.iterator] () == iter2); // true, 이처럼 이터레이터가 자기 자신을 반환하는 [Symbol.iterator]() method를 가지고 있을 떄
    //                                          // well-formed iterator/iterable이라고 부른다. 
    // for (const a of iter2) log(a);

    // 브라우저에서 사용할 수 있는 DOM과 관련된 값이나 JS에서 순회가 가능한 내장 값들은 이터레이터/이터러블 프로토콜을 따른다.
    for (const a of document.querySelectorAll('*')) log(a);
    const all = document.querySelectorAll('*');
    log(all); // 이런식으로 순회를 할 수 있는 이유는 all이라는 값이 배열이여서가 아니라 [Symbol.iterator]가 구현되어 있어서 !
    let iter3 = all[Symbol.iterator](); //[Symbol.iterator]()를 실행했을 떄 이터레이터를 만들고 Array Iterator {}
    log(iter3.next());
    log(iter3.next());
    log(iter3.next()); // 내부 값 순서대로 출력
</script>
```
JS에서 새롭게 바뀐 순회 for...of문, iterator/iterable은 중요 !
<br><br>
## 전개 연산자 🟢
```html
<script>const log = console.log;</script>

<script>
    console.clear();
    const a = [1, 2];
    // a[Symbol.iterator] = null ; // a is not iterable이라는 error가 뜸
    log([...a, ...[3,4]]); // [1 2 3 4], 전개 연산자 역시 iterable 프로토콜을 따르고 있는 값들을 가짐
</script>
```