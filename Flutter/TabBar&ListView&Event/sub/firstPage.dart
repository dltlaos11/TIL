import 'package:flutter/material.dart';
import '../animalItem.dart';

class FirstApp extends StatelessWidget {
  final List<Animal>? list;

  FirstApp({Key? key, this.list}) : super(key: key);
  //생성자 부분, FirstApp 생성될떄 Animal list를 this.list로 넘겨주는것

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Center(
          child: ListView.builder(itemBuilder: (context, position){
            return GestureDetector(
              // 터치 이벤트 처리를위해서
              child: Card(
                // 이 부분에 위젯을 이용해 데이터를 표시, Card에 해당되는 Item들을 쭉넣으면 ListView로 만들어준다.
                child: Row(
                  children: <Widget> [
                    Image.asset(
                      list![position].imagePath!,
                      height: 100,
                      width: 100,
                      fit: BoxFit.contain,
                    ),
                    Text(list![position].animalName!)
                  ],
                ),
              ),
              onTap: (){
                AlertDialog dialog = AlertDialog(
                  content: Text('This animal is a ${list![position].animalName}', style: TextStyle(fontSize: 20),));
                showDialog(context: context, builder: (BuildContext context) => dialog);
              },
            );
          },
          itemCount: list!.length), // 갯수만큼 scroll
        ),
      ),
    );
  }
  // ListView를 만들기 위해서는 ListView.builder를 이용하고 여기에 property로 itemBuilder라는 것이 있는데 
  // 여기에는 BuildContext와 int 2개의 parameter가 넘어온다. itemBuilder는 BuildContext와 int를  
  // 반환하며 BuildContext는 위젯 트리에서 위젯의 위치를 알려주며 int는 아이템의 순번을 의미한다.
  // 통상 ListView의 아이템은 Card형태로 만듦
}

// 관건 : 어떤 class 형태로 정보를 만들고 그 class를 갖는 list를 만들고 그 list를 이용해서 ListView에다가 넣어주는 형태
