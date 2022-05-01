import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: StorePage(),
    );
  }
}

class StorePage extends StatefulWidget {
  const StorePage({Key? key}) : super(key: key);

  @override
  State<StorePage> createState() => _StorePageState();
}

class _StorePageState extends State<StorePage> {
  String sum = '';
  TextEditingController value1 = TextEditingController();
  TextEditingController value2 = TextEditingController();
  bool errorFlag = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('MID-TERM EXAM'),),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: TextField(keyboardType: TextInputType.number, controller: value1,),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: TextField(keyboardType: TextInputType.number, controller: value2,),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                ElevatedButton(onPressed: (){
                  setState(() {
                    if(value1.value.text.length==0 || value2.value.text.length==0){sum=''; errorFlag=true;}
                    else{
                      var result = double.parse(value1.value.text) + double.parse(value2.value.text);
                      sum = '$result';
                      value1.text = '';
                      value2.text = '';
                      errorFlag = false;
                    }
                  });
                }, style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.lightBlueAccent)),
                child: Image.asset('images/add.jpg', width: 30, height: 30, fit: BoxFit.fill,),),
                Spacer(),
                ElevatedButton(onPressed: (){
                  setState(() {
                    if(value1.value.text.length==0 || value2.value.text.length==0){sum=''; errorFlag=true;}
                    else{
                      var result = double.parse(value1.value.text) - double.parse(value2.value.text);
                      sum = '$result';
                      value1.text = '';
                      value2.text = '';
                      errorFlag = false;
                    }
                  });
                }, style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.deepOrange[300])),
                  child: Image.asset('images/sub.png', width: 30, height: 30, fit: BoxFit.fill,),),
                Spacer(),
                ElevatedButton(onPressed: (){
                  setState(() {
                    if(value1.value.text.length==0 || value2.value.text.length==0){sum=''; errorFlag=true;}
                    else{
                      var result = double.parse(value1.value.text) * double.parse(value2.value.text);
                      sum = '$result';
                      value1.text = '';
                      value2.text = '';
                      errorFlag = false;
                    }
                  });
                }, style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.yellow)),
                  child: Image.asset('images/mul.png', width: 30, height: 30, fit: BoxFit.fill,),),
                Spacer(),
                ElevatedButton(onPressed: (){
                  setState(() {
                    if(value1.value.text.length==0 || value2.value.text.length==0){sum=''; errorFlag=true;}
                    else{
                      var result = double.parse(value1.value.text) / double.parse(value2.value.text);
                      sum = '$result';
                      value1.text = '';
                      value2.text = '';
                      errorFlag = false;
                    }
                  });
                }, style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.lightBlueAccent)),
                  child: Image.asset('images/div.png', width: 30, height: 30, fit: BoxFit.fill,),),
              ],
            ),
          ),
          if (!errorFlag) Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text('$sum', style: TextStyle(fontSize: 80, fontWeight: FontWeight.bold),),
          ),
          if (errorFlag) Expanded(child: Image.asset('images/error.png', fit: BoxFit.cover,))
        ],
      ),
    );
  }
  @override
  void initState(){

  }
}


