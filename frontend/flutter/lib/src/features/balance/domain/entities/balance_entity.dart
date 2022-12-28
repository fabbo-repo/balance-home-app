import 'package:balance_home_app/src/features/balance/domain/entities/balance_type_entity.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'balance_entity.freezed.dart';
part 'balance_entity.g.dart';

/// [BalanceEntity] model
@freezed
class BalanceEntity with _$BalanceEntity {
  const BalanceEntity._();

  /// Factory constructor
  /// [id] - [int] id
  /// [name] - [String] name
  /// [description] - [String] description
  /// [quantity] - [double] quantity
  /// [date] - [DateTime] date
  /// [coinType] - [String] coin type code
  /// [balanceType] - [BalanceTypeEntity] balance type
  // ignore: invalid_annotation_target
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory BalanceEntity({
    // ignore: invalid_annotation_target
    @JsonKey(includeIfNull: false) required int? id,
    required String name,
    required String description,
    required double quantity,
    required DateTime date,
    required String coinType,
    required BalanceTypeEntity balanceType,
  }) = _BalanceEntity;

  // Serialization
  factory BalanceEntity.fromJson(Map<String, dynamic> json) =>
      _$BalanceEntityFromJson(json);

  factory BalanceEntity.fromRevenueJson(Map<String, dynamic> json) {
    json["balance_type"] = json.remove("rev_type");
    return _$BalanceEntityFromJson(json);
  }

  factory BalanceEntity.fromExpenseJson(Map<String, dynamic> json) {
    json["balance_type"] = json.remove("exp_type");
    return _$BalanceEntityFromJson(json);
  }

  Map<String, dynamic> toRevenueJson() {
    Map<String, dynamic> map = toJson();
    map["rev_type"] = (map.remove("balance_type") as BalanceTypeEntity).name;
    return map;
  }

  Map<String, dynamic> toExpenseJson() {
    Map<String, dynamic> map = toJson();
    map["exp_type"] = (map.remove("balance_type") as BalanceTypeEntity).name;
    return map;
  }
}
