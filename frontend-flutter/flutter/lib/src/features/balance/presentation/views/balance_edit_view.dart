import 'package:balance_home_app/config/app_colors.dart';
import 'package:balance_home_app/src/core/clients/api_client.dart';
import 'package:balance_home_app/src/core/router.dart';
import 'package:balance_home_app/config/app_theme.dart';
import 'package:balance_home_app/src/core/domain/failures/http_connection_failure.dart';
import 'package:balance_home_app/src/core/domain/failures/no_local_entity_failure.dart';
import 'package:balance_home_app/src/core/presentation/views/app_title.dart';
import 'package:balance_home_app/src/core/providers.dart';
import 'package:balance_home_app/src/core/utils/widget_utils.dart';
import 'package:balance_home_app/src/features/balance/domain/repositories/balance_type_mode.dart';
import 'package:balance_home_app/src/features/balance/presentation/views/balance_view.dart';
import 'package:balance_home_app/src/features/balance/presentation/widgets/balance_edit_form.dart';
import 'package:balance_home_app/src/features/balance/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
    final isConnected = connectionStateListenable.value;
    final appLocalizations = ref.read(appLocalizationsProvider);
    final theme = ref.watch(themeDataProvider);
    final balanceList = widget.balanceTypeMode == BalanceTypeMode.expense
        ? ref.watch(expenseListControllerProvider)
        : ref.watch(revenueListControllerProvider);
    return balanceList.when(data: (data) {
      return data.fold((failure) {
        if (failure is HttpConnectionFailure ||
            failure is NoLocalEntityFailure) {
          return showError(
              icon: Icons.network_wifi_1_bar,
              text: appLocalizations.noConnection);
        }
        return showError(text: failure.detail);
      }, (entities) {
        return Scaffold(
          backgroundColor: widget.balanceTypeMode == BalanceTypeMode.expense
              ? theme == AppTheme.darkTheme
                  ? AppColors.expenseBackgroundDarkColor
                  : AppColors.expenseBackgroundLightColor
              : theme == AppTheme.darkTheme
                  ? AppColors.revenueBackgroundDarkColor
                  : AppColors.revenueBackgroundLightColor,
          appBar: AppBar(
            title: const AppTitle(fontSize: 30),
            backgroundColor: AppColors.appBarBackgroundColor,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => router.goNamed(
                  widget.balanceTypeMode == BalanceTypeMode.expense
                      ? BalanceView.routeExpenseName
                      : BalanceView.routeRevenueName),
            ),
            actions: [
              if (isConnected)
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
              balance:
                  entities.firstWhere((element) => element.id == widget.id),
              balanceTypeMode: widget.balanceTypeMode),
        );
      });
    }, error: (error, _) {
      return Scaffold(
          body: showError(error: error, text: appLocalizations.genericError));
    }, loading: () {
      return Scaffold(body: showLoading());
    });
  }
}
