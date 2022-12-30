import 'package:balance_home_app/config/app_colors.dart';
import 'package:balance_home_app/config/platform_utils.dart';
import 'package:balance_home_app/src/core/presentation/models/selected_date_mode.dart';
import 'package:balance_home_app/src/core/providers.dart';
import 'package:balance_home_app/src/core/utils/date_util.dart';
import 'package:balance_home_app/src/features/balance/domain/entities/balance_entity.dart';
import 'package:balance_home_app/src/features/balance/domain/repositories/balance_type_mode.dart';
import 'package:balance_home_app/src/features/balance/presentation/widgets/balance_bar_chart.dart';
import 'package:balance_home_app/src/features/balance/presentation/widgets/balance_line_chart.dart';
import 'package:balance_home_app/src/features/balance/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BalanaceLeftPanel extends ConsumerWidget {
  final List<BalanceEntity> balances;
  final BalanceTypeMode balanceTypeMode;

  const BalanaceLeftPanel({required this.balances, required this.balanceTypeMode, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appLocalizations = ref.watch(appLocalizationsProvider);
    final theme = ref.watch(themeModeProvider);
    final selectedDate = balanceTypeMode == BalanceTypeMode.expense
        ? ref.watch(expenseSelectedDateProvider)
        : ref.watch(revenueSelectedDateProvider);
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    double chartLineHeight = (screenHeight * 0.45 <= 300)
        ? 300
        : (screenHeight * 0.45 <= 400)
            ? screenHeight * 0.45
            : 400;
    return Container(
      constraints: const BoxConstraints.expand(),
      color: balanceTypeMode == BalanceTypeMode.expense
          ? theme == ThemeMode.dark
              ? AppColors.expenseBackgroundDarkColor
              : AppColors.expenseBackgroundLightColor
          : theme == ThemeMode.dark
              ? AppColors.revenueBackgroundDarkColor
              : AppColors.revenueBackgroundLightColor,
      child: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: chartLineHeight * 1.1,
              width: PlatformUtils().isSmallWindow(context)
                  ? screenWidth * 0.95
                  : screenWidth * 0.45,
              child: BalanceBarChart(
                  balances: balances,
                  balanceType: balanceTypeMode),
            ),
            if (selectedDate.selectedDateMode != SelectedDateMode.day)
              SizedBox(
                height: chartLineHeight,
                width: PlatformUtils().isSmallWindow(context)
                    ? screenWidth * 0.95
                    : screenWidth * 0.45,
                child: BalanceLineChart(
                  monthList: DateUtil.getMonthList(appLocalizations),
                  revenues: (balanceTypeMode == BalanceTypeMode.revenue)
                      ? balances
                      : null,
                  expenses: balanceTypeMode == BalanceTypeMode.expense
                      ? balances
                      : null,
                  selectedDateMode: selectedDate.selectedDateMode,
                  selectedMonth: selectedDate.month,
                  selectedYear: selectedDate.year,
                ),
              )
          ],
        ),
      ),
    );
  }
}
