import 'package:balance_home_app/src/core/widgets/responsive_layout.dart';
import 'package:balance_home_app/src/features/statistics/presentation/views/statistics_view_desktop.dart';
import 'package:balance_home_app/src/features/statistics/presentation/views/statistics_view_mobile.dart';
import 'package:flutter/material.dart';

class StatisticsView extends StatelessWidget {
  const StatisticsView({super.key});

  @override
  Widget build(BuildContext context) {
    return const SingleChildScrollView(
      child: ResponsiveLayout(
        desktopChild: StatisticsViewDesktop(),
        mobileChild: StatisticsViewMobile(),
        tabletChild: StatisticsViewMobile(),
      )
    );
  }

  BoxDecoration borderDecoration() {
    return BoxDecoration(
      border: Border.all(),
    );
  }
}