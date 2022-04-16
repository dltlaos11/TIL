/*printInteger(int aNumber){
  print('The number is $aNumber'); // 콘솔에 출력
}

main() {
  var number = 42; // 동적 타입 변수 지정
  printInteger(number); // 함수 호출
}
*/

/*int? couldReturnNullButDoesnt() => -3; // null을 넣을 수 잇음

void main() {
  int? couldBeNullButIsnt = 1; // null로 변경 가능
  List<int?> listThatCouldHoldNulls = [2, null, 4]; // List의 int에 null 값 포함 가능
  List<int?> nullList; // List 자체가 null일 수 있음
  int a = couldBeNullButIsnt; // null을 넣으면 오류
  // int b = listThatCouldHoldNulls.first; // int b는 ?가 없으므로 오류
  int b = listThatCouldHoldNulls.first!; // null이 아님을 직접 표시
  // int c = couldReturnNullButDoesnt().abs(); // null 일수도 있으므로 abs()에서 오류
  int c = couldReturnNullButDoesnt()!.abs(); // null이 아님을 직접 표시

  print('a is $a.');
  print('b is $b.');
  print('c is $c.');

  // null이 아님을 직접 표시하는 것은 함수나 변수뒤에 !를 붙이면 Null이 아님을 직접 표시
  // 자료형 다음에 ?를 붙이면 Null이 가능하고, 붙이지 않으면 Null이 불가능
*/


/*
// 😀 2단부터 9단까지 순차적으로 나오는 구구단 프로그램 완성
//  for문을 이용한 반복문 생성
//  print를 이용한 결과값 출력
void main(){
  int i;
  int j;

  for (i = 2; i<=9; i++){
    print("-------------");
    for (j = 1; j<=9; j++){
      print('$i * $j = ${i * j}');
    }
  }
}
*/

/*
// 😀 비동기 프로세스의 작동 방식
// async와 await 키워드를 이용해 비동기 처리 구현
// 구현 방식
// 1. 함수 이름 뒤, 본문이 시작하는 중괄호 { 앞에 async 키워드를 붙여 비동기로 만든다.
// 2. 비동기 함수 안에서 언제 끝날지 모르는 작업 앞에 await 키워드를 붙인다.
// 3. 2번 작업을 마친 결과를 얻기 위해 비동기 함수 이름 앞에 Future(값이 여러 개면 Stream) 클래스를 지정한다.
void main() {
  checkVersion();
  print('end process');
}
Future checkVersion() async {
  var version = await lookUpVersion();
  print(version);
}
int lookUpVersion() {
  return 12;
}
// 😀 비동기 처리 예제
// 일반적인 흐름
// main() 함수에서 제일 먼저 checkVersion() 함수를 호출했으므로 checkVersion() 함수에 있는 lookUpVersion() 함수가 호출되어
// 12를 전달받아 출력한 다음, 다시 main() 함수로 돌아와서 'end process'가 출력될 것으로 보이나 실제 출력 결과는 다름

// 😀 비동기 처리 흐름
// checkVersion() 함수 이름 앞뒤로 Future와 async가 있음 -> 비동기 처리 함수 !
// checkVersion() 함수 안에 await가 붙은 함수를 따로(비동기로) 처리한 다음 그 결과는 Future 클래스에 저장해 둘 테니 먼저
// checkVersion() 함수를 호출한 main() 함수의 나머지 코드를 모두 실행하라('end process' 출력)는 의미 !
// 그리고 main() 함수를 모두 실행했으면 그떄 Future 클래스에 저장해 둔 결과를 이용해서 checkVersion() 함수의 나머지 코드를
// 실행함('12' 출력) !
// lookUpVersion() 함수 앞에 await 키워드가 있음
// await 키워드는 처리를 완료하고 결과를 반환할 때까지 이후 코드의 처리를 멈춤
// 따라서 lookUpVersion() 함수를 호출해 version 변수에 12가 저장된 다음에야 비로서 print(version) 문으로 이를 출력

// 이처럼 비동기 함수에서 어떤 결과값이 필요하다면 해당 코드를 await로 지정
// 그러면 네트워크 지연 등으로 제대로 된 값을 반환받지 못한 채 이후 과정이 실행되는 것을 방지할 수 있음
// 이러한 비동기 처리를 이용하면 지연(delay)이 발생하는 동안 애플리케이션이 멈춰 있지 않고 다른 동작을 하게 할 수 있음.
*/

/*
// 😀 비동기 함수가 반환하는 값 활용하기
// 비동기 함수 반환 값 처리
// 비동기 함수가 반환하는 값을 처리하려면 thwn() 함수 이용

// 비동기 함수 반환 값 예제
// lookUpVersionName()에서  리턴한 값을 getVersionName() 함수에서 호출
// then(value) => { } 함수를 이용하여 value의 값을 출력

void main() async {
  await getVersionName().then((value) => {
    print(value)
});
  print('end process');
}

Future<String> getVersionName() async {
  var versionName = await lookUpVersionName();
  return versionName;
}

String lookUpVersionName() {
  return 'Android 0';
}

// Future<String>이라는 반환 값을 정해 놓은 getVersionName() 함수가 있음
// 이 함수는 async 키워드가 붙어 있으므로 비동기 함수임
// 비동기 함수가 데이터를 성공적으로 반환하면 호출하는 쪽에서 then() 함수를 이용해 처리할 수 있음
// then() 이외에 error() 함수도 이용 가능
// error() 함수는 실행 과정에서 오류가 발생했을 떄 호출되므로 이를 이용해 예외 처리 가능
*/

