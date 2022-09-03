import 'package:flutter/material.dart';
import '../object/AccountApplicationService.dart';
import '../object/account.dart';
import 'package:intl/intl.dart';

class DailyAccount extends StatefulWidget {
  Future<List> db;
  Future<AccountApplicationService> applicationservice;
  DailyAccount({Key? key, required this.db, required this.applicationservice})
      : super(key: key);
  @override
  _DailyAccountState createState() => _DailyAccountState();
}

class _DailyAccountState extends State<DailyAccount> {
  late TextEditingController categoryContentConroller;
  DateTime selectedDate = DateTime.now();
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    print('test');
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: const Text('공이와 묭이의 가계부'),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              final selected = showDatePicker(
                  context: context,
                  initialDate: selectedDate,
                  firstDate: DateTime(2022),
                  lastDate: DateTime(2030));
              selected.then((dateTime) {
                setState(() {
                  selectedDate = dateTime as DateTime;
                  final String dateStr =
                      DateFormat('yyyyMM').format(selectedDate);
                  widget.db = widget.applicationservice
                      .then((val) => val.load(dateStr));
                  //widget.db = widget.applicationservice.load(dateStr);
                });
                // 가계부 리스트  업데이트 추가
              });
            },
            child: Text(
              DateFormat.yMMMEd().format(selectedDate),
              style: const TextStyle(color: Colors.white),
            ),
          )
        ],
      ),
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
              return ListView.builder(
                itemBuilder: (context, index) {
                  return Card(
                    elevation: 5,
                    margin: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                    child: ListTile(
                      title: Text(data[index].content),
                      subtitle: Text(data[index].category),
                      leading: Text(data[index].date),
                      trailing: Text(data[index].ammount.toString() + '원'),
                    ),
                  );
                },
                itemCount: length,
              );
            }
            return const Text('No data');
          },
          future: widget.db,
        ),
      )),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          categoryContentConroller = new TextEditingController();
          await showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text('더하기'),
                  content: Column(children: <Widget>[
                    TextField(
                        controller: categoryContentConroller,
                        keyboardType: TextInputType.text)
                  ]),
                  actions: <Widget>[
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text('취소'),
                    ),
                    TextButton(
                      onPressed: () {
                        Account result = Account(
                            category: '식비',
                            ammount: 1500,
                            date: '2022-09-02',
                            content: '스타벅스');
                        widget.applicationservice
                            .then((value) => {value.save('202209', result)});
                        Future.delayed(const Duration(milliseconds: 1000), () {
                          setState(() {
                            final String dateStr =
                                DateFormat('yyyyMM').format(selectedDate);
                            widget.db = widget.applicationservice
                                .then((val) => val.load(dateStr));
                          });
                          Navigator.of(context).pop();
                        });
                      },
                      child: const Text('저장'),
                    ),
                  ],
                );
              });
        },
        child: const Icon(Icons.edit),
      ), // This trailing comma
    );
  }
}
