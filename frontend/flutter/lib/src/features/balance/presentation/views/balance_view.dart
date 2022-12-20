import 'package:balance_home_app/src/core/data/models/selected_date_enum.dart';
import 'package:balance_home_app/src/core/data/models/selected_date_model.dart';
import 'package:balance_home_app/src/core/providers/localization/localization_provider.dart';
import 'package:balance_home_app/src/core/providers/selected_date/selected_date_state_notifier.dart';
import 'package:balance_home_app/src/core/utils/date_util.dart';
import 'package:balance_home_app/src/core/widgets/future_widget.dart';
import 'package:balance_home_app/src/core/widgets/responsive_layout.dart';
import 'package:balance_home_app/src/features/balance/data/models/balance_model.dart';
import 'package:balance_home_app/src/features/balance/data/models/balance_type_enum.dart';
import 'package:balance_home_app/src/features/balance/data/repositories/balance_repository.dart';
import 'package:balance_home_app/src/features/balance/logic/providers/balance_list/balance_list_state_notifier.dart';
import 'package:balance_home_app/src/features/balance/logic/providers/balance_provider.dart';
import 'package:balance_home_app/src/features/balance/presentation/widgets/balance_left_panel.dart';
import 'package:balance_home_app/src/features/balance/presentation/widgets/balance_right_panel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// ignore: must_be_immutable
class BalanceView extends ConsumerWidget {
  final BalanceTypeEnum balanceType;
  DateTime? lastDateFrom;
  DateTime? lastDateTo;
  
  BalanceView({
    required this.balanceType,
    super.key
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final balanceRepository = ref.read(balanceRepositoryProvider);
    final balanceListNotifier = (balanceType == BalanceTypeEnum.expense) ? 
      ref.read(expenseListProvider.notifier) : ref.read(revenueListProvider.notifier);
    final selectedBalanceDate = (balanceType == BalanceTypeEnum.expense) ? 
      ref.watch(selectedExpenseDateStateNotifierProvider).date 
      : ref.watch(selectedRevenueDateStateNotifierProvider).date;
    final appLocalizations = ref.watch(localizationStateNotifierProvider).localization;
    return FutureWidget<bool>(
      childCreation: (_) {
        return ResponsiveLayout(
          mobileChild: shortPanel(context, appLocalizations, selectedBalanceDate), 
          tabletChild: shortPanel(context, appLocalizations, selectedBalanceDate), 
          desktopChild: widePanel(context, appLocalizations, selectedBalanceDate)
        );
      },
      future: fetchData(
        balanceRepository,
        balanceListNotifier,
        selectedBalanceDate
      )
    );
  }

  Widget topContainer(
    BuildContext context, 
    AppLocalizations appLocalizations,
    SelectedDateModel selectedDate
  ) {
    String monthText = DateUtil.getMonthList(appLocalizations)[selectedDate.month-1];
    String dateText = (selectedDate.selectedDateMode == SelectedDateEnum.year) ?
      "${selectedDate.year}" : (selectedDate.selectedDateMode == SelectedDateEnum.month) ?
        "$monthText ${selectedDate.year}" : 
          "${selectedDate.day} $monthText ${selectedDate.year}";
    return Container(
      color: (balanceType == BalanceTypeEnum.expense) ? 
        const Color.fromARGB(255, 212, 112, 78)
        : const Color.fromARGB(255, 76, 122, 52),
      constraints: const BoxConstraints.expand(height: 45),
      child: Center(
        child: Text(
          dateText,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold
          )
        )
      ),
    );
  }

  Widget shortPanel(
    BuildContext context, 
    AppLocalizations appLocalizations,
    SelectedDateModel selectedDate
  ) {
    return Column(
      children: [
        topContainer(context, appLocalizations, selectedDate),
        Expanded(
          child: BalanaceRightPanel(
            balanceType: balanceType
          ),
        ), 
      ],
    );
  }

  @visibleForTesting
  Widget widePanel(
    BuildContext context, 
    AppLocalizations appLocalizations,
    SelectedDateModel selectedDate
  ) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Column(
      children: [
        topContainer(context, appLocalizations, selectedDate),
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Expanded(
                child: BalanaceLeftPanel(
                  balanceTypeEnum: balanceType
                ),
              ),
              SizedBox(
                width: (screenWidth * 0.3 > 440) ? 440 : screenWidth * 0.3,
                child: BalanaceRightPanel(
                  balanceType: balanceType
                ),
              )
            ],
          ),
        ),
      ],
    );
  }

  @visibleForTesting
  Future<bool> fetchData(
    IBalanceRepository balanceRepository,
    BalanceListStateNotifier balanceListNotifier,
    SelectedDateModel selectedDate
  ) async {
    List<BalanceModel> balances = [];
    if (
      lastDateFrom == null || lastDateTo == null
      || lastDateFrom != selectedDate.dateFrom
      || lastDateTo != selectedDate.dateTo
    ) {
      balances = await balanceRepository.getBalances(
        balanceType,
        dateFrom: selectedDate.dateFrom,
        dateTo: selectedDate.dateTo
      );
      balanceListNotifier.setBalances(balances);
      lastDateFrom = selectedDate.dateFrom;
      lastDateTo = selectedDate.dateTo;
    }
    return true;
  }
}