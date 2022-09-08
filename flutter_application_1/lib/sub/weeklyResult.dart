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
  late Map<String, double> weeklyDataMap = {'식비': 0};
  late Map<String, double> monthlyDataMap = {'식비': 0};
  DateTime selectedDate = DateTime.now();

  int getWeek(DateTime date) {
    int day = date.day - 1;
    int ret = (day ~/ 7).toInt() + 1;
    return ret;
  }

  Map<String, double> calcWeekMap(List data) {
    Map<String, double> temp = {'식비': 0};
    int week = getWeek(selectedDate);
    data.forEach((element) {
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
  }

  Map<String, double> calcMonthMap(List data) {
    Map<String, double> temp = {'식비': 0};
    data.forEach((element) {
      temp.update(element.category, (value) => value + element.ammount,
          ifAbsent: () => element.ammount.toDouble());
    });
    temp.forEach((key, value) {
      temp.update(key, (value) => value / 10000);
    });
    var sortMapByValue = Map.fromEntries(
        temp.entries.toList()..sort((e1, e2) => e2.value.compareTo(e1.value)));
    return sortMapByValue;
  }

  updateMaps(List data) {
    setState(() {
      weeklyDataMap = calcWeekMap(data);
      monthlyDataMap = calcMonthMap(data);
    });
  }

  @override
  void initState() {
    super.initState();
    widget.db.then((value) {
      updateMaps(value);
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
                late Future<List> newData;
                selected.then((dateTime) {
                  selectedDate = dateTime as DateTime;
                  final String dateStr =
                      DateFormat('yyyyMM').format(selectedDate);
                  newData = widget.applicationservice
                      .then((val) => val.load(dateStr));
                  newData.then((value) {
                    updateMaps(value);
                  });
                });
              },
              child: Text(
                DateFormat('yyyy-MM-dd').format(selectedDate),
                style: const TextStyle(color: Colors.black),
              ),
            )
          ],
        ),
        body: Column(
          children: <Widget>[
            const SizedBox(
              height: 50,
            ),
            PieChart(
              dataMap: weeklyDataMap,
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
            Text(selectedDate.month.toString() +
                '월 ' +
                getWeek(selectedDate).toString() +
                '주 : ' +
                weeklyDataMap.values
                    .reduce(
                      (value, element) => value + element,
                    )
                    .toInt()
                    .toString() +
                '만원, ' +
                selectedDate.month.toString() +
                '월 합계: ' +
                monthlyDataMap.values
                    .reduce(
                      (value, element) => value + element,
                    )
                    .toInt()
                    .toString() +
                '만원'),
            const SizedBox(height: 30),
            Expanded(
              child: ListView.builder(
                  scrollDirection: Axis.vertical,
                  controller: ScrollController(),
                  itemCount: monthlyDataMap.length,
                  itemBuilder: (context, index) {
                    String key = monthlyDataMap.keys.elementAt(index);
                    String month = selectedDate.month.toString() + '월';
                    return Card(
                      child: ListTile(
                        leading: Text(month),
                        title: Text(key),
                        trailing: Text(monthlyDataMap[key].toString() + ' 만원'),
                        //title: Text('test'),
                      ),
                    );
                  }),
            )
          ],
        ));
  }
}
