import 'package:freezed_annotation/freezed_annotation.dart';

part 'annual_balance_entity.freezed.dart';
part 'annual_balance_entity.g.dart';

/// [AnnualBalanceEntity] model
@freezed
class AnnualBalanceEntity with _$AnnualBalanceEntity {

  /// Factory constructor
  /// [grossQuantity] - [double] gross quantity
  /// [expectedQuantity] - [double] expected quantity
  /// [coinType] - [String] coin type code
  /// [year] - [int] year
  /// [created] - [DateTime] created
  // ignore: invalid_annotation_target
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory AnnualBalanceEntity({
    required double grossQuantity,
    required double expectedQuantity,
    required String coinType,
    required int year,
    required DateTime created,
  }) = _AnnualBalanceEntity;

  // Serialization
  factory AnnualBalanceEntity.fromJson(Map<String, dynamic> json) =>
    _$AnnualBalanceEntityFromJson(json);
}