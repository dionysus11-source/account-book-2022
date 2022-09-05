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
  late TextEditingController contentConroller;
  late TextEditingController amountConroller;
  DateTime selectedDate = DateTime.now();
  late String _category;

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
                    margin: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 20),
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
          contentConroller = TextEditingController();
          amountConroller = TextEditingController();
          await showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text('더하기'),
                  content: Column(children: <Widget>[
                    const Text(
                      '내용',
                      style: TextStyle(color: Colors.blue),
                    ),
                    TextField(
                        controller: contentConroller,
                        keyboardType: TextInputType.text),
                    const Text(
                      '날짜',
                      style: TextStyle(color: Colors.blue),
                    ),
                    Text(DateFormat('yyyy-MM-dd').format(selectedDate)),
                    MyDialog(
                      onValueChange: _onValueChange,
                      initialValue: _category,
                    ),
                    /*DropdownButton<String>(
                      hint: const Text("Pick a thing"),
                      value: _category,
                      onChanged: (value) {
                        setState(() {
                          _category = value as String;
                        });
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
                    ),*/
                    const Text(
                      '금액',
                      style: TextStyle(color: Colors.blue),
                    ),
                    TextField(
                        controller: amountConroller,
                        keyboardType: TextInputType.text),
                    /*
                    PopupMenuButton(
                      //onSelected: (value) => setState(() {
                      //  _category = value as String;
                      //}),
                      onSelected: (value) => {_onValueChange(value as String)},
                      itemBuilder: (_) => [
                        new CheckedPopupMenuItem(
                          checked: _category == Category.food,
                          value: '식비',
                          child: new Text('식비'),
                        ),
                        new CheckedPopupMenuItem(
                          checked: _category == Category.cloth,
                          value: '의복미용',
                          child: new Text('의복미용'),
                        ),
                        new CheckedPopupMenuItem(
                          checked: _category == Category.living,
                          value: '생활용품',
                          child: new Text('생활용품'),
                        ),
                      ],
                    ),*/
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
                            category: _category,
                            ammount: int.parse(amountConroller.value.text),
                            date: DateFormat('yyyy-MM-dd').format(selectedDate),
                            content: contentConroller.value.text);
                        widget.applicationservice.then((value) => {
                              value.save(
                                  DateFormat('yyyyMM').format(selectedDate),
                                  result)
                            });
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

class MyDialog extends StatefulWidget {
  const MyDialog({required this.onValueChange, required this.initialValue});

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
