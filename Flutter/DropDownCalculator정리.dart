import 'dart:html';

import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  var res = '';
  var val1 = '';
  var val2 = '';
  var res1 = 0.0;

  IconData ic1=Icons.icecream_outlined;
  List _dropdownList = ['ADD', 'SUB', 'MUL', 'DIV'];
  List<DropdownMenuItem<String>> li = new List.empty(growable: true);
  String? dropDownText;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    for(var items in _dropdownList){
      li.add(DropdownMenuItem(child: Text(items), value: items,));
    }
    dropDownText = _dropdownList[0];
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dropdown Calculator',
      home: Scaffold(
        appBar: AppBar(
          title: Text("Widget Example"),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text("Result: $res"),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                onChanged: (val){
                  val1 = val;
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                onChanged: (val){
                  val2 = val;
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(onPressed: (){
                setState(() {
                  setState(() {
                    if(dropDownText == 'ADD'){
                      res1 = double.parse(val1) + double.parse(val2);
                      res = res1.toString();
                    } else if(dropDownText == 'SUB'){
                      res1 = double.parse(val1) - double.parse(val2);
                      res = res1.toString();
                    }else if(dropDownText == 'MUL'){
                      res1 = double.parse(val1) * double.parse(val2);
                      res = res1.toString();
                    }else
                      res1 = double.parse(val1) / double.parse(val2);
                      res = res1.toString();
                  });
                });
              },
                  child: Row(
                children: [
                  Icon(ic1),
                  Text("$dropDownText")
                ],
              ),
                style: ButtonStyle(backgroundColor:
                MaterialStateProperty.all(Colors.amber))),
            ),
            DropdownButton(items: li, onChanged:(String? val){
              dropDownText = val;
             setState(() {
               if(dropDownText == 'ADD'){
                 ic1 = ic1;
               } else if(dropDownText == 'SUB'){
                 ic1 = Icons.ice_skating_outlined;
               }else if(dropDownText == 'MUL'){
                 ic1 = Icons.access_time_filled;
               }else ic1 = Icons.ac_unit_rounded;
             });
            }, value: dropDownText,)

          ],
        ),
      ),
    );
  }
}

// MaterialApp() 함수
//  title: 앱의 이름을 정의
//  theme: 앱의 색이나 설정을 정의, 메인 색상을 지정하는 primarySwatch, visualDensity 속성은 앱이 다양한 플랫폼에 적응적으로 보이도록 정의
//  home: 앱을 실행할 때 첫 화면에 어떤 내용을 표시할지 정의

// Container
//  플러터에서 가장 많이 사용하는 위젯 중 하나로 특정 공간을 책임지는 역할
//  그 공간에서 배경색이나 정렬, 여백 등 다양한 역항을 담당하는 위젯
//  color 지정 !

// 텍스트 가운데 정렬
//  Text()함수에 두번째 인자로 textAlign속성 추가하고, TextAlign.center값을 추가
//  Center로 Wrap하면 화면 정중앙으로 옴 !
//  style 옵션 추가 가능 !

// child 옵션
//  자신 아래 어떤 위젯을 넣겠다는 의미
//  하나일 경우 child, 여러 위젯을 넣고 싶을때는 children 옵션 사용 !
//  Row, Column 사용시 children 안에 위젯 넣음 !

// Scaffold를 이용해 스위치를 구성
//  Scaffold 클래스(위젯)은 Appbar나 아래 네비게이션 바, 우하단 +버튼 등 자주쓰이는 위젯을 포함하고있는 클래스

// 스테이트풀 위젯은 State 클래스를 필요함
// State 클래스를 상속받는 _MyApp클래스를 만들고, 그 안에 위젯을 담음
// Stateful 클래스를 상속받는 MyApp은 createState() 함수를 재정의하고 호출
// MyApp클래스가 현재 화면을 주시하다가 상태 변경이 되면 이를 감지하고 _MyApp 클래스가 화면을 갱신

// 화면의 값을 변경하기 위해서는 setState() 함수내에서, 변경 값이 화면에 반영(갱신)
// 주로 이벤트 안에서 사용, 변수는 위젯 빌드 위에서 선언 !! 😀

// 버튼을 눌러 텍스트 변경
//  ElevatedButton 위젯 사용
//  버튼 위젯에도 child 선언 가능
//  child를 선언해 Text에 문자열 변수 test 대입
//  onPress 함수 이벤트 처리
//  ElevatedButton 색 변경 하려면 style: ButtonStyle(backgroundColor: MaterialStateProperty.all(co))
//  MaterialStateProperty.all(변수선언)을 해주어야 함

// State와 StatefulWidget 클래스의 분리 이유
//  StatefulWidget보다 State 클래스가 상대적으로 더 무겁기 때문
//  StatefulWidget에서 감시하고 있다가 상태 변경 신호가 오면 State 클래스가 화면을 갱신하도록 구현
//  만약 StatefulWidget에서 바로 갱신하면 나중에 화면이 종료되어도 할당받은 메모리를 없앨 때까지 오랜 시간이 걸릴 수 있음.
//  따라서 상태 변경 감시는 StatefulWidget 클래스가 담당하고, 실제 갱신 등은 State 클래스가 담당하도록 분리

// 화면에 표시하는 build() 함수
//  Widget을 반환 >> 즉, 위젯을 화면에 렌더링

// DropdownButton 생성
//  items: dropdown에 표시할 아이템 목록
//  onChanged: 아이템이 바뀔때 이벤트 처리
//  리스트 _buttonList 선언하고 아이템 입력
//  DropdownButton 형식 리스트 하나 더 선언

// =====================================================================================================================================================
// 만들면서 헷갈렸던 부분들

// dropdown
// 1. Appbar -
// home: Scaffold(
//     appBar: AppBar(
//         title: Text(""),
//     )
// )
// 2. ElevatedButton_backgroundcolor -
// ElevatedButton( style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.amber)))
// 3. double.parse, toString()
// 4.build 전에 수행가능하지만 생명주기 활용
// 상태 초기화하는 initState() 함수에서 작성
//     for(var items in _dropdownList){
//       li.add(DropdownMenuItem(child: Text(items), value: items,));
//     }