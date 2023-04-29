import 'package:balance_home_app/config/app_layout.dart';
import 'package:balance_home_app/src/core/presentation/widgets/app_error_widget.dart';
import 'package:balance_home_app/src/core/presentation/widgets/loading_widget.dart';
import 'package:flutter/material.dart';

Widget showLoading(
    {Widget? cache,
    AlignmentGeometry alignment = AlignmentDirectional.centerStart}) {
  return Stack(alignment: alignment, children: [
    if (cache != null) cache,
    const LoadingWidget(color: Colors.grey),
  ]);
}

Widget showError(Object error, StackTrace stackTrace, {Widget? cache}) {
  debugPrint("[ERROR] $error -> $stackTrace");
  return Stack(alignment: AlignmentDirectional.centerStart, children: [
    if (cache != null) cache,
    const AppErrorWidget(),
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
