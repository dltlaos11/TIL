# main.dart 🟢
```dart
import 'package:flutter/material.dart';
import 'package:kichulmunjaebychanhee/sub/first_page.dart';
import 'package:kichulmunjaebychanhee/sub/second_page.dart';

void main() {
  runApp(const MaterialApp(home: MyApp(),));
}

List myData = [];


class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with SingleTickerProviderStateMixin{
  TabController? _tabController;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: TabBarView(children: const [
          FirstApp(), SecondApp()
        ], controller: _tabController),
      ),
      bottomNavigationBar: TabBar(controller: _tabController,
        tabs: const [
          Tab(icon: Icon(Icons.home, color: Colors.green,)),
          Tab(icon : Icon(Icons.desktop_windows_outlined, color: Colors.green))
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }
}

```