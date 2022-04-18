import 'dart:html';

import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  var res = '';
  var val1 = '';
  var val2 = '';
  var res1 = 0.0;

  IconData ic1= Icons.ice_skating_outlined;

  List DropdownList = ['ADD', 'SUB', 'MUL', 'DIV'];
  List <DropdownMenuItem<String>> dplist = [];
  String? DropDownText;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    for (var item in DropdownList){
      dplist.add(DropdownMenuItem(value: item,child: Text(item)));
      // List <DropdownMenuItem<String>> dplist에 위젯을 넣어주는 부분에서 헤멨다..
      // 주로 Text위젯을 넣어주며 value도 함께 적어줘야 error가 안남..😠
      DropDownText=DropdownList[0];
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "I'll make it",
      home: Scaffold(
        appBar: AppBar(
          title: Text("Common !! FLUTTER !!!"),
        ),
        body: Column(
          children: [
            Text("Result: $res"),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                onChanged: (val){
                  val1 = val;
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                onChanged: (val){
                  val2 = val;
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(onPressed: (){
                setState(() {
                  if(DropDownText == 'ADD'){
                    res1 = double.parse(val1) + double.parse(val2);
                    res = res1.toString();
                  }else if(DropDownText == 'SUB'){
                    res1 = double.parse(val1) - double.parse(val2);
                    res = res1.toString();
                  }else if(DropDownText == 'MUL'){
                    res1 = double.parse(val1) * double.parse(val2);
                    res = res1.toString();
                  }else
                    res1 = double.parse(val1) / double.parse(val2);
                    res = res1.toString();

                });
              },
                child: Row(
                  children: [
                    Icon(ic1),
                    Text('$DropDownText')
                  ],
                ),
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.pink)
              ),),
            ),
            DropdownButton(items: dplist, onChanged: (String? val) {
              setState(() {
                if(val == 'SUB'){
                  ic1 = Icons.invert_colors;
                  DropDownText = val;
                }else if(val == 'ADD'){
                  ic1 = ic1;
                  DropDownText =val;
                }else if(val == 'MUL'){
                  ic1 = Icons.insert_emoticon_outlined;
                  DropDownText =val;
                }else
                  ic1= Icons.icecream;
                DropDownText=val;
                });
            },value: DropDownText,)
          ],
        ),
      ),
    );
  }
}
