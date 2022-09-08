import 'package:flutter/material.dart';
import '../object/AccountApplicationService.dart';
import '../object/account.dart';
import 'package:pie_chart/pie_chart.dart';
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
  late Map<String, double> dataMap = {'식비': 0};
  DateTime selectedDate = DateTime.now();

  int getWeek(DateTime date) {
    int day = date.day - 1;
    int ret = (day ~/ 7).toInt() + 1;
    return ret;
  }

  Map<String, double> calcMap(Future<List> data) {
    Map<String, double> temp = {'식비': 0};
    int week = getWeek(selectedDate);
    data.then((value) {
      value.forEach((element) {
        int elementWeek = getWeek(DateTime.parse(element.date));
        if (elementWeek == week) {
          temp.update(element.category, (value) => value + element.ammount,
              ifAbsent: () => element.ammount.toDouble());
        }
      });
      temp.forEach((key, value) {
        temp.update(key, (value) => value / 10000);
      });
      return temp;
    });
    return temp;
  }

  updateMap(Future<List> data) {
    setState(() {
      dataMap = calcMap(data);
    });
  }

  @override
  void initState() {
    super.initState();
    updateMap(widget.db);
  }

  @override
  Widget build(BuildContext context) {
    print('build is called');
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
              late Future<List> newData;
              selected.then((dateTime) {
                setState(() {
                  selectedDate = dateTime as DateTime;
                  final String dateStr =
                      DateFormat('yyyyMM').format(selectedDate);
                  newData = widget.applicationservice
                      .then((val) => val.load(dateStr));
                });
                updateMap(newData);
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
      body: PieChart(
        dataMap: dataMap,
        animationDuration: const Duration(milliseconds: 800),
        chartLegendSpacing: 32,
        chartRadius: MediaQuery.of(context).size.width / 2.5,
        initialAngleInDegree: 0,
        chartType: ChartType.ring,
        ringStrokeWidth: 32,
        legendOptions: const LegendOptions(
          showLegendsInRow: false,
          legendPosition: LegendPosition.bottom,
          showLegends: true,
          legendTextStyle: TextStyle(
            fontWeight: FontWeight.normal,
          ),
        ),
        chartValuesOptions: const ChartValuesOptions(
          showChartValueBackground: true,
          showChartValues: true,
          showChartValuesInPercentage: false,
          showChartValuesOutside: false,
          decimalPlaces: 1,
        ),
        // gradientList: ---To add gradient colors---
        // emptyColorGradient: ---Empty Color gradient---
      ),
    );
  }
}
