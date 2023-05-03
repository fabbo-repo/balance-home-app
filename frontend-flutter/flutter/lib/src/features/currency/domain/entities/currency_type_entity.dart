import 'package:freezed_annotation/freezed_annotation.dart';

part 'currency_type_entity.freezed.dart';
part 'currency_type_entity.g.dart';

/// [CurrencyTypeEntity] model
@freezed
class CurrencyTypeEntity with _$CurrencyTypeEntity {
  /// Factory constructor
  /// [code] - [String] code
  // ignore: invalid_annotation_target
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory CurrencyTypeEntity({required String code}) =
      _CurrencyTypeEntity;

  // Serialization
  factory CurrencyTypeEntity.fromJson(Map<String, dynamic> json) =>
      _$CurrencyTypeEntityFromJson(json);
}
