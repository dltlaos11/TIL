# largeFileMain.dart
```dart
import 'package:flutter/material.dart';
import 'package:dio/dio.dart'; // 진행상황 표시, dio 패키지
import 'package:path_provider/path_provider.dart'; // 내부 저장소 이용하는 parh_provider 패키지
import 'dart:io';

class LargeFIleMain extends StatefulWidget {

  @override
  State<LargeFIleMain> createState() => _LargeFIleMainState();
}

class _LargeFIleMainState extends State<LargeFIleMain> {
  // String imgUrl = 'https://images.pexels.com/photos/8699259/pexels-photo-8699259.jpeg?auto=compress&cs=tinysrgb&dpr=3&h=750&w=1260';
  bool downloading = false;
  var progressString = '';
  String file = '';
  TextEditingController _editingController;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _editingController,
          style: TextStyle(color: Colors.white),
          keyboardType: TextInputType.text,
          decoration: InputDecoration(hintText: 'Please enter url'),
        )
        // Text('Large File Example'),
      ),
      body: Center(
        child: downloading ?
        Container(
          height: 120,
          width: 200,
          child: Card(
            color: Colors.black,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 20.0,),
                Text(
                  'Downloading File: ${progressString}',
                  style: TextStyle(color: Colors.white),
                )
              ],
            ),
          ),
        ) : FutureBuilder(
          // 정해지지 않은 무언가 처리..
            builder: (context, snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.none:
                  print('none');
                  return Text('No data');
                case ConnectionState.waiting:
                  print('waiting');
                  return CircularProgressIndicator();
                case ConnectionState.active:
                  print('active');
                  return CircularProgressIndicator();
                case ConnectionState.done:
                  print('done');
                  if(snapshot.hasData) {
                    return snapshot.data as Widget;
                  }
              }
              print('end process');
              return Text('No data');
        }, future: downloadWidget(file),)
            // future 완료되면 하는 행위
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          downloadFile();
        },
        child: Icon(Icons.file_download),
      ),
    );
  }
  // build 함수
  // 스캐폴드를 이용해 머티리얼 형태로 표시하고 앱바와 플로팅 버튼을 만듦
  // 플로팅 버튼을 누르면 파일을 내려받는 downloadfile() 함수를 실행
  // body는 downloading이 true인지 false인지에 따라서 위젯 구성

  // FutureBuilder 위젯을 이용해 이미지 내려받기 화면 구성
  // 아직은 데이터가 없지만 앞으로 데이터를 받아서 처리한 후에 만들겠다는 의미
  // 파일 입출력이나 네트워크 통신을 구현할 떄는 대부분 비동기 방식으로 처리하기 떄문에 Future를 이용
  // FutureBuilder는 builder에서 snapshot이라는 변수를 반환, snapshot은 FutureBuilder.future에서 받아온 데이터를 저장한 dynamic 형태의 변수
  // snapshot.connectionState를 이용해 switch문으로 데이터를 받을 떄, 오류가 발생할 떄, 데이터가 완료되었을 떄 나누어 처리
  // connectionState값이 done이면 snapshot.data를 반환
  // none: 데이터 없음, Waiting: 데이터 전달 받는중, Active; stream모드에서 동작하는 코드, Done: 모든 데이터 전송이 완료된 상태

  Future downloadFile() async {
    Dio dio = Dio();
    try{
      var dir = await getApplicationDocumentsDirectory();
      await dio.download(/*imgUrl*/_editingController.value.text, '${dir.path}/myimage.jpg',
      onReceiveProgress: (rec, total) {
        print('Rec: ${rec}, Total: ${total}');
        file = '${dir.path}/myimage.jpg';
        setState(() {
          downloading = true;
          progressString = ((rec/total) *100).toStringAsFixed(0) + '%';
        });
      });
    } catch (e) {
      print(e);
    }
    setState(() {
      downloading = false;
      progressString = 'Completed';
    });
    print('Download completed');
  }
  // downloadFile() 함수
  // dio 선언 후 내부 디렉토리를 가져옴
  // getApplicationDocumentsDirectory() 함수
  // path_provider 패키지가 제공하며 플러터 앱의 내부 디렉토리를 가져오는 역할
  // dio.download를 이용해 url에 담긴 주소에서 파일을 내려받음
  // 내려받은 파일은 내부 디렉토리 안에 myimage.jpg라는 이름으로 저장
  // 이떄 데이터를 받을 때마다 onReceiveProgress()함수를 실행해 진행 상황을 표시
  // 이 함수가 전달받은 rec는 지금까지 내려받은 데이터, total은 파일의 전체 크기
  // 내려받기 시작되면
  // downloading = true를 선언하고 얼마나 받았는지 계산한 후 프로그레스에 표시할 문자열에 입력
  // 다 내려 받았으면 downloading = false로 설정하고 프로그레스 문자열을 Completed로 변경

  Future downloadWidget(String fileParh) async {
    File file = File(fileParh);
    bool exist = await file.exists();
    new FileImage(file).evict();

    if(exist) {
      return Column(
        children: [
          Image.file(File(fileParh))
        ],
      );
    } else {
      return Text('No data');
    }
  }
  // downloadWidget(file) 함수
  // snapshot.data는 downloadWidget(file)함수가 반환하는 데이터
  // 이 함수를 _LargeDileMain 클래스에 작성
  // 이미지 파일이 있는지 확인해서 있으면 이미지를 화면에 보여주는 위젯을 반환
  // 없으면 'No data'텍스트 출력
  // evit()함수는 캐시를 초기화(플러터는 빠른 이미지 처리를 위해 캐시에 같은 이름의 이미지가 있으면 이미지 변경없이 해당 이미지를 사용)

@override
  void initState() {
    // TODO: implement initState
    super.initState();
    _editingController = new TextEditingController(
      text: 'https://images.pexels.com/photos/8699259/pexels-photo-8699259.jpeg?auto=compress&cs=tinysrgb&dpr=3&h=750&w=1260'
    );
  }
}

```