import 'package:flutter/material.dart';
import 'package:hi/sub/firstPage.dart';
import 'package:hi/sub/secondPage.dart';

void main() {
  runApp(MyApp());
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
  // SingleTickerProviderStateMixin : Tab 컨트롤러에 대한 처리를 담당하는 class
  TabController? controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('TabBar Example'),
      ),
      body: TabBarView(
        children: <Widget> [FirstApp(), SecondApp()],
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
