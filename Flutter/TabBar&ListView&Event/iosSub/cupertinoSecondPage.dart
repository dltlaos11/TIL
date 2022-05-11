import 'package:flutter/cupertino.dart';
import '../animalItem.dart';

class CupertinoSecondPage extends StatefulWidget {
  final List<Animal>? animalList;

  const CupertinoSecondPage({Key? key, required this.animalList}) : super(key: key);

  @override
  State<CupertinoSecondPage> createState() => _CupertinoSecondPageState();
}

class _CupertinoSecondPageState extends State<CupertinoSecondPage> {
  TextEditingController? _textEditingController;
  int _kindChoice = 0;
  bool _flyExist = false;
  String? _imagePath;
  Map<int, Widget> segmentWidgets = {
    0 : SizedBox(
      child: Text('Insect', textAlign: TextAlign.center,),
      width: 80,
    ),
    // 영역을 만들어 주는 위젯, 위젯에 지정한 값만큼 세그먼트의 너비와 높이가 정해짐
    1 : SizedBox(
      child: Text('Plants', textAlign: TextAlign.center,),
      width: 80,
    ),
    2 : SizedBox(
      child: Text('Animal', textAlign: TextAlign.center,),
      width: 80,
    )
  };
  // Map : 정수형 키와 위젯형 값을 쌍으로 해서 구성, 세그먼트 위젯 구성을 위한 필요 내용
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
    navigationBar: CupertinoNavigationBar(middle: Text('Add an Animal'),),
      child: Container(
        child: Center(
          child: Column(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.all(10),
              child: CupertinoTextField(
                controller: _textEditingController,
                keyboardType: TextInputType.text,
                maxLines: 1,
              ),
                // iOS 스타일 입력창, textController 지정, maxLines는 최대 입력 줄수
              ),
              CupertinoSegmentedControl(
                padding: EdgeInsets.only(bottom: 20, top: 20),
                  groupValue: _kindChoice,
                  // groupValue에는 0으로 초기화한 _kindChoice 값 설정, 이후에는 segmnetWidgets에서 정해진 키값이 groupValue에서 설정
                  children: segmentWidgets,
                  // Map으로 생성했던 segmentWidgets를 children으로 설정
                  onValueChanged: (int value){
                  setState(() {
                    _kindChoice = value;
                  });
                  }
                  // 값이 바뀌었을때 동잘할 이벤트 핸들러 정의
                  ),
              Row(
                children: <Widget>[
                  Text('Can it fly?'),
                  CupertinoSwitch(
                      value: _flyExist,
                      onChanged: (value) {
                        setState(() {
                          _flyExist = value;
                        });
                      })
                  // CupertinoSwitch를 이용해 iOS 스타일의 스위치를 만듦
                ],
                mainAxisAlignment: MainAxisAlignment.center,
              ),
              SizedBox(
                height: 100,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  // 리스트뷰를 가로로 스크롤 하기 위해 Axis.horizontal로 설정
                  // 이때 height로 높이를 지정하는 것이 중요(높이 지정안하면 오류 발생)
                  children: <Widget>[
                    GestureDetector(
                      child: Image.asset('repo/images/cow.png', width: 80,),
                      onTap: (){
                        _imagePath = 'repo/images/cow.png';
                      },
                    )
                    // onTap() 이벤트를 통해 선택된 동물 이미지를 저장
                    ,GestureDetector(
                      child: Image.asset('repo/images/gorilla.png', width: 80,),
                      onTap: (){
                        _imagePath = 'repo/images/gorilla.png';
                      },
                    ),
                    GestureDetector(
                      child: Image.asset('repo/images/racoon.png', width: 80,),
                      onTap: (){
                        _imagePath = 'repo/images/racoon.png';
                      },
                    ),
                    GestureDetector(
                      child: Image.asset('repo/images/tiger.png', width: 80,),
                      onTap: (){
                        _imagePath = 'repo/images/tiger.png';
                      },
                    ),GestureDetector(
                      child: Image.asset('repo/images/gorilla.png', width: 80,),
                      onTap: (){
                        _imagePath = 'repo/images/gorilla.png';
                      },
                    ),
                    GestureDetector(
                      child: Image.asset('repo/images/racoon.png', width: 80,),
                      onTap: (){
                        _imagePath = 'repo/images/racoon.png';
                      },
                    ),
                  ],
                ),
              ),
              CupertinoButton(
                  child: Text('Add an Animal'),
                  onPressed: (){
                widget.animalList?.add(Animal(
                  animalName: _textEditingController?.value.text,
                  kind: getKind(_kindChoice),
                  imagePath: _imagePath,
                  flyExist: _flyExist
                ));
                },
              ),
            ],
            mainAxisAlignment: MainAxisAlignment.center,
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _textEditingController = TextEditingController();
  }
  // TextEditingController 선언, 입력한 값을 위한 변수 선언
  getKind(int? radioValue){
    switch (radioValue) {
      case 0:
        return "Insect";
      case 1:
        return "Plants";
      case 2:
        return "Animal";
    }
  }
}
