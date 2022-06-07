# Main.dart
```dart
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http; // http 패키지를 이용해 서버에 접속하고 데이터 가져오기
import 'dart:convert';

import 'package:network_communicaiton/largeFileMain.dart'; // JSON 데이터 이용 위해 convert 패키지 import

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: LargeFIleMain(),
      // HttpApp(), 조회, 검색
    );
  }
}

class HttpApp extends StatefulWidget {

  @override
  State<HttpApp> createState() => _HttpAppState();
}

class _HttpAppState extends State<HttpApp> {
  String result = '';
  List data = [];
  TextEditingController _editingController;
  int page = 1;
  ScrollController _scrollController;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _editingController,
          style: TextStyle(color: Colors.white),
          keyboardType: TextInputType.text,
          decoration: InputDecoration(hintText: 'Please enter a search term'),
        )
        // Text('Http Example'),
        // 검색기능 추가
        // 텍스트 필드를 이용해 사용자가 직접 검색어를 입력할 수 있도록 수정
        // 텍스트 필드 위젯을 만들고 initState() 함수에서 TextEditingController 초기화
        // decoration
        // 텍스트필드 위젯에 보이는 텍스트를 꾸미는 옵션
        // hintText

      ),
      body:
      Container(
        child: Center(child: data.length == 0 ?
        Text('The data is nor available.', style: TextStyle(fontSize: 20),
          textAlign: TextAlign.center,) :
        ListView.builder(itemBuilder: (context, index) {
          return Card(child: Container(
              child: Row( //Column(
                children: [
                  // Text(data[index]['title'].toString()),
                  // Text(data[index]['authors'].toString()),
                  // Text(data[index]['sale_products'].toString()),
                  // Text(data[index]['status'].toString()),
                  Image.network(
                    data[index]['thumbnail'],
                    height: 100,
                    width: 100,
                    fit: BoxFit.contain,
                  ),
                  Column(
                    children: [
                      Container(
                        width: MediaQuery
                            .of(context)
                            .size
                            .width - 150,
                        child: Text(
                          data[index]['title'].toString(),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Text('Author : ${data[index]['authors'].toString()}'),
                      Text('Price : ${data[index]['sale_price'].toString()}'),
                      Text('Status : ${data[index]['status'].toString()}'),
                    ],
                  )
                ],
                mainAxisAlignment: MainAxisAlignment.start,
              )
          ),
          );
        },
          itemCount: data.length,
          controller: _scrollController,
          // ListView.builder()함수에 controller 옵션에 스크롤 컨트롤러 입력
        )
        ),
      ),
      //Text('$result'),
      // JSON 데이터를 List 형태의 data 변수에 저장
      // initState() 함수에서 data 변수를 초기화
      // data가 0일떄 Text 위젯을 이용해 데이터가 없다는 문구 표시
      // Image.network는 네트웨크에 있는 이미지를 가져오는 위젯, 이 위젯을 이용하면 URL을 이용해 간단하게 화면에 이미지 출력

      // Card 위젯에서 Row와 Column을 이용해 화면 배치
      // MediaQuery.of(context).size
      // 현 스마트 디바이스의 화면크기
      // 화면의 넓이에서 이미지를 뺸 나머지만큼만 제목을 입력하도록 함, 그렇지 않으면 영역 넘김 오류 표시(노란색 빗금)

      floatingActionButton: FloatingActionButton(
        onPressed: () /*async*/
        // var url = 'https://www.google.com/search?q=flutter+XMLHttpRequest+error.&ei=4smdYqOtBazS2roP3eK5kA4&ved=0ahUKEwijpvjNwpj4AhUsqVYBHV1xDuIQ4dUDCA4&uact=5&oq=flutter+XMLHttpRequest+error.&gs_lcp=Cgdnd3Mtd2l6EAMyBAgAEB4yBAgAEB4yBAgAEB4yBggAEB4QCDIGCAAQHhAIMgYIABAeEAgyBggAEB4QCDIGCAAQHhAIMgYIABAeEAgyBggAEB4QCDoHCAAQRxCwA0oECEEYAEoECEYYAFCwAViwAWDPBGgBcAF4AIABmAGIAZgBkgEDMC4xmAEAoAECoAEByAEKwAEB&sclient=gws-wiz';
        // var response = await http.get(Uri.parse(url));
        // setState(() {
        //   result = response.body;
        // });
        {
          page =1;
          data.clear();
          getJsonData();
          // 버튼을 누를 떄마다 기존 내용을 지우고 페이지를 1로 초기화하는 코드 추가
        },
        child: Icon(Icons.file_download),
      ),
    );
  }

  Future getJsonData() async {
    var url = "https://dapi.kakao.com/v3/search/book?target=titile&page=${page}&query=${_editingController.value.text}";
    var response = await http.get(Uri.parse(url),
        headers: {"Authorization": "KakaoAK 27b19a2be7c298c36933631bebfdfdc7"});
    // print(response.body);
    setState(() {
      var dataConvertedToJson = json.decode(response.body);
      List result = dataConvertedToJson['documents'];
      data.addAll(result);
    });
    return response.body;
  }

  // async를 선언하고 await를 이용해 통신
  // Future 반환 : 비동기 처리에서 데이터를 바로 처리할 수 없을 떄 사용

  @override
  void initState() {
    super.initState();
    data = new List.empty(growable: true);
    _editingController = new TextEditingController();

    _scrollController = new ScrollController();
    _scrollController.addListener(() {
      if(_scrollController.offset >= _scrollController.position.maxScrollExtent && !_scrollController.position.outOfRange) {
        print('bottom');
        page++;
        getJsonData();
      }
    });
  }
}
// 화면에서 목록을 가장 밑으로 내리면 page 숫자를 증가한 후 서버에 이를 다시 요청하는 코드 작성
// _HttpAppState 클래스에서 스크롤 컨트롤러  변수 선언
// initState() 함수
// 스크롤 컨트롤러의 addListener() 함수를 이용해 스크롤 할 떄 이벤트 처리
// offset은 목록에서 현재 위치를 double형 변수로 나타냄
// 스크롤할 떄마다 offset을 검사해 maxScrollExtent보다 크거나 같고 스크롤 컨트롤러의 position에 정의된 범위를 넘어가지 않으면 목록의 마지막이라고 인식
// 그러면 page를 1만큼 증가한 후 getJsonData()함수 호출
```