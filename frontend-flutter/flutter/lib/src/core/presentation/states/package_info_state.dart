import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';

class PackageInfoState extends StateNotifier<AsyncValue<PackageInfo?>> {
  PackageInfoState()
      : super(const AsyncValue.data(null));

  Future<void> get() async {
    state = const AsyncLoading();
    state = AsyncValue.data(await PackageInfo.fromPlatform());
  }
}