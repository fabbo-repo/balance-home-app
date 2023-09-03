import 'package:adaptive_navigation/adaptive_navigation.dart';
import 'package:balance_home_app/src/core/clients/api_client.dart';
import 'package:balance_home_app/src/core/providers.dart';
import 'package:balance_home_app/src/core/utils/platform_utils.dart';
import 'package:balance_home_app/src/features/balance/presentation/views/balance_view.dart';
import 'package:balance_home_app/src/features/home/presentation/views/home_tabs.dart';
import 'package:balance_home_app/src/features/home/presentation/widgets/app_bar.dart';
import 'package:balance_home_app/src/features/statistics/presentation/views/statistics_view.dart';
import 'package:balance_home_app/src/features/statistics/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:universal_io/io.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

final lastExitPressState = ValueNotifier<DateTime?>(null);

class HomeView extends ConsumerStatefulWidget {
  final HomeTab selectedSection;
  final Widget child;

  const HomeView(
      {required this.selectedSection, required this.child, super.key});

  @override
  ConsumerState<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends ConsumerState<HomeView> {
  @override
  Widget build(BuildContext context) {
    final appLocalizations = ref.watch(appLocalizationsProvider);
    final isConnected = connectionStateListenable.value;
    if (!isConnected) {
      Future.delayed(Duration.zero, () {
        showNoConnectionSnackBar(appLocalizations);
      });
    }
    return WillPopScope(
      onWillPop: () async {
        final now = DateTime.now();
        if (lastExitPressState.value != null &&
            now.difference(lastExitPressState.value!) <
                const Duration(seconds: 2)) {
          exit(0);
        } else {
          lastExitPressState.value = now;
          final snackBar = SnackBar(
              content: Text(appLocalizations.exitRepeatMessage,
                  textAlign: TextAlign.center),
              duration: const Duration(seconds: 2));
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
          return false;
        }
      },
      child: AdaptiveNavigationScaffold(
        appBar: const PreferredSize(
            preferredSize: Size.fromHeight(40), child: CustomAppBar()),
        resizeToAvoidBottomInset: false,
        body: SafeArea(child: widget.child),
        selectedIndex: widget.selectedSection.index,
        onDestinationSelected: (int index) {
          switch (HomeTab.values[index]) {
            case HomeTab.statistics:
              ref.read(statisticsControllerProvider.notifier).handle();
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
      ),
    );
  }

  @visibleForTesting
  NavigationType navigationTypeResolver(BuildContext context) {
    if (PlatformUtils.isLargeWindow(context) ||
        PlatformUtils.isMediumWindow(context)) {
      return NavigationType.rail;
    } else {
      return NavigationType.bottom;
    }
  }

  @visibleForTesting
  void showNoConnectionSnackBar(final AppLocalizations appLocalizations) {
    final snackBar = SnackBar(
        content:
            Text(appLocalizations.noConnection, textAlign: TextAlign.center),
        backgroundColor: Colors.grey,
        duration: const Duration(seconds: 3));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
