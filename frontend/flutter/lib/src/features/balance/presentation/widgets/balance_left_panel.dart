import 'package:balance_home_app/src/core/infrastructure/datasources/selected_date_enum.dart';
import 'package:balance_home_app/src/core/providers/localization/localization_provider.dart';
import 'package:balance_home_app/src/core/services/platform_service.dart';
import 'package:balance_home_app/src/core/utils/date_util.dart';
import 'package:balance_home_app/src/features/balance/data/models/balance_type_enum.dart';
import 'package:balance_home_app/src/features/balance/logic/providers/balance_provider.dart';
import 'package:balance_home_app/src/features/balance/presentation/widgets/balance_bar_chart.dart';
import 'package:balance_home_app/src/features/balance/presentation/widgets/balance_line_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BalanaceLeftPanel extends ConsumerWidget {
  final BalanceTypeEnum balanceType;
  
  const BalanaceLeftPanel({
    required this.balanceType,
    super.key
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appLocalizations = ref.watch(localizationStateNotifierProvider).localization;
    final selectedBalanceDate = (balanceType == BalanceTypeEnum.expense) ? 
      ref.watch(selectedExpenseDateStateNotifierProvider).date 
      : ref.watch(selectedRevenueDateStateNotifierProvider).date;
    final balanceListProvider = (balanceType == BalanceTypeEnum.expense) ? 
      ref.watch(expenseListProvider) : ref.watch(revenueListProvider);
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    double chartLineHeight = (screenHeight * 0.45 <= 300) ? 
      300 : (screenHeight * 0.45 <= 400) ? screenHeight * 0.45 : 400;
    return Container(
      constraints: const BoxConstraints.expand(),
      color: (balanceType == BalanceTypeEnum.expense) ?
        const Color.fromARGB(254, 255, 236, 215) : 
        const Color.fromARGB(254, 223, 237, 214),
      child: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: chartLineHeight * 1.1,
              width: (PlatformService().isSmallWindow(context)) ? 
                screenWidth * 0.95 : screenWidth * 0.45,
              child: BalanceBarChart(
                balances: balanceListProvider.models,
                balanceType: balanceType
              ),
            ),
            if (selectedBalanceDate.selectedDateMode != SelectedDateEnum.day) 
              SizedBox(
                height: chartLineHeight,
                width: (PlatformService().isSmallWindow(context)) ? 
                  screenWidth * 0.95 : screenWidth * 0.45,
                child: BalanceLineChart(
                  monthList: DateUtil.getMonthList(appLocalizations),
                  revenues: (balanceType == BalanceTypeEnum.revenue) ? 
                    balanceListProvider.models : null,
                  expenses: (balanceType == BalanceTypeEnum.expense) ? 
                    balanceListProvider.models : null,
                  dateType: selectedBalanceDate.selectedDateMode,
                  selectedMonth: selectedBalanceDate.month,
                  selectedYear: selectedBalanceDate.year,
                ),
              )
          ],
        ),
      ),
    );
  }
}