import 'package:balance_home_app/src/core/providers/localization/localization_provider.dart';
import 'package:balance_home_app/src/core/services/platform_service.dart';
import 'package:balance_home_app/src/features/balance/data/models/balance_type_enum.dart';
import 'package:balance_home_app/src/features/balance/presentation/widgets/balance_bar_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BalanaceLeftPanel extends ConsumerWidget {
  final BalanceTypeEnum balanceTypeEnum;
  
  const BalanaceLeftPanel({
    required this.balanceTypeEnum,
    super.key
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appLocalizations = ref.watch(localizationStateNotifierProvider).localization;
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    double chartLineHeight = (screenHeight * 0.45 <= 200) ? 
      200 : (screenHeight * 0.45 <= 350) ? screenHeight * 0.45 : 350;
    return Container(
      color: (balanceTypeEnum == BalanceTypeEnum.expense) ?
        const Color.fromARGB(254, 255, 236, 215) : 
        const Color.fromARGB(254, 223, 237, 214),
      child: Column(
        children: [
          SizedBox(
            height: chartLineHeight,
            width: (PlatformService().isSmallWindow(context)) ? 
              screenWidth * 0.95 : screenWidth * 0.45,
            child: BalanceBarChart(
              balances: [],
              balanceType: balanceTypeEnum
            )
          ),
        ],
      ),
    );
  }
}