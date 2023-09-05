import 'package:freezed_annotation/freezed_annotation.dart';

part 'account_entity.freezed.dart';
part 'account_entity.g.dart';

/// [AccountEntity] model
@freezed
class AccountEntity with _$AccountEntity {
  /// Factory constructor
  /// [username] - [String] username
  /// [email] - [String] email
  /// [receiveEmailBalance] - [bool] receive email balance
  /// [balance] - [double] balance
  /// [expectedAnnualBalance] - [double] expected annual balance
  /// [expectedMonthlyBalance] - [double] expected monthly balance
  /// [language] - [double] language
  /// [prefCoinType] - [double] preferred coin type
  /// [image] - [double] profile image
  /// [lastLogin] - [DateTime] last login date
  // ignore: invalid_annotation_target
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory AccountEntity({
    required String username,
    required String email,
    required bool receiveEmailBalance,
    required double balance,
    required double expectedAnnualBalance,
    required double expectedMonthlyBalance,
    required String language,
    required String prefCoinType,
    // ignore: invalid_annotation_target
    @JsonKey(includeIfNull: false) required String? image,
    // ignore: invalid_annotation_target
    @JsonKey(includeIfNull: false) required DateTime? lastLogin,
  }) = _AccountEntity;

  // Serialization
  factory AccountEntity.fromJson(Map<String, dynamic> json) =>
      _$AccountEntityFromJson(json);
}
