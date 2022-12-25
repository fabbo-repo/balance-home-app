import 'package:freezed_annotation/freezed_annotation.dart';

part 'exchange_entity.freezed.dart';
part 'exchange_entity.g.dart';

/// [ExchangeEntity] model
@freezed
class ExchangeEntity with _$ExchangeEntity {
  /// Factory constructor
  /// [code] - [String] code
  /// [value] - [double] value
  // ignore: invalid_annotation_target
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory ExchangeEntity({required String code, required double value}) =
      _ExchangeEntity;

  // Serialization
  factory ExchangeEntity.fromJson(Map<String, dynamic> json) =>
      _$ExchangeEntityFromJson(json);
}
