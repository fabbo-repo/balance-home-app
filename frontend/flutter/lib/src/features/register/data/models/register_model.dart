import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'register_model.g.dart';

@JsonSerializable()
class RegisterModel extends Equatable {

  final String username;
  final String email;
  final String language;
  final String invCode;
  final String prefCoinType;
  final String password;
  final String password2;

  const RegisterModel({
    required this.username,
    required this.email,
    required this.language,
    required this.invCode,
    required this.prefCoinType,
    required this.password,
    required this.password2,
  });

  // Json Serializable
  factory RegisterModel.fromJson(Map<String, dynamic> json) =>
    _$RegisterModelFromJson(json);

  Map<String, dynamic> toJson() => _$RegisterModelToJson(this);

  @override
  List<Object?> get props => [
    username,
    email
  ];
}