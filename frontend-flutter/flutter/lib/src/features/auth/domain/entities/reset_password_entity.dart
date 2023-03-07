import 'package:freezed_annotation/freezed_annotation.dart';

part 'reset_password_entity.freezed.dart';
part 'reset_password_entity.g.dart';

/// [ResetPasswordEntity] model
@freezed
class ResetPasswordEntity with _$ResetPasswordEntity {
  
  /// Factory constructor
  /// [email] - [String] email
  /// [code] - [String] code
  /// [newPassword] - [String] new password
  // ignore: invalid_annotation_target
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory ResetPasswordEntity({
    required String email,
    required String code,
    required String newPassword
  }) = _ResetPasswordEntity;

  // Serialization
  factory ResetPasswordEntity.fromJson(Map<String, dynamic> json) =>
    _$ResetPasswordEntityFromJson(json);
}