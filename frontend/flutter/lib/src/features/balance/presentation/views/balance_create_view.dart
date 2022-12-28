import 'package:balance_home_app/config/app_colors.dart';
import 'package:balance_home_app/src/core/presentation/views/app_titlle.dart';
import 'package:balance_home_app/src/features/balance/domain/repositories/balance_type_mode.dart';
import 'package:balance_home_app/src/features/balance/presentation/widgets/balance_create_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BalanceCreateView extends ConsumerWidget {
  /// Route name
  static const routeName = 'balanceCreate';

  /// Route path
  static const routePath = 'create';

  final BalanceTypeMode balanceTypeMode;

  const BalanceCreateView({required this.balanceTypeMode, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: balanceTypeMode == BalanceTypeMode.expense
          ? AppColors.expenseBackgroundColor
          : AppColors.revenueBackgroundColor,
      appBar: AppBar(
        title: const AppTittle(fontSize: 30),
        backgroundColor: AppColors.appBarBackgroundColor,
      ),
      body: SingleChildScrollView(
          child: BalanceCreateForm(balanceTypeMode: balanceTypeMode)),
    );
  }
}
