import 'package:freezed_annotation/freezed_annotation.dart';

part 'balance_type_entity.freezed.dart';
part 'balance_type_entity.g.dart';

/// [BalanceTypeEntity] model
@freezed
class BalanceTypeEntity with _$BalanceTypeEntity {

  /// Factory constructor
  /// [name] - [String] name
  /// [image] - [String] image url
  // ignore: invalid_annotation_target
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory BalanceTypeEntity({
    required String name,
    required String image,
  }) = _BalanceTypeEntity;

  // Serialization
  factory BalanceTypeEntity.fromJson(Map<String, dynamic> json) =>
    _$BalanceTypeEntityFromJson(json);
}
