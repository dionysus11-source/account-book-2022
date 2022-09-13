import 'package:flutter/material.dart';
import '../object/account.dart';
import '../object/account_application_service.dart';
import 'package:intl/intl.dart';

class EditAlert extends StatefulWidget {
  final String title;
  final void Function() updateAccount;
  final List db;
  final Future<AccountApplicationService> applicationservice;
  final Account account;
  const EditAlert(
      {Key? key,
      required this.title,
      required this.updateAccount,
      required this.db,
      required this.applicationservice,
      required this.account})
      : super(key: key);
  @override
  EditAlertState createState() => EditAlertState();
}

class EditAlertState extends State<EditAlert> {
  late String _category;
  late DateTime _toDate;
  void _onValueChange(String value) {
    setState(() {
      _category = value;
    });
  }

  @override
  void initState() {
    super.initState();
    _category = widget.account.category;
    _toDate = DateTime.parse(widget.account.date);
  }

  @override
  Widget build(BuildContext context) {
    TextEditingController contentConroller = TextEditingController();
    TextEditingController amountConroller = TextEditingController();
    return AlertDialog(
      title: Text(widget.title),
      content: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
        const Divider(color: Color.fromRGBO(251, 251, 251, 1)),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton(
            onPressed: () {
              final selected = showDatePicker(
                  context: context,
                  initialDate: _toDate,
                  firstDate: DateTime(2022),
                  lastDate: DateTime(2030));
              selected.then((dateTime) {
                setState(() {
                  _toDate = dateTime as DateTime;
                });
              });
            },
            child: Text(
              DateFormat('yyyy-MM-dd').format(_toDate),
              style: const TextStyle(color: Colors.black, fontSize: 16),
            ),
            style: TextButton.styleFrom(padding: const EdgeInsets.all(0)),
          ),
        ),
        const Divider(color: Color.fromRGBO(251, 251, 251, 1)),
        MyDialog(
          initialValue: widget.account.category,
          onValueChange: _onValueChange,
        ),
        const Divider(color: Color.fromRGBO(251, 251, 251, 1)),
        TextField(
            controller: contentConroller,
            keyboardType: TextInputType.text,
            decoration: InputDecoration(
                hintText: widget.account.content, border: InputBorder.none)),
        const Divider(color: Color.fromRGBO(251, 251, 251, 1)),
        TextField(
          controller: amountConroller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
              hintText: widget.account.ammount.toString(),
              border: InputBorder.none),
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
            final int ammount;
            final String content;
            if (amountConroller.value.text == '') {
              ammount = widget.account.ammount;
            } else {
              ammount = int.parse(amountConroller.value.text);
            }
            if (contentConroller.value.text == '') {
              content = widget.account.content;
            } else {
              content = contentConroller.value.text;
            }
            Account result = Account(
                category: _category,
                ammount: ammount,
                date: DateFormat('yyyy-MM-dd').format(_toDate),
                content: content);
            await widget.applicationservice
                .then((value) => {value.editItem(widget.account, result)});
            widget.updateAccount();
            Navigator.of(context).pop();
          },
          child: const Text(
            '저장',
            style: TextStyle(color: Color.fromRGBO(217, 134, 74, 1)),
          ),
        ),
      ],
    );
  }
}

class MyDialog extends StatefulWidget {
  final void Function(String) onValueChange;
  const MyDialog(
      {Key? key, required this.initialValue, required this.onValueChange})
      : super(key: key);
  final String initialValue;

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
