import 'package:freezed_annotation/freezed_annotation.dart';

part 'balance_years_entity.freezed.dart';
part 'balance_years_entity.g.dart';

/// [BalanceYearsEntity] model
@freezed
class BalanceYearsEntity with _$BalanceYearsEntity {

  /// Factory constructor
  /// [years] - [List] list of years
  // ignore: invalid_annotation_target
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory BalanceYearsEntity({
    required List<int> years
  }) = _BalanceYearsEntity;

  // Serialization
  factory BalanceYearsEntity.fromJson(Map<String, dynamic> json) =>
    _$BalanceYearsEntityFromJson(json);
}