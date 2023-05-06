import 'package:balance_home_app/config/router.dart';
import 'package:balance_home_app/src/core/presentation/models/selected_date.dart';
import 'package:balance_home_app/src/core/presentation/models/selected_date_mode.dart';
import 'package:balance_home_app/src/core/presentation/states/selected_date_state.dart';
import 'package:balance_home_app/src/core/presentation/widgets/app_text_button.dart';
import 'package:balance_home_app/src/core/presentation/widgets/error_dialog.dart';
import 'package:balance_home_app/src/core/presentation/widgets/responsive_layout.dart';
import 'package:balance_home_app/src/core/providers.dart';
import 'package:balance_home_app/src/core/utils/date_util.dart';
import 'package:balance_home_app/src/core/utils/widget_utils.dart';
import 'package:balance_home_app/src/features/balance/domain/entities/balance_entity.dart';
import 'package:balance_home_app/src/features/balance/domain/repositories/balance_type_mode.dart';
import 'package:balance_home_app/src/features/balance/presentation/widgets/balance_left_panel.dart';
import 'package:balance_home_app/src/features/balance/presentation/widgets/balance_right_panel.dart';
import 'package:balance_home_app/src/features/balance/presentation/widgets/date_balance_dialog.dart';
import 'package:balance_home_app/src/features/balance/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class BalanceView extends ConsumerWidget {
  /// Named route for revenues [BalanceView]
  static const String routeRevenueName = 'revenues';

  /// Path route for revenues [BalanceView]
  static const String routeRevenuePath = 'revenues';

  /// Named route for expenses [BalanceView]
  static const String routeExpenseName = 'expenses';

  /// Path route for expenses [BalanceView]
  static const String routeExpensePath = 'expenses';

  @visibleForTesting
  final cache = ValueNotifier<Widget>(Container());

  @visibleForTesting
  final BalanceTypeMode balanceTypeMode;

  BalanceView({required this.balanceTypeMode, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final balanceList = balanceTypeMode == BalanceTypeMode.expense
        ? ref.watch(expenseListControllerProvider)
        : ref.watch(revenueListControllerProvider);
    final balanceListController = balanceTypeMode == BalanceTypeMode.expense
        ? ref.watch(expenseListControllerProvider.notifier)
        : ref.watch(revenueListControllerProvider.notifier);
    final selectedDate = balanceTypeMode == BalanceTypeMode.expense
        ? ref.watch(expenseSelectedDateProvider)
        : ref.watch(revenueSelectedDateProvider);
    final appLocalizations = ref.watch(appLocalizationsProvider);
    final selectedDateState = balanceTypeMode == BalanceTypeMode.expense
        ? ref.watch(expenseSelectedDateProvider.notifier)
        : ref.watch(revenueSelectedDateProvider.notifier);
    return balanceList.when<Widget>(data: (List<BalanceEntity> balances) {
      final balanceYears = balanceListController.getAllBalanceYears();
      List<BalanceEntity> filteredBalances = [];
      for (BalanceEntity e in balances) {
        if (selectedDate.year != e.date.year) continue;
        if (selectedDate.selectedDateMode == SelectedDateMode.month ||
            selectedDate.selectedDateMode == SelectedDateMode.day) {
          if (selectedDate.month != e.date.month) continue;
          if (selectedDate.selectedDateMode == SelectedDateMode.day) {
            if (selectedDate.day != e.date.day) continue;
          }
        }
        filteredBalances.add(e);
      }
      cache.value = ResponsiveLayout(
          mobileChild: shortPanel(context, appLocalizations, selectedDateState,
              selectedDate, filteredBalances, balanceYears),
          tabletChild: shortPanel(context, appLocalizations, selectedDateState,
              selectedDate, filteredBalances, balanceYears),
          desktopChild: widePanel(context, appLocalizations, selectedDateState,
              selectedDate, filteredBalances, balanceYears));
      return cache.value;
    }, error: (error, _) {
      return showError(error: error, background: cache.value);
    }, loading: () {
      return showLoading(background: cache.value);
    });
  }

  Widget topContainer(
      BuildContext context,
      AppLocalizations appLocalizations,
      SelectedDateState selectedDateState,
      SelectedDate selectedDate,
      Future<List<int>> balanceYears) {
    String monthText =
        DateUtil.getMonthList(appLocalizations)[selectedDate.month - 1];
    String dateText = (selectedDate.selectedDateMode == SelectedDateMode.year)
        ? "${selectedDate.year}"
        : (selectedDate.selectedDateMode == SelectedDateMode.month)
            ? "$monthText ${selectedDate.year}"
            : "${selectedDate.day} $monthText ${selectedDate.year}";
    double screenWidth = MediaQuery.of(context).size.width;
    Widget topContainer = Container(
      color: balanceTypeMode == BalanceTypeMode.expense
          ? const Color.fromARGB(255, 212, 112, 78)
          : const Color.fromARGB(255, 76, 122, 52),
      constraints: BoxConstraints.tightFor(
          height: 45,
          width: screenWidth < 550
              ? screenWidth
              : screenWidth < 1024
                  ? screenWidth - 100
                  : screenWidth - 173),
      child: Center(
          child: Text(dateText,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold))),
    );
    Widget dateBtn = AppTextButton(
      text: appLocalizations.date,
      backgroundColor: balanceTypeMode == BalanceTypeMode.expense
          ? const Color.fromARGB(255, 160, 71, 41)
          : const Color.fromARGB(255, 54, 90, 35),
      onPressed: () async {
        await showDateBalanceDialog(
            appLocalizations, selectedDateState, selectedDate, balanceYears);
      },
      height: 45,
      width: screenWidth < 550 ? screenWidth : 100,
    );
    return ResponsiveLayout(
        mobileChild: Column(children: [dateBtn, topContainer]),
        tabletChild: Row(children: [dateBtn, topContainer]),
        desktopChild: Row(children: [dateBtn, topContainer]));
  }

  Future<void> showDateBalanceDialog(
      AppLocalizations appLocalizations,
      SelectedDateState selectedDateState,
      SelectedDate selectedDate,
      Future<List<int>> balanceYears) async {
    final years = await balanceYears;
    if (years.isEmpty) {
      await showDialog(
          context: navigatorKey.currentContext!,
          builder: (context) => ErrorDialog(
                dialogTitle: appLocalizations.resetPassword,
                dialogDescription: appLocalizations.genericError,
                cancelText: appLocalizations.cancel,
              ));
    } else {
      await showDialog(
          context: navigatorKey.currentContext!,
          builder: (context) => DateBalanceDialog(
                selectedDate: selectedDate,
                onPressed: (SelectedDate newDate) {
                  // Pop current dialog
                  Navigator.pop(context);
                  selectedDateState.setSelectedDate(newDate);
                },
                years: years,
              ));
    }
  }

  Widget shortPanel(
      BuildContext context,
      AppLocalizations appLocalizations,
      SelectedDateState selectedDateState,
      SelectedDate selectedDate,
      List<BalanceEntity> balances,
      Future<List<int>> balanceYears) {
    return Column(
      children: [
        topContainer(context, appLocalizations, selectedDateState, selectedDate,
            balanceYears),
        Expanded(
          child: BalanaceRightPanel(
              balances: balances, balanceTypeMode: balanceTypeMode),
        ),
      ],
    );
  }

  @visibleForTesting
  Widget widePanel(
      BuildContext context,
      AppLocalizations appLocalizations,
      SelectedDateState selectedDateState,
      SelectedDate selectedDate,
      List<BalanceEntity> balances,
      Future<List<int>> balanceYears) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Column(
      children: [
        topContainer(context, appLocalizations, selectedDateState, selectedDate,
            balanceYears),
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Expanded(
                child: BalanaceLeftPanel(
                    balances: balances, balanceTypeMode: balanceTypeMode),
              ),
              SizedBox(
                width: (screenWidth * 0.3 > 440) ? 440 : screenWidth * 0.3,
                child: BalanaceRightPanel(
                    balances: balances, balanceTypeMode: balanceTypeMode),
              )
            ],
          ),
        ),
      ],
    );
  }
}
