import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_entity.freezed.dart';
part 'user_entity.g.dart';

/// [UserEntity] model
@freezed
class UserEntity with _$UserEntity {

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
  const factory UserEntity({
        required String username,
        required String email,
        required bool receiveEmailBalance,
        required double balance,
        required double expectedAnnualBalance,
        required double expectedMonthlyBalance,
        required String language,
        required String prefCoinType,
        required String image,
        required DateTime? lastLogin,
  }) = _UserEntity;

  // Serialization
  factory UserEntity.fromJson(Map<String, dynamic> json) =>
    _$UserEntityFromJson(json);
}