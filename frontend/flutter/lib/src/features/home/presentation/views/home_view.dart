import 'package:adaptive_navigation/adaptive_navigation.dart';
import 'package:balance_home_app/src/core/providers.dart';
import 'package:balance_home_app/config/platform_utils.dart';
import 'package:balance_home_app/src/features/balance/presentation/views/balance_view.dart';
import 'package:balance_home_app/src/features/home/presentation/views/home_tabs.dart';
import 'package:balance_home_app/src/features/home/presentation/widgets/app_bar.dart';
import 'package:balance_home_app/src/features/statistics/presentation/views/statistics_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class HomeView extends ConsumerWidget {
  final HomeTab selectedSection;
  final Widget child;

  HomeView(
      {required this.selectedSection,
      required this.child,
      super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appLocalizations = ref.watch(appLocalizationsProvider);
    return AdaptiveNavigationScaffold(
      appBar: const PreferredSize(
          preferredSize: Size.fromHeight(40), child: CustomAppBar()),
      resizeToAvoidBottomInset: false,
      body: SafeArea(child: child),
      selectedIndex: selectedSection.index,
      onDestinationSelected: (int index) {
        switch (HomeTab.values[index]) {
          case HomeTab.statistics:
            context.go("/${StatisticsView.routePath}");
            break;
          case HomeTab.revenues:
            context.go("/${BalanceView.routeRevenuePath}");
            break;
          case HomeTab.expenses:
            context.go("/${BalanceView.routeExpensePath}");
            break;
        }
      },
      destinations: [
        AdaptiveScaffoldDestination(
          icon: Icons.insert_chart_outlined_sharp,
          title: appLocalizations.statistics,
        ),
        AdaptiveScaffoldDestination(
          icon: Icons.trending_up,
          title: appLocalizations.revenues,
        ),
        AdaptiveScaffoldDestination(
          icon: Icons.trending_down,
          title: appLocalizations.expenses,
        ),
      ],
      navigationTypeResolver: navigationTypeResolver,
    );
  }

  NavigationType navigationTypeResolver(BuildContext context) {
    if (PlatformUtils().isLargeWindow(context) ||
        PlatformUtils().isMediumWindow(context)) {
      return NavigationType.rail;
    } else {
      return NavigationType.bottom;
    }
  }
}
