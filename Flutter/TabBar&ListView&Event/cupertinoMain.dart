import 'package:flutter/cupertino.dart';
import 'package:listview_example/iosSub/cupertinoSecondPage.dart';
import 'animalItem.dart';
import 'iosSub/cupertinoFirstPage.dart';
import 'iosSub/cupertinoSecondPage.dart';

class CupertinoMain extends StatefulWidget {
  @override
  State<CupertinoMain> createState() => _CupertinoMainState();
}

class _CupertinoMainState extends State<CupertinoMain> {
  CupertinoTabBar? tabBar;
  List<Animal> animalList = List.empty(growable: true);
  // List를  이용해 animalList를 선언

  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      home: CupertinoTabScaffold(
          tabBar: tabBar!,
          // 정의한 탭바를 build()함수내 tabBar에 넣음
          tabBuilder: (context, value) {
            if (value == 0) {
              return CupertinoFirstPage(animalList: animalList);
              // build() 함수에서 CupertinoFirstPage를 반환하도록 수정
              //   Container(
              //   child: Center(
              //     child: Text('cupertino tab 1'),
              //   ),
              // );
            }
            else {
              return CupertinoSecondPage(animalList: animalList);
              // Container(
              //   child: Center(
              //     child: Text('cupertino tab 2'),
              //   ),
              // );
            }
          }
          // tabBuilder에서 각 탭을 어떻게 표시할지 작성, 각 탭을 누르면 tabBuilder에서 value 0이나 1을 반환 이 값을 이용해 각 탭의 로직 처리
          ),
    );
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    tabBar = CupertinoTabBar(items: <BottomNavigationBarItem>[
      BottomNavigationBarItem(icon: Icon(CupertinoIcons.home)),
      BottomNavigationBarItem(icon: Icon(CupertinoIcons.add))
    ]);

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
  // _CupertinoMain 클래스에 CupertinoTabBar를 만든 후 initState() 함수에서 정의, initState -> build 생명주기
}
