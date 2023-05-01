import 'package:balance_home_app/src/features/currency/domain/entities/currency_conversion_entity.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'currency_conversion_list_entity.freezed.dart';
part 'currency_conversion_list_entity.g.dart';

/// [CurrencyConversionListEntity] model
@freezed
class CurrencyConversionListEntity with _$CurrencyConversionListEntity {
  /// Factory constructor
  /// [code] - [String] code
  /// [exchanges] - [List] exchanges
  // ignore: invalid_annotation_target
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory CurrencyConversionListEntity(
      {required String code,
      required List<CurrencyConversionEntity> exchanges}) = _CurrencyConversionListEntity;

  // Serialization
  factory CurrencyConversionListEntity.fromJson(Map<String, dynamic> json) =>
      _$CurrencyConversionListEntityFromJson(json);
}
