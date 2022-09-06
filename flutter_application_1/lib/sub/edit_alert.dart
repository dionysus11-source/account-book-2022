import 'package:flutter/material.dart';
import '../object/account.dart';
import '../object/AccountApplicationService.dart';

class EditAlert extends StatefulWidget {
  final String title;
  final DateTime selectedDate;
  final void Function() updateAccount;
  Future<List> db;
  final Future<AccountApplicationService> applicationservice;
  final Account account;
  EditAlert(
      {Key? key,
      required this.title,
      required this.selectedDate,
      required this.updateAccount,
      required this.db,
      required this.applicationservice,
      required this.account})
      : super(key: key);
  @override
  EditAlertState createState() => EditAlertState();
}

class EditAlertState extends State<EditAlert> {
  String _category = '식비';
  void _onValueChange(String value) {
    setState(() {
      _category = value;
    });
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
            alignment: Alignment.centerLeft, child: Text(widget.account.date)),
        const Divider(color: Color.fromRGBO(251, 251, 251, 1)),
        MyDialog(
          initialValue: _category,
          onValueChange: _onValueChange,
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
          decoration:
              const InputDecoration(hintText: '금액', border: InputBorder.none),
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
                date: widget.account.date,
                content: contentConroller.value.text);
            await widget.applicationservice
                .then((value) => {value.editItem(widget.account, result)});
            widget.updateAccount();
            //Future.delayed(const Duration(milliseconds: 1000), () {
            // widget.db =
            ////      widget.applicationservice.then((val) => val.load(dateStr));
            Navigator.of(context).pop();
            //});
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
  const MyDialog({required this.initialValue, required this.onValueChange});
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
