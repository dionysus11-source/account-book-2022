import 'package:flutter/material.dart';
import '../object/AccountApplicationService.dart';
import '../object/account.dart';
import 'package:intl/intl.dart';

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
              List<dynamic> data = snapshot.data as List<dynamic>;

              data.sort((a, b) {
                return a.date
                    .toString()
                    .toLowerCase()
                    .compareTo(b.date.toString().toLowerCase());
              });
              data = data.reversed.toList();
              int length = data.length;
              var f = NumberFormat('###,###,###,###');
              return ListView.builder(
                itemBuilder: (context, index) {
                  return Card(
                    elevation: 5,
                    margin: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 20),
                    child: ListTile(
                      title: Text(data[index].content),
                      subtitle: Text(data[index].category),
                      leading: Text(data[index].date),
                      trailing:
                          Text(f.format(data[index].ammount).toString() + '원'),
                    ),
                  );
                },
                itemCount: length,
              );
            }
            return Text('No data');
          },
          future: widget.db,
        ),
      )),
    );
  }
}
