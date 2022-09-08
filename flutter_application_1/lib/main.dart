import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_1/sub/DailyAccount.dart';
import './repository/account_repository.dart';
import './object/AccountApplicationService.dart';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'sub/DailyAccount.dart';
import 'sub/WeeklyResult.dart';
import 'dart:async';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Account Book',
      theme: ThemeData(
          // This is the theme of your application.
          //
          // Try running your application with "flutter run". You'll see the
          // application has a blue toolbar. Then, without quitting the app, try
          // changing the primarySwatch below to Colors.green and then invoke
          // "hot reload" (press "r" in the console where you ran "flutter run",
          // or simply save your changes to "hot reload" in a Flutter IDE).
          // Notice that the counter didn't reset back to zero; the application
          // is not restarted.
          primarySwatch: Colors.blue),
      home: const MyHomePage(title: '공이와 묭이의 가계부'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin {
  late TabController controller;
  DateTime selectedDate = DateTime.now();
  late TextEditingController categoryContentConroller;
  int _selectedIndex = 0;
  late Future<AccountApplicationService> applicationservice;
  late Future<List> db;
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    controller = TabController(length: 2, vsync: this);
    applicationservice = initApplicationService();
    db = applicationservice.then((aas) => initDatabase(aas));
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      body: Center(
          child: IndexedStack(
        index: _selectedIndex,
        children: <Widget>[
          DailyAccount(db: db, applicationservice: applicationservice),
          WeeklyResult(db: db, applicationservice: applicationservice)
        ],
      )),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.addchart),
            label: 'Chart',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.black,
        onTap: _onItemTapped,
      ),
    );
  }

  Future<AccountApplicationService> initApplicationService() async {
    String jsonString = await rootBundle.loadString('assets/json/env.json');
    final jsonResponse = json.decode(jsonString);
    String databaseString =
        await rootBundle.loadString('assets/json/database_info.json');
    final databaseInfo = json.decode(databaseString);
    var repo = AccountRepository(jsonResponse['NOTION_KEY'], '2022-02-22');
    return AccountApplicationService(repo, databaseInfo);
  }

  Future<List> initDatabase(AccountApplicationService acs) async {
    final String dateStr = DateFormat('yyyyMM').format(DateTime.now());
    return acs.load(dateStr);
  }
}
