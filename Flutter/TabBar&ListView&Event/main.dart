import 'package:flutter/material.dart';
import 'package:listview_example/sub/firstPage.dart';
import 'package:listview_example/sub/secondPage.dart';
import './animalItem.dart';

void main() {
  // runApp(MyApp());
  runApp(CupertinoMain());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tabbar Example',
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with SingleTickerProviderStateMixin{
  // SingleTickerProviderStateMixin : Tab 컨트롤러에 대한 처리를 담당하는 class,(this 오류 해결)
  // SingleTickerProviderStateMixin 클래스를 상속받지 않으면 탭 컨트롤러를 만들 수 없음
  // with : 여러 클래스를 재사용할 수 있는 키워드
  TabController? controller;
  List<Animal> animalList = new List.empty(growable: true);
  // List 선언시 빈 값이므로 List.empty(growable: true)로 선언
  // (growable: true) : 가변적으로 변경될 수 있음을 true로

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('TabBar Example'),
      ),
      body: TabBarView(
        children: <Widget> [FirstApp(list: animalList), SecondApp(list: animalList,)],
        //
        controller: controller,
      ),
      bottomNavigationBar: TabBar(tabs: <Tab> [
        Tab(icon: Icon(Icons.looks_one, color: Colors.blue,) ),
        Tab(icon: Icon(Icons.looks_two, color: Colors.blue,) )
      ], controller: controller),
    );
  }
  @override
  void initState() {
    super.initState();
    controller = TabController(length: 2, vsync: this);
    // TabcController 탭의 위치나 애니메이션 상태 등을 확인할 수 있는 기능 제공, 탭이 이동할 떄 어떤 동작을 추가하고 싶으면 addListener() 함수 이용

    animalList.add(Animal(animalName: "bear",kind: "animal",  imagePath: "repo/images/bear.png"));
    animalList.add(Animal(animalName: "cow",kind: "animal",  imagePath: "repo/images/cow.png"));
    animalList.add(Animal(animalName: "fox",kind: "animal",  imagePath: "repo/images/fox.png"));
    animalList.add(Animal(animalName: "gorillad",kind: "animal",  imagePath: "repo/images/gorilla.png"));
    animalList.add(Animal(animalName: "horse",kind: "animal",  imagePath: "repo/images/horse.png"));
    animalList.add(Animal(animalName: "mouse",kind: "animal",  imagePath: "repo/images/mouse.png"));
    animalList.add(Animal(animalName: "penguin",kind: "animal",  imagePath: "repo/images/penguin.png"));
    animalList.add(Animal(animalName: "racoon",kind: "animal",  imagePath: "repo/images/racoon.png"));
    animalList.add(Animal(animalName: "tiger",kind: "animal",  imagePath: "repo/images/tiger.png"));
    animalList.add(Animal(animalName: "gosun",kind: "animal",  imagePath: "repo/images/gosun.png"));

  }
  // this -> _MyHomePageState
@override
  void dispose() {
  controller!.dispose();
  super.dispose();
  }
  // Tab이동과 관련된 처리 -> with 키워드 추가, 단일상속 그 이상의 클래스를 상속 가능하다. Tabcontroller 지정가능
  // 애니매이션효과 메모리 많이 차지 -> 애니메이션 적정히 낭비를 줄이기 위해서 App이 dispose됬을떄 controller도 같이 dispose될 수 있도록
  // dispose() 함수 오버라이드함 그래서 탭 화면 전환시 메모리 줄일 수 있다.

}
