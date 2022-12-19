import 'package:balance_home_app/src/core/providers/package_info/package_info_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';

class PackageInfoStateNotifier extends StateNotifier<PackageInfoState> {
  PackageInfoStateNotifier() : super(const PackageInfoState(null));
  
  void setPackageInfo(PackageInfo info) {
    state = state.copyWith(info: info);
  }

  PackageInfo? getPackageInfo() {
    return state.info;
  }
}