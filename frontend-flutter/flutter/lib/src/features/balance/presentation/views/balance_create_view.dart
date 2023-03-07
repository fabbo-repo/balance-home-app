import 'package:balance_home_app/config/app_colors.dart';
import 'package:balance_home_app/config/router.dart';
import 'package:balance_home_app/src/core/presentation/views/app_titlle.dart';
import 'package:balance_home_app/src/core/providers.dart';
import 'package:balance_home_app/src/features/balance/domain/repositories/balance_type_mode.dart';
import 'package:balance_home_app/src/features/balance/presentation/views/balance_view.dart';
import 'package:balance_home_app/src/features/balance/presentation/widgets/balance_create_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class BalanceCreateView extends ConsumerWidget {
  /// Route name
  static const routeName = 'balanceCreate';

  /// Route path
  static const routePath = 'create';

  final BalanceTypeMode balanceTypeMode;

  const BalanceCreateView({required this.balanceTypeMode, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeModeProvider);
    return Scaffold(
      backgroundColor: balanceTypeMode == BalanceTypeMode.expense
          ? theme == ThemeMode.dark
              ? AppColors.expenseBackgroundDarkColor
              : AppColors.expenseBackgroundLightColor
          : theme == ThemeMode.dark
              ? AppColors.revenueBackgroundDarkColor
              : AppColors.revenueBackgroundLightColor,
      appBar: AppBar(
        title: const AppTittle(fontSize: 30),
        backgroundColor: AppColors.appBarBackgroundColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => navigatorKey.currentContext!.goNamed(
              balanceTypeMode == BalanceTypeMode.expense
                  ? BalanceView.routeExpenseName
                  : BalanceView.routeRevenueName),
        ),
      ),
      body: BalanceCreateForm(balanceTypeMode: balanceTypeMode),
    );
  }
}
