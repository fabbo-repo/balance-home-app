import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'forgot_password_model.g.dart';

@JsonSerializable()
class ForgotPasswordModel extends Equatable {
  
  final String email;
  final String code;
  @JsonKey(name: 'new_password')
  final String newPassword;

  const ForgotPasswordModel({
    required this.email,
    required this.code,
    required this.newPassword
  });

  // Json Serializable
  factory ForgotPasswordModel.fromJson(Map<String, dynamic> json) =>
    _$ForgotPasswordModelFromJson(json);

  Map<String, dynamic> toJson() => _$ForgotPasswordModelToJson(this);

  @override
  List<Object?> get props => [
    email,
    code,
    newPassword
  ];
}