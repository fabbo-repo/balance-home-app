import 'package:freezed_annotation/freezed_annotation.dart';

part 'min_max.freezed.dart';

@freezed
class MinMax with _$MinMax {

  const factory MinMax({
    required double min,
    required double max,
  }) = _MinMax;
}