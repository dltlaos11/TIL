import 'package:flutter/material.dart';
import '../animalItem.dart';

class SecondApp extends StatefulWidget {
  const SecondApp({Key? key, @required this.list}) : super(key: key);

  final List<Animal>? list;

  @override
  State<SecondApp> createState() => _SecondAppState();
}

class _SecondAppState extends State<SecondApp> {
  final nameController = TextEditingController();
  // Text 사용시 Controller를 사용할 수 있음, 없어도 할 순 있다.
  int? _radioValue = 0;
  bool? flyExist = false;
  String? _imagePath;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget> [
              TextField(controller: nameController,
              keyboardType: TextInputType.text,
              maxLines: 1,),
              Row(
                children: [
                  Radio(value: 0, groupValue: _radioValue, onChanged: _radioChange),
                  Text('Insect'),
                  Radio(value: 1, groupValue: _radioValue, onChanged: _radioChange),
                  Text('Plants'),
                  Radio(value: 2, groupValue: _radioValue, onChanged: _radioChange),
                  Text('Animal'),
                ],// value : 인덱스값, groupValue : 그룹화, onChanged : 이벤트처리 지정
                // value에는 각각 0,1,2로 인덱스 부여, groupValue에는 int형 _radioValue를 선언해서 넣음, 초기값 0
                // onChanged에는 라디오 버튼이 눌렸을 때 호출할 함수를 라디오 버튼의 인덱스 값을 _radioValue 변수에 넣는 _radioChange()함수로 정의해서 넣음
              ),
              Row(
                children: [
                  Text('Can it fly?'),
                  Checkbox(value: flyExist,
                      onChanged: (bool? check){
                    setState(() {
                      flyExist = check;
                    });
                  })
                ],
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                // 위젯들 여백 설정 Row 위젯에 mainAxisAlignment를 spaceAround값으로 설정
              ),
              Container(
                height: 100,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  // scrollDirection을 이용하면 가로 리스트뷰 변경 가능
                  children: [
                    GestureDetector(
                    child: Image.asset('repo/images/cow.png', width: 80,),
                    onTap: (){
                      _imagePath = 'repo/images/cow.png';
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
                    GestureDetector(
                      child: Image.asset('repo/images/tiger.png', width: 80,),
                      onTap: (){
                        _imagePath = 'repo/images/tiger.png';
                      },
                    )
                    // GestureDetector를 사용해 이미지를 클릭하면 해당 이미지를 선택할 수 있도록
                  ],

                ),
              ),
              ElevatedButton(onPressed: (){
                var animal = Animal(
                  animalName: nameController.value.text,
                  imagePath: _imagePath,
                  kind: getKind(_radioValue),
                  // getKind() 함수 : 라디오 버튼에서 선택된 값을 전달받아 동물의 종류를 문자열로 반환
                  flyExist: flyExist,
                );
                AlertDialog dialog = AlertDialog(
                  title: Text('Add an Animal'),
                  content: Text(
                    'This is a ${animal.animalName}. \nWould you like to add this animal?',
                    style: TextStyle(fontSize: 20),),
                  actions: [
                    ElevatedButton(onPressed: (){
                      widget.list?.add(animal);
                      Navigator.of(context).pop();
                    }, child: Text('Yes')),
                    ElevatedButton(onPressed: (){
                      Navigator.of(context).pop();
                    }, child: Text('No'))
                  ],
                  // actions : 배열 형태로 위젯을 가져올 수 있음 여기서는 버튼을 선언해 이벤트를 처리하도록 작성 'YES'를 누르면 animal을 리스트에 추가한 다음 알림창이 꺼짐
                );
                showDialog(context: context, builder: (BuildContext context) => dialog);
              }, child: Text('Add an Animal'))
            ],
          ),
        ),
      ),
    );
  }

  _radioChange(int? value) {
    setState(() {
      _radioValue = value;
    });
  }
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
