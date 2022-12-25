import 'package:freezed_annotation/freezed_annotation.dart';

part 'credentials_entity.freezed.dart';
part 'credentials_entity.g.dart';

/// [CredentialsEntity] model
@freezed
class CredentialsEntity with _$CredentialsEntity {
  
  /// Factory constructor
  /// [email] - [String] email
  /// [password] - [String] password
  // ignore: invalid_annotation_target
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory CredentialsEntity({
    required String email,
    required String password
  }) = _CredentialsEntity;

  // Serialization
  factory CredentialsEntity.fromJson(Map<String, dynamic> json) =>
    _$CredentialsEntityFromJson(json);
}