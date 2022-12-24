import 'package:freezed_annotation/freezed_annotation.dart';

part 'monthly_balance_entity.freezed.dart';
part 'monthly_balance_entity.g.dart';

/// [MonthlyBalanceEntity] model
@freezed
class MonthlyBalanceEntity with _$MonthlyBalanceEntity {

  /// Factory constructor
  /// [grossQuantity] - [MonthlyBalanceEntity] gross quantity
  /// [expectedQuantity] - [MonthlyBalanceEntity] expected quantity
  /// [coinType] - [MonthlyBalanceEntity] coin type code
  /// [year] - [MonthlyBalanceEntity] year
  /// [month] - [MonthlyBalanceEntity] month
  /// [created] - [MonthlyBalanceEntity] created
  // ignore: invalid_annotation_target
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory MonthlyBalanceEntity({
    required double grossQuantity,
    required double expectedQuantity,
    required String coinType,
    required int year,
    required int month,
    required DateTime created,
  }) = _MonthlyBalanceEntity;

  // Serialization
  factory MonthlyBalanceEntity.fromJson(Map<String, dynamic> json) =>
    _$MonthlyBalanceEntityFromJson(json);
}