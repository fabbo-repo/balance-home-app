import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:package_info_plus/package_info_plus.dart';

part 'app_version.freezed.dart';

/// App version class.
///
/// Version is formatted as 3 numbers: `x.y.z`
@freezed
class AppVersion with _$AppVersion {
  const factory AppVersion(
      {required int x,
      required int y,
      required int z,
      bool? isLower}) = _AppVersion;

  factory AppVersion.fromPackageInfo(PackageInfo packageInfo) {
    List<String> version = packageInfo.version.split(".");
    return AppVersion(
        x: int.parse(version[0]),
        y: int.parse(version[1]),
        z: int.parse(version[2]));
  }
}
