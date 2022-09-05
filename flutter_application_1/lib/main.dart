import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
    Future<AccountApplicationService> accountApplicationService =
        initApplicationService();
    Future<List> database =
        accountApplicationService.then((aas) => initDatabase(aas));
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
      home: MyHomePage(
          title: '공이와 묭이의 가계부',
          db: database,
          applicationservice: accountApplicationService),
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

class MyHomePage extends StatefulWidget {
  Future<List> db;
  Future<AccountApplicationService> applicationservice;
  MyHomePage(
      {Key? key,
      required this.title,
      required this.db,
      required this.applicationservice})
      : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;
  void refesh(String date) {
    //db = applicationservice.load()
  }
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin {
  late TabController controller;
  DateTime selectedDate = DateTime.now();
  late TextEditingController categoryContentConroller;
  @override
  void initState() {
    super.initState();
    controller = TabController(length: 2, vsync: this);
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
      body: TabBarView(children: <Widget>[
        DailyAccount(
            db: widget.db, applicationservice: widget.applicationservice),
        WeeklyResult(
            db: widget.db, applicationservice: widget.applicationservice)
      ], controller: controller),
      bottomNavigationBar: TabBar(tabs: <Tab>[
        Tab(icon: Image.asset('assets/icon/daily.png', width: 24, height: 24)),
        Tab(icon: Image.asset('assets/icon/daily.png', width: 24, height: 24))
      ], controller: controller),
    );
  }
}
