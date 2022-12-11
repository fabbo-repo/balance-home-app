
import 'package:balance_home_app/src/core/providers/localization_provider.dart';
import 'package:balance_home_app/src/features/expense/data/models/expense_model.dart';
import 'package:balance_home_app/src/features/revenue/data/models/revenue_model.dart';
import 'package:balance_home_app/src/features/statistics/data/models/selected_exchange_model.dart';
import 'package:balance_home_app/src/features/statistics/data/models/statistics_data_model.dart';
import 'package:balance_home_app/src/features/statistics/logic/providers/selected_exchange/selected_exchange_model_provider.dart';
import 'package:balance_home_app/src/features/statistics/logic/providers/selected_exchange/selected_exchange_model_state_notifier.dart';
import 'package:balance_home_app/src/features/statistics/presentation/widgets/currency/currency_line_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CurrencyChartContainer extends ConsumerWidget {
  final StatisticsDataModel statisticsData;

  const CurrencyChartContainer({
    required this.statisticsData,
    super.key
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appLocalizations = ref.watch(localizationStateNotifierProvider).localization;
    SelectedExchangeModel selectedExchange = ref.watch(selectedExchangeStateNotifierProvider).model;
    SelectedExchangeModelStateNotifier selectedExchangeDateNotifier = ref.read(selectedExchangeStateNotifierProvider.notifier);
    // Coin codes list
    List<String> coins = statisticsData.coinTypes.map((e) => e.code).toList();
    String selectedCoinFrom = selectedExchange.selectedCoinFrom;
    String selectedCoinTo = selectedExchange.selectedCoinTo;
    // Screen sizes:
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    double chartLineHeight = (screenHeight * 0.65 <= 350) ? 
      350 : (screenHeight * 0.65 <= 500) ? screenHeight * 0.65 : 500;
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 20, bottom: 10),
              color: const Color.fromARGB(255, 61, 138, 247),
              height: 45,
              width: screenWidth * 0.70,
              child: Center(
                child: Text(
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold
                  ),
                  appLocalizations.currencyChartTitle
                )
              ),
            ),
            Container(
              margin: const EdgeInsets.only(top: 20, bottom: 10),
              color: const Color.fromARGB(255, 117, 169, 249),
              padding: const EdgeInsets.only(left: 10, right: 10),
              height: 45,
              child: DropdownButton<String>(
                value: selectedCoinFrom,
                items: coins.map(
                  (coin) {
                    return DropdownMenuItem<String>(
                      value: coin,
                      child: Text(coin),
                    );
                  }
                ).toList(),
                onChanged: (coin) {
                  selectedExchangeDateNotifier.setSelectedCoinFrom(
                    coin!
                  );
                }
              ),
            ),
            Container(
              margin: const EdgeInsets.only(top: 20, bottom: 10),
              color: const Color.fromARGB(255, 117, 169, 249),
              padding: const EdgeInsets.only(left: 10, right: 10),
              height: 45,
              child: DropdownButton<String>(
                value: selectedCoinTo,
                items: coins.map(
                  (coin) {
                    return DropdownMenuItem<String>(
                      value: coin,
                      child: Text(coin),
                    );
                  }
                ).toList(),
                onChanged: (coin) {
                  selectedExchangeDateNotifier.setSelectedCoinTo(
                    coin!
                  );
                }
              ),
            )
          ],
        ),
        SizedBox(
          height: chartLineHeight,
          width: screenWidth * 0.90,
          child: CurrencyLineChart(
            selectedCoinFrom: statisticsData.selectedCoinFrom,
            selectedCoinTo: statisticsData.selectedCoinTo,
            dateExchangesModel: statisticsData.dateExchangesModel,
          )
        ),
      ],
    );
  }

  List<ExpenseModel> getExpenses(int month) {
    List<ExpenseModel> expenses = [];
    for (ExpenseModel expense in statisticsData.expenses) {
      if (expense.date.month == month) expenses.add(expense);
    }
    return expenses;
  }
  
  List<RevenueModel> getRevenues(int month) {
    List<RevenueModel> revenues = [];
    for (RevenueModel revenue in statisticsData.revenues) {
      if (revenue.date.month == month) revenues.add(revenue);
    }
    return revenues;
  }
}