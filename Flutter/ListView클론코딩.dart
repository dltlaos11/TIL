//https://flutter.github.io/samples/testing_app.html 클론코딩한 사이트

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  IconData ic1 = Icons.favorite_border;

  String ent = "item";
  final List<int> cocaine = <int>[75, 76, 77, 78, 79, 80, 81, 82];

  final List<String> textList = <String>['ITEM75', 'ITEM76', 'ITEM77'];
  final List<Color> colorList = <Color>[Colors.pink, Colors.brown, Colors.redAccent];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'List View',
      home: Scaffold(
        appBar: AppBar(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Testing Sample"),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: IconButton(icon: Icon(ic1),
                        onPressed: () {
                          setState(() {
                            if (ic1 == Icons.favorite_border) {
                              ic1 = Icons.favorite;
                            } else
                              ic1 = Icons.favorite_border;
                          });
                        },
                      ),
                    ),
                    Text("Favorite")
                  ],
                ),
              ),
            ],
          ),
        ),
        body: ListView.builder(
          itemCount: textList.length,
            itemBuilder: (context, index) {
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: colorList[index],
                  child: Text('ha'),
                ),
                title: Text('${textList[index]}'),
                trailing: IconButton(
                    icon: Icon(Icons.favorite_border), onPressed: () {}),
              );
            }), // ListView.builder 사용 
        // body: ListView(
        //   children: [
        //     ListTile(
        //       leading: CircleAvatar(
        //         backgroundColor: Colors.amber,
        //         child: const Text('Ah'),
        //       ),
        //       title: Text("Item75"),
        //       trailing: IconButton(icon: Icon(Icons.favorite_border),onPressed: (){}),
        //     ),
        //     ListTile(
        //       title: Text("Item75"),
        //       trailing: IconButton(icon: Icon(Icons.favorite_border),onPressed: (){}),
        //     ),
        //     ListTile(
        //       title: Text("Item75"),
        //       trailing: IconButton(icon: Icon(Icons.favorite_border),onPressed: (){}),
        //     )
        //   ],
        // )  ListView일떄
      ),
    );
  }
}
