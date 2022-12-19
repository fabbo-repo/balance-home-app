import 'package:balance_home_app/src/core/data/models/selected_date_enum.dart';
import 'package:balance_home_app/src/core/data/models/selected_date_model.dart';
import 'package:balance_home_app/src/core/providers/selected_date/selected_date_state_notifier.dart';
import 'package:balance_home_app/src/core/widgets/future_widget.dart';
import 'package:balance_home_app/src/features/balance/data/models/balance_limit_type_enum.dart';
import 'package:balance_home_app/src/features/balance/data/models/balance_model.dart';
import 'package:balance_home_app/src/features/balance/data/models/balance_type_enum.dart';
import 'package:balance_home_app/src/features/balance/data/repositories/balance_repository.dart';
import 'package:balance_home_app/src/features/balance/logic/providers/balance_limit_type/balance_limit_type_state.dart';
import 'package:balance_home_app/src/features/balance/logic/providers/balance_limit_type/balance_limit_type_state_notifier.dart';
import 'package:balance_home_app/src/features/balance/logic/providers/balance_list/balance_list_state_notifier.dart';
import 'package:balance_home_app/src/features/balance/logic/providers/balance_provider.dart';
import 'package:balance_home_app/src/features/balance/presentation/widgets/balance_right_panel.dart';
import 'package:balance_home_app/src/features/revenue/logic/providers/revenue_limit_type_provider.dart';
import 'package:balance_home_app/src/features/revenue/logic/providers/revenue_list_provider.dart';
import 'package:balance_home_app/src/features/revenue/logic/providers/selected_revenue_date_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RevenueView extends ConsumerWidget {
  const RevenueView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final balanceRepository = ref.read(balanceRepositoryProvider);
    final revenueListNotifier = ref.read(revenueListProvider.notifier);
    final selectedRevenueDateNotifier = ref.read(
      selectedRevenueDateStateNotifierProvider.notifier);
    return FutureWidget<bool>(
      childCreation: (_) {
        return BalanaceRightPanel(balanceTypeEnum: BalanceTypeEnum.revenue);
      },
      future: fetchData(
        balanceRepository,
        revenueListNotifier,
        selectedRevenueDateNotifier
      )
    );
  }

  @visibleForTesting
  Future<bool> fetchData(
    IBalanceRepository balanceRepository,
    BalanceListStateNotifier revenueListNotifier,
    SelectedDateStateNotifier selectedRevenueDateNotifier
  ) async {
    List<BalanceModel> balances = [];
    SelectedDateModel selectedDate = selectedRevenueDateNotifier.getSelectedDate();
    if (selectedDate.selectedDateMode == SelectedDateEnum.day) {
      DateTime date = DateTime(
        selectedDate.year,
        selectedDate.month,
        selectedDate.day
      );
      balances = await balanceRepository.getBalances(
        BalanceTypeEnum.revenue,
        dateFrom: date,
        dateTo: date
      );
    } else if (selectedDate.selectedDateMode == SelectedDateEnum.month) {
      DateTime dateFrom = DateTime(
        selectedDate.year,
        selectedDate.month,
        1
      );
      DateTime dateTo = DateTime(
        selectedDate.year,
        selectedDate.month,
        DateUtils.getDaysInMonth(
          selectedDate.year, selectedDate.month)
      );
      balances = await balanceRepository.getBalances(
        BalanceTypeEnum.revenue,
        dateFrom: dateFrom,
        dateTo: dateTo
      );
    } else if (selectedDate.selectedDateMode == SelectedDateEnum.year) {
      DateTime dateFrom = DateTime(
        selectedDate.year,
        1,
        1
      );
      DateTime dateTo = DateTime(
        selectedDate.year,
        12,
        DateUtils.getDaysInMonth(
          selectedDate.year, 12)
      );
      balances = await balanceRepository.getBalances(
        BalanceTypeEnum.revenue,
        dateFrom: dateFrom,
        dateTo: dateTo
      );
    }
    revenueListNotifier.setBalances(balances);
    return true;
  }
}