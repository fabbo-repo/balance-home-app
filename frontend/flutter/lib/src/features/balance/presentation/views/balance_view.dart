import 'package:balance_home_app/src/core/presentation/models/selected_date.dart';
import 'package:balance_home_app/src/core/presentation/models/selected_date_mode.dart';
import 'package:balance_home_app/src/core/presentation/views/error_view.dart';
import 'package:balance_home_app/src/core/presentation/widgets/loading_widget.dart';
import 'package:balance_home_app/src/core/presentation/widgets/responsive_layout.dart';
import 'package:balance_home_app/src/core/providers.dart';
import 'package:balance_home_app/src/core/utils/date_util.dart';
import 'package:balance_home_app/src/features/balance/domain/entities/balance_entity.dart';
import 'package:balance_home_app/src/features/balance/domain/repositories/balance_type_mode.dart';
import 'package:balance_home_app/src/features/balance/presentation/widgets/balance_left_panel.dart';
import 'package:balance_home_app/src/features/balance/presentation/widgets/balance_right_panel.dart';
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

  final BalanceTypeMode balanceTypeMode;

  const BalanceView({required this.balanceTypeMode, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final balanceListController = balanceTypeMode == BalanceTypeMode.expense
        ? ref.watch(expenseListControllerProvider)
        : ref.watch(revenueListControllerProvider);
    final selectedDate = balanceTypeMode == BalanceTypeMode.expense
        ? ref.watch(expenseSelectedDateProvider)
        : ref.watch(revenueSelectedDateProvider);
    final appLocalizations = ref.watch(appLocalizationsProvider);
    return balanceListController.when<Widget>(
        data: (List<BalanceEntity> balances) {
      return ResponsiveLayout(
          mobileChild: shortPanel(context, appLocalizations, selectedDate, balances),
          tabletChild: shortPanel(context, appLocalizations, selectedDate, balances),
          desktopChild:
              widePanel(context, appLocalizations, selectedDate, balances));
    }, error: (Object o, StackTrace st) {
      debugPrint("[BALANCE_VIEW] $o -> $st");
      ErrorView.go();
      return const LoadingWidget(color: Colors.red);
    }, loading: () {
      return const LoadingWidget(color: Colors.grey);
    });
  }

  Widget topContainer(BuildContext context, AppLocalizations appLocalizations,
      SelectedDate selectedDate) {
    String monthText =
        DateUtil.getMonthList(appLocalizations)[selectedDate.month - 1];
    String dateText = (selectedDate.selectedDateMode == SelectedDateMode.year)
        ? "${selectedDate.year}"
        : (selectedDate.selectedDateMode == SelectedDateMode.month)
            ? "$monthText ${selectedDate.year}"
            : "${selectedDate.day} $monthText ${selectedDate.year}";
    return Container(
      color: balanceTypeMode == BalanceTypeMode.expense
          ? const Color.fromARGB(255, 212, 112, 78)
          : const Color.fromARGB(255, 76, 122, 52),
      constraints: const BoxConstraints.expand(height: 45),
      child: Center(
          child: Text(dateText,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold))),
    );
  }

  Widget shortPanel(BuildContext context, AppLocalizations appLocalizations,
      SelectedDate selectedDate, List<BalanceEntity> balances) {
    return Column(
      children: [
        topContainer(context, appLocalizations, selectedDate),
        Expanded(
          child: BalanaceRightPanel(balances: balances, balanceTypeMode: balanceTypeMode),
        ),
      ],
    );
  }

  @visibleForTesting
  Widget widePanel(BuildContext context, AppLocalizations appLocalizations,
      SelectedDate selectedDate, List<BalanceEntity> balances) {
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
                    balances: balances, balanceTypeMode: balanceTypeMode),
              ),
              SizedBox(
                width: (screenWidth * 0.3 > 440) ? 440 : screenWidth * 0.3,
                child: BalanaceRightPanel(balances: balances, balanceTypeMode: balanceTypeMode),
              )
            ],
          ),
        ),
      ],
    );
  }
}