/*
// 😀 Dart
// 하나의 스레드로 동작하는 프로그래밍 언어
// await 키워드 활용 예제
// Future.delayed() 함수는 Duration 기간 동안 기다린 후에 진행
// Duration에는 분(minutes)이나 밀리초(milliseconds) 등 다양한 값을 넣을 수 있음

void main() {
  printOne();
  printTwo();
  printThree();
}

void printOne() {
  print('One');
}

void printThree() {
  print('Three');
}

void printTwo() async {
  await Future.delayed(Duration(seconds: 1), () {
    print('Future');
  });
  print('Two');
}
// Future.delayed() 코드 앞에 await 키워드를 붙였으므로 이후 코드의 실행이 멈춤
// 따라서 pirntTwo() 함수를 벗어나 main() 함수의 나머지 코드를 모두 실행하고, 그 다음에 await가 붙은 코드부터 차례대로 실행
// 이처럼 await 키워드를 이용하면 await가 속한 함수를 호출한 쪽(예제: main() 함수)의 프로세스가 끝날 때까지 기다리기 떄문에 이를 잘 고려해야 함.
// await 함수 호출시, 오버헤드 시간이 좀 걸릴 수 있다 !
*/

/*
// 😀 Dart JSON Decoding
//  JSON을 사용하려면 소스에 convert라는 라이브러리를 포함해야 함
// JSON 데이터 디코딩 예제
// jsonDecode() 함수에 전달한 후 그 결과를 scores 변수에 저장
// jsonDecode() 함수는 JSON 형태의 데이터를 dynamic 형식의 리스트로 변환해서 반환해 둠.
import 'dart:convert';

void main() {
  var jsonString = '''
  [
    {"score":40},
    {"score":60}
  ]
  ''';
  var scores = jsonDecode(jsonString);
  print(scores is List); // True
  var firstScore = scores[0];
  print(firstScore is Map); // True
  print(firstScore['score'] == 40); // True
}

// jsonString 변수에 저장된 데이터가 JSON 형태의 문자열 !!
// 키(key)와 값(value)이 있는 Map 형태

// 😀 Dart JSON Encoding
// 애플리케이션에서 서버로 데이터를 보내는 예
// jsonEncode() 함수를 이용해 JSON 형태로 반환한 데이터를 서버로 저장
*/

/*
// JSON 데이터 인코딩 예제
// Map을 jsonEncode() 함수를 이용하여 변경
// 변경후 서버에 전달할 수 있도록 json 형태의 String으로 변환
import 'dart:convert';
void main() {
  var scores = [
    {'score':40},
    {'score':60}
  ];

  var jt=jsonEncode(scores);
  print(jt ==
    '[{"score":40},'
   '{"score":60}]'
  );
}
// 앞의 코드에서 {"score": 40}처럼 키에 큰따옴표 사용해 JSON 데이터임을 표시,
// {'score': 40}처럼 작은 따옴표를 이용하면 변수임을 표시
// 이 scores 데이터를 인자로 jsonEncode() 함수를 호출하면 키값이 큰 따옴표로 묶이고 전체 데이터를 작은 따옴표로
// 한번 묶어서 JSON 데이터가 됨
// 이처럼 다트는 간단하게 JSON을 만들고 파싱하여 데이터를 주고 받는 기능을 제공공 //
*/

/*
// 😀 스트림
//  순서를 보장받고 싶은 경우
//  예를 들어, 데이터를 순서대로 주고받을 것으로 생각해서 화면을 구성, 네트워크나 와이파이 연결이 끊기거나 특정 API 호출이
//  늦어져 순서가 달라지면 애플리케이션이 원하는 흐흠대로 작동하지 않을 수도 있음
// 스트림 통신 예제

import 'dart:async';

Future<int> sumStream(Stream<int> stream) async {
  var sum =0;
  await for (var value in stream) {
    print('sumStream: $value');
    sum += value;
  }
  return sum;
}

Stream<int> countStream(int to) async* {
  for(int i =0; i<=to; i++){
    print('countStream: $i');
    yield i;
  }
}

main() async {
  var stream = countStream(10);
  var sum = await sumStream(stream);
  print(sum);
}
// main() 함수
//  먼저 countStream(10) 함수를 호출
//  이 함수는 async*와 yield 키워드를 이용해 비동기 함수로 만들었음
//  이 함수는 for문을 이용해 1부터 to로 전달받은 숫자까지 반복
// async* 명령어
//  앞으로 yield를 이용해 지속적으로 데이터를 전달하겠다는 의미
//  이 코드에서 yield는 int형 i를 반환하는데, return은 한 번 반환하면 함수가 끝나지만, yield는 반환후에도 계속 함수를 유지함.
// 이렇게 받은 yield값을 인자로 sumStream() 함수를 호출하면 이 값이 전달될 때마다 sum 변수에 누적해서 반환
// 그리고 main() 함수에서 이값을 받아 출력하면 55
// 스트림을 이용하면 데이터를 차례대로 받아서 처리가능
*/

// then() 함수 활용 예제
//  Stream 클래스를 이용해 배열을 하나 만든 후 함수를 이용해 값을 가져옴
//  그런 다음 then() 함수로 가져다 사용
//  오류 발생 > 일단 스트림을 통해 데이터를 사용하면 데이터는 사라짐. 따라서 다음처럼 한번 만 실행하도록 변경해야 함.
main() {
  var stream = Stream.fromIterable([1,2,3,4,5]);

  // 가장 마지막 데이터의 결괴: 5
  stream.last.then((value) => print('last: $value'));
}
// 스트림 통신 사용 예
//  실시간으로 서버를 살펴보다가 서버에서 데이터가 변경되면 화면을 새로 고침하지 않더라도 자동으로 변경된 데이터가
//  반영되어야 할 때 사용할 수 있는 유용한 클래스스