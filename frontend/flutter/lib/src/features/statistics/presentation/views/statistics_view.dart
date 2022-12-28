import 'package:balance_home_app/src/core/presentation/widgets/responsive_layout.dart';
import 'package:balance_home_app/src/features/statistics/presentation/views/statistics_view_desktop.dart';
import 'package:balance_home_app/src/features/statistics/presentation/views/statistics_view_mobile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class StatisticsView extends ConsumerWidget {
  /// Named route for [StatisticsView]
  static const String routeName = 'statistics';

  /// Path route for [StatisticsView]
  static const String routePath = 'statistics';

  const StatisticsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ResponsiveLayout(
      desktopChild: StatisticsViewDesktop(),
      mobileChild: StatisticsViewMobile(),
      tabletChild: StatisticsViewMobile(),
    );
  }
}
