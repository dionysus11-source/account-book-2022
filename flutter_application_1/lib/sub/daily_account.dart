import 'package:flutter/material.dart';
import '../object/account_application_service.dart';
import '../object/account.dart';
import 'package:intl/intl.dart';
import './edit_alert.dart';

class DailyAccount extends StatefulWidget {
  final Future<List> db;
  final Future<AccountApplicationService> applicationservice;
  final void Function(DateTime selected) refreshAccount;
  const DailyAccount(
      {Key? key,
      required this.db,
      required this.applicationservice,
      required this.refreshAccount})
      : super(key: key);
  @override
  _DailyAccountState createState() => _DailyAccountState();
}

class _DailyAccountState extends State<DailyAccount> {
  late TextEditingController contentConroller;
  late TextEditingController amountConroller;
  DateTime selectedDate = DateTime.now();
  late String _category;
  List<String> choices = <String>['내역 수정', '삭제'];
  void _select(String choice, Account data) async {
    if (choice == '삭제') {
      await widget.applicationservice.then((value) {
        value.deleteItem(data);
      });
      widget.refreshAccount(selectedDate);
    } else if (choice == '내역 수정') {
      widget.db.then((db) {
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return EditAlert(
                  title: '내역 수정',
                  updateAccount: widget.refreshAccount,
                  db: db,
                  applicationservice: widget.applicationservice,
                  account: data);
            });
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _category = '식비';
  }

  void _onValueChange(String value) {
    setState(() {
      _category = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          '가계부',
          style: TextStyle(color: Colors.black),
        ),
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
                  widget.refreshAccount(selectedDate);
                });
                // 가계부 리스트  업데이트 추가
              });
            },
            child: Text(
              DateFormat('yyyy-MM-dd').format(selectedDate),
              style: const TextStyle(color: Colors.black),
            ),
          )
        ],
      ),
      body: Center(
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
              return RefreshIndicator(
                  child: ListView.builder(
                    controller: ScrollController(),
                    itemBuilder: (context, index) {
                      return Card(
                        elevation: 5,
                        margin: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 20),
                        child: ListTile(
                          title: Text(data[index].content),
                          subtitle: Text(data[index].category),
                          leading: Text(data[index].date),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Text(f.format(data[index].ammount).toString() +
                                  '원'),
                              PopupMenuButton(
                                onSelected: (String value) async {
                                  _select(value, data[index]);
                                },
                                padding: EdgeInsets.zero,
                                itemBuilder: (BuildContext context) {
                                  return choices.map((String choice) {
                                    return PopupMenuItem<String>(
                                      value: choice,
                                      child: Text(choice),
                                    );
                                  }).toList();
                                },
                              )
                            ],
                          ),
                        ),
                      );
                    },
                    itemCount: length,
                  ),
                  onRefresh: () {
                    return Future.delayed(const Duration(seconds: 1), () {
                      widget.refreshAccount(selectedDate);
                    });
                  });
            }
            return const Text('No data');
          },
          future: widget.db,
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color.fromRGBO(254, 110, 14, 1),
        onPressed: () async {
          contentConroller = TextEditingController();
          amountConroller = TextEditingController();
          showDialog(
              context: context,
              builder: (BuildContext context) {
                return StatefulBuilder(builder: (context, setState) {
                  return AlertDialog(
                    title: const Text('내역 추가'),
                    content: Column(mainAxisSize: MainAxisSize.min, children: <
                        Widget>[
                      const Divider(color: Color.fromRGBO(251, 251, 251, 1)),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton(
                          onPressed: () {
                            final selected = showDatePicker(
                                context: context,
                                initialDate: selectedDate,
                                firstDate: DateTime(2022),
                                lastDate: DateTime(2030));
                            selected.then((dateTime) {
                              setState(() {
                                selectedDate = dateTime as DateTime;
                              });
                            });
                          },
                          child: Text(
                            DateFormat('yyyy-MM-dd').format(selectedDate),
                            style: const TextStyle(
                                color: Colors.black, fontSize: 16),
                          ),
                          style: TextButton.styleFrom(
                              padding: const EdgeInsets.all(0)),
                        ),
                      ),
                      const Divider(color: Color.fromRGBO(251, 251, 251, 1)),
                      MyDialog(
                        onValueChange: _onValueChange,
                        initialValue: _category,
                      ),
                      const Divider(color: Color.fromRGBO(251, 251, 251, 1)),
                      TextField(
                          controller: contentConroller,
                          keyboardType: TextInputType.text,
                          decoration: const InputDecoration(
                              hintText: '내용', border: InputBorder.none)),
                      const Divider(color: Color.fromRGBO(251, 251, 251, 1)),
                      TextField(
                        controller: amountConroller,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                            hintText: '금액', border: InputBorder.none),
                      ),
                    ]),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text(
                          '취소',
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
                      TextButton(
                        onPressed: () async {
                          Account result = Account(
                              category: _category,
                              ammount: int.parse(amountConroller.value.text),
                              date:
                                  DateFormat('yyyy-MM-dd').format(selectedDate),
                              content: contentConroller.value.text);
                          await widget.applicationservice
                              .then((value) => {value.save(result)});
                          widget.refreshAccount(selectedDate);
                          Navigator.of(context).pop();
                        },
                        child: const Text(
                          '저장',
                          style:
                              TextStyle(color: Color.fromRGBO(217, 134, 74, 1)),
                        ),
                      ),
                    ],
                  );
                });
              });
        },
        child: const Icon(
          Icons.edit,
          //color: Color.fromRGBO(254, 110, 14, 1),
        ),
      ), // This trailing comma
    );
  }
}

class MyDialog extends StatefulWidget {
  const MyDialog(
      {Key? key, required this.onValueChange, required this.initialValue})
      : super(key: key);

  final String initialValue;
  final void Function(String) onValueChange;

  @override
  State createState() => MyDialogState();
}

class MyDialogState extends State<MyDialog> {
  String _selectedId = '식비';

  @override
  void initState() {
    super.initState();
    _selectedId = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      isExpanded: true,
      hint: const Text("Pick a thing"),
      value: _selectedId,
      onChanged: (value) {
        setState(() {
          _selectedId = value as String;
        });
        widget.onValueChange(value as String);
      },
      items: <String>[
        '식비',
        '의복미용',
        '생활용품',
        '의료',
        '기타',
        '교통',
        '여가활동',
        '용돈',
        '육아',
        '꿈지출'
      ].map((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
    );
  }
}
