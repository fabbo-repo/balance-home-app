import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'jwt_model.g.dart';

@JsonSerializable()
class JwtModel extends Equatable {
  
  final String access;
  final String refresh;

  const JwtModel({
    required this.access,
    required this.refresh
  });

  // Json Serializable
  factory JwtModel.fromJson(Map<String, dynamic> json) =>
    _$JwtModelFromJson(json);

  Map<String, dynamic> toJson() => _$JwtModelToJson(this);

  @override
  List<Object?> get props => [
    access, 
    refresh
  ];
}