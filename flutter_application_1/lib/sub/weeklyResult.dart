import 'package:flutter/material.dart';
import '../object/AccountApplicationService.dart';
import '../object/account.dart';
import 'package:pie_chart/pie_chart.dart';

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

  void calcMap() {
    int week = getWeek(selectedDate);
    widget.db.then((value) {
      value.forEach((element) {
        int elementWeek = getWeek(DateTime.parse(element.date));
        if (elementWeek == week) {
          dataMap.update(element.category, (value) => value + element.ammount,
              ifAbsent: () => element.ammount.toDouble());
        }
      });
    });
  }

  @override
  void initState() {
    super.initState();
    calcMap();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PieChart(
        dataMap: dataMap,
        animationDuration: const Duration(milliseconds: 800),
        chartLegendSpacing: 32,
        chartRadius: MediaQuery.of(context).size.width / 3.2,
        initialAngleInDegree: 0,
        chartType: ChartType.ring,
        ringStrokeWidth: 32,
        legendOptions: const LegendOptions(
          showLegendsInRow: false,
          legendPosition: LegendPosition.bottom,
          showLegends: true,
          legendTextStyle: TextStyle(
            fontWeight: FontWeight.bold,
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
