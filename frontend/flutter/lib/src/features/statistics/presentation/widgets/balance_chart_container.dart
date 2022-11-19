
import 'package:balance_home_app/src/features/statistics/presentation/widgets/balance_line_chart.dart';
import 'package:flutter/material.dart';

class BalanceChartContainer extends StatefulWidget {
  const BalanceChartContainer({super.key});

  @override
  State<BalanceChartContainer> createState() => _BalanceChartContainerState();
}

class _BalanceChartContainerState extends State<BalanceChartContainer> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 20, bottom: 10),
              color: const Color.fromARGB(255, 114, 187, 83),
              height: 45,
              width: MediaQuery.of(context).size.width * 0.35,
              child: Center(
                child: Text("AAAAAAAAAAAAAAA")
              ),
            ),
            Container(
              margin: const EdgeInsets.only(top: 20, bottom: 10),
              color: const Color.fromARGB(255, 195, 187, 56),
              padding: const EdgeInsets.only(left: 10, right: 10),
              height: 45,
              child: DropdownButton<String>(
                value: "uno",
                items: [
                  DropdownMenuItem<String>(
                    value: "uno",
                    child: Text("aaaaaaa"),
                  )
                ], 
                onChanged: (value) {}
              ),
            )
          ],
        ),
        SizedBox(
          height: 350,
          width: MediaQuery.of(context).size.width * 0.45,
          child: BalanceLineChart()
        ),
      ],
    );
  }
}