import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'jwt_model.g.dart';

@JsonSerializable()
class JwtModel extends Equatable {
  
  final String accessToken;
  final String refreshToken;

  JwtModel({
    required this.accessToken,
    required this.refreshToken
  });

  // Json Serializable
  factory JwtModel.fromJson(Map<String, dynamic> json) =>
    _$JwtModelFromJson(json);

  Map<String, dynamic> toJson() => _$JwtModelToJson(this);

  @override
  List<Object?> get props => [
    accessToken, 
    refreshToken
  ];
}