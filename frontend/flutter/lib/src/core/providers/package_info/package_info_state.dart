import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:package_info_plus/package_info_plus.dart';

part 'package_info_state.freezed.dart';

@freezed
class PackageInfoState with _$PackageInfoState {
  const factory PackageInfoState(PackageInfo? info) = _PackageInfoState;
}