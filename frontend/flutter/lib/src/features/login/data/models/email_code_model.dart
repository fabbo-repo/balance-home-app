import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'email_code_model.g.dart';

@JsonSerializable()
class EmailCodeModel extends Equatable {
  
  final String email;
  final String code;

  const EmailCodeModel({
    required this.email,
    required this.code
  });

  // Json Serializable
  factory EmailCodeModel.fromJson(Map<String, dynamic> json) =>
    _$EmailCodeModelFromJson(json);

  Map<String, dynamic> toJson() => _$EmailCodeModelToJson(this);

  @override
  List<Object?> get props => [
    email, 
    code
  ];
}