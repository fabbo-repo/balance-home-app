import 'package:balance_home_app/src/core/providers/package_info_state.dart';
import 'package:balance_home_app/src/core/providers/package_info_state_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';

final packageInfoProvider = FutureProvider<PackageInfo>(
  (_) async => await PackageInfo.fromPlatform(),
);

/// StateNotifier
final packageInfoStateNotifierProvider = StateNotifierProvider<PackageInfoStateNotifier, PackageInfoState>(
  (StateNotifierProviderRef<PackageInfoStateNotifier, PackageInfoState> ref) => 
    PackageInfoStateNotifier()
);