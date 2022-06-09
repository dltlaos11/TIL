# first_page.dart🟢
```dart
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:kichulmunjaebychanhee/bookItem.dart';
import 'dart:convert';

import '../main.dart';


class FirstApp extends StatefulWidget {
  const FirstApp({Key? key}) : super(key: key);
  @override
  State<FirstApp> createState() => _FirstAppState();
}

class _FirstAppState extends State<FirstApp> {
  List? data = [];
  TextEditingController? _editingController;
  int page = 1;
  ScrollController? _scrollController;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text('책 검색')
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Center(
              child: SizedBox(
                width: 500,
                child: TextField(
                  controller: _editingController,
                  style: const TextStyle(color: Colors.green),
                  keyboardType: TextInputType.text,
                  decoration: const InputDecoration(
                      hintText: '제목',
                      border: OutlineInputBorder()
                  ),
                  maxLines: 5,
                  minLines: 1,
                ),
              ),
            ),
            data!.isEmpty
                ? const Text(
              'The data is not available', style: TextStyle(fontSize: 20),
              textAlign: TextAlign.center,)
                : Expanded(
              child: ListView.builder(
                itemBuilder: (context, index) {
                  return GestureDetector(
                    child: Card(
                      child: Row(
                        children: [
                          // Text(data![index]['title'].toString()),
                          // Text(data![index]['authors'].toString()),
                          // Text(data![index]['sale_price'].toString()),
                          Image.network(
                            data![index]['thumbnail'],
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
                                      '제목 : ${data![index]['title']
                                          .toString()}',
                                      textAlign: TextAlign.left,
                                    ),
                                    Text('저자 : ${data![index]['authors']
                                        .toString()}',
                                        textAlign: TextAlign.left),
                                    Text('가격 : ${data![index]['sale_price']
                                        .toString()}',
                                        textAlign: TextAlign.left),
                                  ],
                                  mainAxisAlignment: MainAxisAlignment.start,
                                ),
                              ),
                            ],
                          )
                        ], mainAxisAlignment: MainAxisAlignment.start,
                      ),
                    ), onTap: () {
                      var book = Book(title: data![index]['title'].toString(), authors: data![index]['authors'].toString(),
                          sale_price: data![index]['sale_price'].toString(),
                          publisher: data![index]['publisher'].toString(), contents: data![index]['contents'].toString(), thumbnail: data![index]['thumbnail']);
                      print(book.thumbnail);
                    AlertDialog dialog = AlertDialog(
                      content: Expanded(
                        child: SizedBox(
                          width: 300,
                          height: 350,
                          child: Column(
                              children: [
                                Image.network(
                                  data![index]['thumbnail'],
                                  height: 100,
                                  width: 100,
                                  fit: BoxFit.contain,
                                ),
                                Text('제목 : ${data![index]['title'].toString()}',),
                                Text('저자 : ${data![index]['authors'].toString()}'),
                                Text('가격 : ${data![index]['sale_price']
                                    .toString()}'),
                                Text(
                                    '출판사: ${data![index]['publisher'].toString()}'),
                                const Text('도서소개'),
                                Expanded(
                                  child: SingleChildScrollView(
                                    scrollDirection: Axis.vertical,
                                    child: Text(
                                      data![index]['contents'].toString(),
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
                      ),
                      actions: [
                        ElevatedButton(onPressed: (){
                          myData.add(book);
                          Navigator.of(context).pop();
                        }, child: Text('저장'))
                      ],
                    );
                    showDialog(context: context,
                        builder: (BuildContext context) => dialog);
                  },
                  );
                }, itemCount: data!.length,controller: _scrollController),
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          page = 1;
          data!.clear();
          download();
        },
        child: const Icon(Icons.file_download),
      ),
    );
  }

  Future download() async {
    var url = "https://dapi.kakao.com/v3/search/book?target=title&page=$page&query=${_editingController!
        .value.text}";
    var response = await http.get(Uri.parse(url),
        headers: {"Authorization": "KakaoAK 27b19a2be7c298c36933631bebfdfdc7"});
    // print(response.body);
    setState(() {
      var dataConvertToJSON = json.decode(response.body);
      List result = dataConvertToJSON['documents'];
      data!.addAll(result);
    });
    return response.body;
  }

  @override
  void initState() {
    super.initState();
    _editingController =  TextEditingController();
    _scrollController = ScrollController();

    _scrollController!.addListener(() {
      if(_scrollController!.offset >= _scrollController!.position.maxScrollExtent
      && !_scrollController!.position.outOfRange) {
        print('bottom');
        page++;
        download();
      }
    });
  }
}

```