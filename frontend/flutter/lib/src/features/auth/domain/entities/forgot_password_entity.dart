import 'package:freezed_annotation/freezed_annotation.dart';

part 'forgot_password_entity.freezed.dart';
part 'forgot_password_entity.g.dart';

/// [ForgotPasswordEntity] model
@freezed
class ForgotPasswordEntity with _$ForgotPasswordEntity {
  
  /// Factory constructor
  /// [email] - [String] email
  /// [code] - [String] code
  /// [newPassword] - [String] new password
  // ignore: invalid_annotation_target
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory ForgotPasswordEntity({
    required String email,
    required String code,
    required String newPassword
  }) = _ForgotPasswordEntity;

  // Serialization
  factory ForgotPasswordEntity.fromJson(Map<String, dynamic> json) =>
    _$ForgotPasswordEntityFromJson(json);
}