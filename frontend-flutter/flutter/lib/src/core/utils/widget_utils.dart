import 'package:balance_home_app/config/app_layout.dart';
import 'package:balance_home_app/src/core/presentation/widgets/app_error_widget.dart';
import 'package:balance_home_app/src/core/presentation/widgets/app_loading_widget.dart';
import 'package:flutter/material.dart';

Widget showLoading(
    {Widget? background,
    AlignmentGeometry alignment = AlignmentDirectional.centerStart}) {
  return Stack(alignment: alignment, children: [
    IgnorePointer(child: background),
    const AppLoadingWidget(color: Colors.grey),
  ]);
}

Widget showError(
    {Object? error, Widget? background, String? text, IconData? icon}) {
  if (error != null) debugPrint("[ERROR] $error");
  return Stack(alignment: AlignmentDirectional.centerStart, children: [
    IgnorePointer(child: background),
    AppErrorWidget(text: text, icon: icon),
  ]);
}

Widget verticalSpace() {
  return const SizedBox(
    height: AppLayout.genericPadding,
  );
}

Widget horizontalSpace() {
  return const SizedBox(
    width: AppLayout.genericPadding,
  );
}
