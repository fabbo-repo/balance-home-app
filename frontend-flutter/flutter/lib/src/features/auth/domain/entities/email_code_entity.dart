
import 'package:freezed_annotation/freezed_annotation.dart';

part 'email_code_entity.freezed.dart';
part 'email_code_entity.g.dart';

/// [EmailCodeEntity] model
@freezed
class EmailCodeEntity with _$EmailCodeEntity {
  
  /// Factory constructor
  /// [email] - [String] email
  /// [code] - [String] code
  // ignore: invalid_annotation_target
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory EmailCodeEntity({
    required String email,
    required String code
  }) = _EmailCodeEntity;

  // Serialization
  factory EmailCodeEntity.fromJson(Map<String, dynamic> json) =>
    _$EmailCodeEntityFromJson(json);
}