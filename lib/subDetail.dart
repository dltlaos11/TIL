import 'package:flutter/material.dart';

class SubDetail extends StatefulWidget {

  @override
  State<SubDetail> createState() => _SubDetailState();
}

class _SubDetailState extends State<SubDetail> {
  List todoList = [];

  // 리스트뷰에 할일을 보여주는 기능 구현
  // InkWell 위젯은 탭, 더블탭, 롱탭 등 다양한 터치 이벤트를 처리할 수 있음
  // pushNamed() 함수로 페이지 이동시 arguments로 지정한 데이터를 전달

  // 세번쨰 페이지로 이동하면서 todoList[index], 즉 사용자가 선택한 할일(문자열)을 전달

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sub Detail Example'),
      ),
      body: ListView.builder(itemBuilder: (context, index) {
        return Card(
          child: InkWell(
            child: Text(
              todoList[index],
              style: TextStyle(fontSize: 30),
            ),
            onTap: () {
              Navigator.of(context).pushNamed(
                  '/third', arguments: todoList[index]);
            },
          ),
        );
      },
        itemCount: todoList.length,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _addNavigation(context);
        },
        child: Icon(Icons.add),
      ),

      // Container(
      //   child: Center(
      //     child: ElevatedButton(
      //       onPressed: (){
      //         // Navigator.of(context).pushReplacementNamed('/second');
      //         Navigator.of(context).pushNamed('/second');
      //       },
      //       child: Text('Go ro the second page'),
      //     ),
      //   ),
      // ),

    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    todoList.add('Buy some carrot');
    todoList.add('Buy medicine');
    todoList.add('Cleaning');
    todoList.add('Calling parents');
  }

  void _addNavigation(BuildContext context) async {
    final result = await Navigator.of(context).pushNamed('/second');
    setState(() {
      todoList.add(result as String);
    });
  }
}
  // 버튼을 누르면 두번쨰 페이지로 이동하고 여기서 반환하는 값을 저장해 할일 몯록에 추가하는 _addNavigation() 함수 정의
  // 이 함수는 데이터를 받은 다음에 처리해야 하므로 비동기식으로 구현
  // result가 String이라는 것을 알 수 있도록 형변환이 필요

// build()함수  수정
// Container를 이용해 버튼 생성
// 버튼 이벤트 처리 : 페이지 이동, 라우트  기능 이용
// pushReplacementNamed()함수는 스택 메모리에 있는 자료를 교체


// pushReplacementNamed() 함수를 pushNamed() 함수로 수정
// pushReplacementNamed() 함수는 스택에 추가하지 않고 교체함
// 스택 추가를 위해서 pushNamed() 사용