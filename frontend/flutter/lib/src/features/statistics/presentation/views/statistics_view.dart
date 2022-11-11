import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';

class StatisticsView extends StatelessWidget {
  const StatisticsView({super.key});

  @override
  Widget build(BuildContext context) {
    List<Map<String, int>> data = [
      {
        "atrr1" : 1,
        "atrr2" : 100
      },
      {
        "atrr1" : 2,
        "atrr2" : 200
      },
      {
        "atrr1" : 3,
        "atrr2" : 300
      }
    ];
    List<charts.Series<Map<String, int>, int>> series = [
      charts.Series(
        id: "developers",
        data: data,
        domainFn: (Map<String, int> series, _) => series["atrr1"]!,
        measureFn: (Map<String, int> series, _) => series["atrr2"],
        colorFn: (Map<String, int> series, _) => charts.ColorUtil.fromDartColor(Colors.green)
      )
    ];
    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            color: const Color.fromARGB(254, 254, 252, 224),
            foregroundDecoration: borderDecoration(),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: 400,
                  width: MediaQuery.of(context).size.width * 0.45,
                  child: charts.LineChart(series, animate: true)
                ),
                SizedBox(
                  height: 400,
                  width: MediaQuery.of(context).size.width * 0.45,
                  child: charts.LineChart(series, animate: true)
                ),
              ],
            ),
          ),
          Container(
            color: const Color.fromARGB(254, 254, 252, 224),
            foregroundDecoration: borderDecoration(),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: 400,
                  width: MediaQuery.of(context).size.width * 0.45,
                  child: charts.LineChart(series, animate: true)
                ),
                SizedBox(
                  height: 400,
                  width: MediaQuery.of(context).size.width * 0.45,
                  child: charts.LineChart(series, animate: true)
                ),
              ],
            ),
          ),
          Container(
            color: const Color.fromARGB(254, 201, 241, 253),
            foregroundDecoration: borderDecoration(),
            child: Center(
              child: SizedBox(
                height: 600,
                width: MediaQuery.of(context).size.width * 0.95,
                child: charts.LineChart(series, animate: true)
              ),
            ),
          ),
        ],
      ),
    );
  }

  BoxDecoration borderDecoration() {
    return BoxDecoration(
      border: Border.all(),
    );
  }
}