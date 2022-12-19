import 'package:balance_home_app/src/core/providers/package_info/package_info_state.dart';
import 'package:balance_home_app/src/core/providers/package_info/package_info_state_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// StateNotifier
final packageInfoStateNotifierProvider = StateNotifierProvider<PackageInfoStateNotifier, PackageInfoState>(
  (StateNotifierProviderRef<PackageInfoStateNotifier, PackageInfoState> ref) => 
    PackageInfoStateNotifier()
);