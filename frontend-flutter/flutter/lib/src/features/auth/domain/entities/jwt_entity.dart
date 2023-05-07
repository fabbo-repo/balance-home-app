import 'package:freezed_annotation/freezed_annotation.dart';

part 'jwt_entity.freezed.dart';
part 'jwt_entity.g.dart';

/// [JwtEntity] model
@freezed
class JwtEntity with _$JwtEntity {

  /// Factory constructor
  /// [access] - [String] access token
  /// [refresh] - [String] refresh token
  // ignore: invalid_annotation_target
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory JwtEntity({
    // ignore: invalid_annotation_target
    @JsonKey(includeIfNull: false) 
    required String? access,
    // ignore: invalid_annotation_target
    @JsonKey(includeIfNull: false) 
    required String? refresh
  }) = _JwtEntity;

  // Serialization
  factory JwtEntity.fromJson(Map<String, dynamic> json) =>
    _$JwtEntityFromJson(json);
}