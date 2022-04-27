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