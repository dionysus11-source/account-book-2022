import 'package:flutter/material.dart';
import '../object/AccountApplicationService.dart';
import '../object/account.dart';

class WeeklyResult extends StatefulWidget {
  final Future<List> db;
  final Future<AccountApplicationService> applicationservice;
  const WeeklyResult(
      {Key? key, required this.db, required this.applicationservice})
      : super(key: key);
  @override
  _WeeklyResultState createState() => _WeeklyResultState();
}

class _WeeklyResultState extends State<WeeklyResult> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
          child: Center(
        child: FutureBuilder(
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              Account data = snapshot.data as Account;
              String title = data.category;
              String content = 'test';
              return ListView.builder(
                itemBuilder: (context, index) {
                  return Card(
                    elevation: 5,
                    margin: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 20),
                    child:
                        ListTile(title: Text(title), subtitle: Text(content)),
                  );
                },
                itemCount: title.length,
              );
            }
            return const Text('No data');
          },
          future: widget.db,
        ),
      )),
    );
  }
}
