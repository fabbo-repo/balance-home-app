import 'package:adaptive_navigation/adaptive_navigation.dart';
import 'package:balance_home_app/src/core/providers/localization_provider.dart';
import 'package:balance_home_app/src/core/services/platform_service.dart';
import 'package:balance_home_app/src/features/home/presentation/views/home_tabs.dart';
import 'package:balance_home_app/src/features/home/presentation/widgets/app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class HomeView extends ConsumerWidget {
  final HomeTab selectedSection;
  final Widget child;
  final PlatformService platformService;
  
  HomeView({
    required this.selectedSection,
    required this.child,
    PlatformService? platformService,
    super.key
  }) : platformService = platformService ?? PlatformService();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appLocalizations = ref.watch(localizationStateNotifierProvider).localization;
    return AdaptiveNavigationScaffold(
      appBar: PreferredSize(
          preferredSize: const Size.fromHeight(40), 
          child: CustomAppBar()),
      resizeToAvoidBottomInset: false,
      body: SafeArea(child: child),
      selectedIndex: selectedSection.index,
      onDestinationSelected: (int index) {
        switch (HomeTab.values[index]) {
          case HomeTab.statistics:
            context.go("/statistics");
            break;
          case HomeTab.revenues:
            context.go("/revenues");
            break;
          case HomeTab.expenses:
            context.go("/expenses");
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
    if (platformService.isLargeScreen(context) || platformService.isMediumScreen(context)) {
      return NavigationType.rail;
    } else {
      return NavigationType.bottom;
    }
  }
}