import 'package:flutter/material.dart';

class ThirdDetail extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    final String args = ModalRoute.of(context).settings.arguments.toString();

    // 할일 보기 기능 만들기
    // args 변수
    // ModalRoute.of(context)!.settings.arguements.toString() 코드를 이용해 두번째 페이지에서 보낸 arguments값을 입력하고 이 값을 텍스트 위젯에 출력
    // arguments의 값이 어떤 자료형인지 알 수 없으므로 String으로 변환한 다음 처리

    return Scaffold(
      appBar: AppBar(
        title: Text('Third Page'),
      ),
      body: Container(
        child: Center(
          child: Text(
            args,
            style: TextStyle(fontSize: 30),
          ),
        ),
      )

      // Container(
      //   child: Center(
      //     child: ElevatedButton(
      //       onPressed: () {
      //         // Navigator.of(context).pop();
      //         Navigator.of(context).pushReplacementNamed('/third');
      //       },
      //       child: Text('Go to the first Page'),
      //     ),
      //   ),
      // ),
    );
  }
}
