import 'package:freezed_annotation/freezed_annotation.dart';

part 'coin_type_entity.freezed.dart';
part 'coin_type_entity.g.dart';

/// [CoinTypeEntity] model
@freezed
class CoinTypeEntity with _$CoinTypeEntity {
  /// Factory constructor
  /// [code] - [CoinTypeEntity] code
  // ignore: invalid_annotation_target
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory CoinTypeEntity({required String code}) = _CoinTypeEntity;

  // Serialization
  factory CoinTypeEntity.fromJson(Map<String, dynamic> json) =>
      _$CoinTypeEntityFromJson(json);
}
