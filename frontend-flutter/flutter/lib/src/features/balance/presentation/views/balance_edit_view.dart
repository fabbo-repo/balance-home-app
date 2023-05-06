import 'package:balance_home_app/config/app_colors.dart';
import 'package:balance_home_app/config/router.dart';
import 'package:balance_home_app/config/theme.dart';
import 'package:balance_home_app/src/core/presentation/views/app_titlle.dart';
import 'package:balance_home_app/src/core/providers.dart';
import 'package:balance_home_app/src/core/utils/widget_utils.dart';
import 'package:balance_home_app/src/features/balance/domain/repositories/balance_type_mode.dart';
import 'package:balance_home_app/src/features/balance/presentation/views/balance_view.dart';
import 'package:balance_home_app/src/features/balance/presentation/widgets/balance_edit_form.dart';
import 'package:balance_home_app/src/features/balance/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class BalanceEditView extends ConsumerStatefulWidget {
  /// Route name
  static const routeName = 'balanceEdit';

  /// Route path
  static const routePath = 'edit';

  final int id;
  final BalanceTypeMode balanceTypeMode;

  const BalanceEditView(
      {required this.id, required this.balanceTypeMode, super.key});

  @override
  ConsumerState<BalanceEditView> createState() => _BalanceEditViewState();
}

class _BalanceEditViewState extends ConsumerState<BalanceEditView> {
  bool edit = false;

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeDataProvider);
    final balanceList = widget.balanceTypeMode == BalanceTypeMode.expense
        ? ref.watch(expenseListControllerProvider)
        : ref.watch(revenueListControllerProvider);
    return balanceList.when(data: (data) {
      return Scaffold(
        backgroundColor: widget.balanceTypeMode == BalanceTypeMode.expense
            ? theme == AppTheme.darkTheme
                ? AppColors.expenseBackgroundDarkColor
                : AppColors.expenseBackgroundLightColor
            : theme == AppTheme.darkTheme
                ? AppColors.revenueBackgroundDarkColor
                : AppColors.revenueBackgroundLightColor,
        appBar: AppBar(
          title: const AppTittle(fontSize: 30),
          backgroundColor: AppColors.appBarBackgroundColor,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => navigatorKey.currentContext!.goNamed(
                widget.balanceTypeMode == BalanceTypeMode.expense
                    ? BalanceView.routeExpenseName
                    : BalanceView.routeRevenueName),
          ),
          actions: [
            IconButton(
              icon: Icon(
                (!edit) ? Icons.edit : Icons.cancel_outlined,
                color: Colors.white,
              ),
              onPressed: () {
                setState(() {
                  edit = !edit;
                });
              },
            )
          ],
        ),
        body: BalanceEditForm(
            edit: edit,
            balance: data.firstWhere((element) => element.id == widget.id),
            balanceTypeMode: widget.balanceTypeMode),
      );
    }, error: (error, _) {
      return showError(error: error);
    }, loading: () {
      return showLoading();
    });
  }
}
