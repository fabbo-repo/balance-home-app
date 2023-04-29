import 'package:balance_home_app/src/core/domain/failures/bad_request_failure.dart';
import 'package:balance_home_app/src/core/domain/repositories/app_info_repository_interface.dart';
import 'package:balance_home_app/src/core/presentation/models/app_version.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AppVersionController extends StateNotifier<AsyncValue<AppVersion>> {
  final AppInfoRepositoryInterface _repository;

  AppVersionController(this._repository) : super(const AsyncValue.loading()) {
    handle();
  }

  /// Package info comparison with app version.
  @visibleForTesting
  Future<void> handle() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    final res = await _repository.getVersion();
    state = res.fold((failure) {
      if (failure is BadRequestFailure) {
        return AsyncValue.error(failure.detail, StackTrace.empty);
      }
      return const AsyncValue.error("", StackTrace.empty);
    }, (remoteVersion) {
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
      return AsyncValue.data(localVersion);
    });
  }
}
