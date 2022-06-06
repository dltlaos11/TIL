# main.dart
```dart
import 'package:flutter/material.dart';
import 'package:navigation/SecondDetail.dart';
import 'package:navigation/ThirdPage.dart';
import 'package:navigation/subDetail.dart';

// 내비게이션
// 앱이 제공하는 기능이나 메뉴별로 화면을 분리해서 개발하는 방법
// 데이터 주고 받으며 화면 전화

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  static const _title = 'Widhet Example';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: _title,
      theme: ThemeData(
        primarySwatch: Colors.green
      ),
      // home: FirstPage(),
      initialRoute: '/',
      routes: {
        '/' : (context) => SubDetail(),
        '/second' : (context) => SecondDetail(),
        '/third' : (context) => ThirdDetail()
      },
    );
  }
}
// home property에 대한 수정
// home 대신에 initialRoute와 routes 사용
// routes에는 <String : Widget> 형태로 경로를 선언
// String에 경로로 사용할 문자열을 입력, Widget에는 해당 경로가 가리키는 위젯을 지정
// '/'와 '/second'에 각각 FirstPage와 SecondPage를 지정
// initialRoute에는 처음 앱을 시작했을 때 보여줄 경로 지정용

// pushNamed() 함수는 스택에 추가
// pushReplacement() 함수는 스택에 교체

class FirstPage extends StatefulWidget {

  @override
  State<FirstPage> createState() => _FirstPageState();
}

class _FirstPageState extends State<FirstPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sub Page Wait'),
      ),
      body: Container(
        child: Center(
            child: Text('First Page')
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          Navigator.of(context).push(MaterialPageRoute(builder: (context) => SecondPage()));
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
// Navigator
// 스택(stack)을 이용해 페이지를 관리할 때 사용하는 클래스
// Navigator 클래스의 Of(context) 함수는 현재 페이지를 나타냄
// push() 함수는 스택에 페이지를 쌓는 역할
// 플로팅 버튼을 눌렀을 떄 스택 메모리에 페이지가 쌓이는 구조

// push() 함수에 전달한 MaterialPageRoute() 함수는 머티리얼 스타일로 페이지를 이동하게 해줌
// 앱 실행해서 플로팅 버튼을 누르면 페이지가 이동하는 애니메이션 확인

class SecondPage extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Second Page'),
      ),
      body: Container(
        child: Center(
          child: ElevatedButton(
            onPressed: (){
              Navigator.of(context).pop();
            },
            child: Text('Back'),
          ),
        ),
      ),
    );
  }
}
// Navigator.of() 함수의 pop()함수
// 스택 메모리에서 맨 위에 있는 페이지를 제거
```