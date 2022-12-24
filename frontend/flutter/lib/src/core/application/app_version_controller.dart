import 'package:balance_home_app/src/core/domain/repositories/app_info_repository_interface.dart';
import 'package:balance_home_app/src/core/presentation/models/app_version.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AppVersionController extends StateNotifier<AsyncValue<AppVersion>> {
  final AppInfoRepositoryInterface _repository;

  AppVersionController(this._repository) : super(const AsyncValue.loading());

  /// Package info comparison with app version.
  Future<void> handle() async {
    AppVersion remoteVersion = await _repository.getVersion();
    state = const AsyncValue.loading();
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    AppVersion localVersion = AppVersion.fromPackageInfo(packageInfo);
    if (localVersion.x != remoteVersion.x) {
      localVersion =
          localVersion.copyWith(isLower: localVersion.x < remoteVersion.x);
    } else if (localVersion.y != remoteVersion.y) {
      localVersion =
          localVersion.copyWith(isLower: localVersion.y < remoteVersion.y);
    } else if (localVersion.z != remoteVersion.z) {
      localVersion =
          localVersion.copyWith(isLower: localVersion.z < remoteVersion.z);
    } else {
      localVersion = localVersion.copyWith(isLower: false);
    }
    state = AsyncValue.data(localVersion);
  }
}
