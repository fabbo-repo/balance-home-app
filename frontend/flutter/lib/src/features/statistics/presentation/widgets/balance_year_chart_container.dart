
import 'package:balance_home_app/src/core/providers/localization_provider.dart';
import 'package:balance_home_app/src/core/utils/date_util.dart';
import 'package:balance_home_app/src/features/statistics/data/models/selected_date_model.dart';
import 'package:balance_home_app/src/features/statistics/logic/providers/selected_date/selected_date_model_provider.dart';
import 'package:balance_home_app/src/features/statistics/logic/providers/selected_date/selected_date_model_state_notifier.dart';
import 'package:balance_home_app/src/features/statistics/presentation/widgets/balance_year_line_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BalanceYearChartContainer extends ConsumerWidget {

  const BalanceYearChartContainer({super.key});
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appLocalizations = ref.watch(localizationStateNotifierProvider).localization;
    SelectedDateModel selectedBalanceDate = ref.watch(selectedBalanceDateStateNotifierProvider).model;
    SelectedDateModelStateNotifier selectedBalanceDateNotifier = ref.read(selectedBalanceDateStateNotifierProvider.notifier);
    List<int> years = []; // TODO add provider with watch
    int selectedYear = selectedBalanceDate.year;
    // Month names list
    List<String> months = DateUtil.getMonthList(appLocalizations);
    // Adding selected year to years list
    if (!years.contains(selectedYear)) years.add(selectedYear);
    // Adding current year to years list
    if (!years.contains(DateTime.now().year)) years.add(DateTime.now().year);
    // Screen sizes:
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    double chartLineHeight = (screenHeight * 0.45 <= 200) ? 
      200 : (screenHeight * 0.45 <= 350) ? screenHeight * 0.45 : 350;
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
                child: Text(
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold
                  ),
                  "${appLocalizations.balanceChartTitle} $selectedYear"
                )
              ),
            ),
            Container(
              margin: const EdgeInsets.only(top: 20, bottom: 10),
              color: const Color.fromARGB(255, 195, 187, 56),
              padding: const EdgeInsets.only(left: 10, right: 10),
              height: 45,
              child: DropdownButton<int>(
                value: selectedYear,
                items: years.map(
                  (year) {
                    return DropdownMenuItem<int>(
                      value: year,
                      child: Text(year.toString()),
                    );
                  }
                ).toList(),
                onChanged: (year) {
                  selectedBalanceDateNotifier.setYear(year!);
                }
              ),
            )
          ],
        ),
        SizedBox(
          height: chartLineHeight,
          width: screenWidth * 0.45,
          child: BalanceLineChart(
            monthList: months,
          )
        ),
      ],
    );
  }
}