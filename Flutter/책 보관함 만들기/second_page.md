# second_page.dart🟢
```dart
import 'package:flutter/material.dart';
import 'package:kichulmunjaebychanhee/main.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:dio/dio.dart';

class SecondApp extends StatefulWidget {
  const SecondApp({Key? key}) : super(key: key);

  @override
  State<SecondApp> createState() => _FirstAppState();
}

class _FirstAppState extends State<SecondApp> {
  String? imgUrl = '';
  bool downloading = false;
  var progressString = '';
  String file = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text('내 보관함')
      ),
      body: Stack(
        children: [
          Center(
            child: ListView.builder(itemBuilder: (context, index){
              return GestureDetector(
                child: Card(
                child: Row(
                  children: [
                    Image.network(
                      myData[index].thumbnail.toString(),
                      height: 100,
                      width: 100,
                      fit: BoxFit.contain,
                    ),
                    Column(
                      children: [
                        SizedBox(
                          width: MediaQuery
                              .of(context)
                              .size
                              .width - 150,
                          child: Column(
                            children: [
                              Text(
                                '제목 : ${myData[index].title}',
                                textAlign: TextAlign.left,
                              ),
                              Text('저자 : ${myData[index].authors
                                  .toString()}',
                                  textAlign: TextAlign.left),
                              Text('가격 : ${myData[index].sale_price}',
                                  textAlign: TextAlign.left),
                            ],
                            mainAxisAlignment: MainAxisAlignment.start,
                          ),
                        ),
                      ],
                    )
                  ],
                ),
                ),
                onTap: (){
                  print(myData[index].title);
                  setState(() {
                    imgUrl =  myData[index].thumbnail.toString();
                  });
                  print(imgUrl);
                  AlertDialog dialog = AlertDialog(
                    content: SizedBox(
                      width: 300,
                      height: 300,
                      child: Column(
                        children: [
                          Image.network(
                            myData[index].thumbnail.toString(),
                            height: 100,
                            width: 100,
                            fit: BoxFit.contain,
                            ),
                            Text('제목 : ${myData[index].title}',),
                            Text('저자 : ${myData[index].authors}',),
                          Text('가격 : ${myData[index].sale_price}',),
                          Text('출판사 : ${myData[index].publisher}',),
                          const Text('도서소개'),
                          Expanded(
                            child: SingleChildScrollView(
                              scrollDirection: Axis.vertical,
                              child: Text(
                                '${myData[index].contents}',
                                style: const TextStyle(
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20.0,
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                    actions: [
                      ElevatedButton(onPressed: (){
                        myData.remove(myData[index]);
                        Navigator.of(context).pop();
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (context) => const SecondApp()), // this mymainpage is your page to refresh
                              (Route<dynamic> route) => false,
                        );
                      }, child: const Text('삭제'))
                    ],
                  );
                  showDialog(context: context, builder: (BuildContext context) => dialog);
                },
              );
            },itemCount: myData.length,),
          ),
          Center(
            child: downloading ?
            SizedBox(
             height: 120,
             width: 200,
             child: Card(
               color: Colors.black,
               child: Column(
                 mainAxisAlignment: MainAxisAlignment.center,
                 children: [
                   const CircularProgressIndicator(),
                   const SizedBox(height: 20,),
                   Text(
                     'Downloading File: $progressString',
                     style: TextStyle(color: Colors.white),
                   )
                 ],
               ),
             ),
            ) : FutureBuilder(
                builder: (context, snapshot) {
                  switch (snapshot.connectionState) {
                    case ConnectionState.none:
                      print('done');
                      return const Text('No Data');
                    case ConnectionState.waiting:
                      print('waiting');
                      return const CircularProgressIndicator();
                    case ConnectionState.active:
                      print('active');
                      return const CircularProgressIndicator();
                    case ConnectionState.done:
                      print('done');
                      if(snapshot.hasData) {
                        return snapshot.data as Widget;
                      }
                  }
                  print('end process');
                  return const Text('No data');
                },future: downloadWidget(file),)
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          downloadFile();
        },child: const Icon(Icons.file_download),
      ),
    );
  }

  Future downloadFile() async {
    Dio dio = Dio();
    try{
      var dir = await getApplicationDocumentsDirectory();
      await dio.download(imgUrl!, '${dir.path}/myimage.jpg',
      onReceiveProgress: (rec, total) {
        print('Rec: $rec, Total: $total');
        file = '${dir.path}/myimage.jpg';
        setState(() {
          downloading = true;
          progressString = ((rec/total) * 100).toStringAsFixed(0) + '%';
        });
      }
      );
    } catch(e) {
      print(e);
    }
    setState(() {
      downloading = false;
      progressString = 'Completed';
    });
    print('Download completed');
  }

  Future downloadWidget(String filePath) async {
    File file = File(filePath);
    bool exist = await file.exists();
    FileImage(file).evict();

    if (exist) {
      return Center(
        child: Column(
          children: [
            Image.file(File(filePath))
          ],
        ),
      );
    } else {
      return const Text('No data');
    }
  }
}
```