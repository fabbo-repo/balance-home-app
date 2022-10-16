import 'package:balance_home_app/src/core/providers/package_info_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AppVersion extends ConsumerWidget {
  
  const AppVersion({super.key});

  @override
  Widget build(BuildContext context, dynamic ref) {
    final textTheme = Theme.of(context).textTheme;

    return ref(packageInfoProvider).when(
      data: (info) => Text('v${info.version}', style: textTheme.caption),
      loading: () => const CircularProgressIndicator(),
      error: (error, _) => Text(error.toString()),
    );
  }
}