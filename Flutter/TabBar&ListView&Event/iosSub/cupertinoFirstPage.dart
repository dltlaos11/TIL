import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../animalItem.dart';

class CupertinoFirstPage extends StatelessWidget {
  final List<Animal>? animalList;

  const CupertinoFirstPage({Key? key, required this.animalList}) : super(key: key);
  // cupertinoMain에서 만든 동물 리스트를 상속 받아서 리스트뷰로 화면에 출력

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
    navigationBar: CupertinoNavigationBar(middle: Text('Animals List'),),
      // 앱바 위젯이 없으므로 네비게이션바가 있으므로 CupertinoNavigationBar를 이용, middle에 문자열 삽입
      child: ListView.builder(
          itemBuilder: (context, index) {
            return Container(
              // cupertino에서는 카드 위젯이 없음, Container를 이용해 만들고 각 Container에 높이를 정해서 위젯을 배치
              padding: EdgeInsets.all(5),
              height: 100,
              child: Column(
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Image.asset(
                        animalList![index].imagePath!,
                        fit: BoxFit.contain,
                        width: 80,
                        height: 80,
                      ),
                      Text(animalList![index].animalName!)
                    ],
                  ),
                  Container(
                    height: 2,
                    color: CupertinoColors.black,
                  )
                ],
              ),
            );
          },
        itemCount: animalList!.length,
          ),
    );
  }
}
