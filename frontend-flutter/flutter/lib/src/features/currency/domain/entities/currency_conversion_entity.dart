import 'package:freezed_annotation/freezed_annotation.dart';

part 'currency_conversion_entity.freezed.dart';
part 'currency_conversion_entity.g.dart';

/// [CurrencyConversionEntity] model
@freezed
class CurrencyConversionEntity with _$CurrencyConversionEntity {
  /// Factory constructor
  /// [code] - [String] code
  /// [value] - [double] value
  // ignore: invalid_annotation_target
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory CurrencyConversionEntity({required String code, required double value}) =
      _CurrencyConversionEntity;

  // Serialization
  factory CurrencyConversionEntity.fromJson(Map<String, dynamic> json) =>
      _$CurrencyConversionEntityFromJson(json);
}
