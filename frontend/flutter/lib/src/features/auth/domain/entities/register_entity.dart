import 'package:freezed_annotation/freezed_annotation.dart';

part 'register_entity.freezed.dart';
part 'register_entity.g.dart';

/// [RegisterEntity] model
@freezed
class RegisterEntity with _$RegisterEntity {
  /// Factory constructor
  /// [username] - [String] username
  /// [email] - [String] email
  /// [language] - [String] language
  /// [invCode] - [String] invitation code
  /// [prefCoinType] - [String] preferred coin type
  /// [password] - [String] password
  /// [password2] - [String] scond password
  // ignore: invalid_annotation_target
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory RegisterEntity({
    required String username,
    required String email,
    required String language,
    required String invCode,
    required String prefCoinType,
    required String password,
    required String password2,
  }) = _RegisterEntity;

  // Serialization
  factory RegisterEntity.fromJson(Map<String, dynamic> json) =>
      _$RegisterEntityFromJson(json);
}
