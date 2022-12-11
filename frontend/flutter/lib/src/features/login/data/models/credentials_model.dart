import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'credentials_model.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class CredentialsModel extends Equatable {
  
  final String email;
  final String password;

  const CredentialsModel({
    required this.email,
    required this.password
  });

  // Json Serializable
  factory CredentialsModel.fromJson(Map<String, dynamic> json) =>
    _$CredentialsModelFromJson(json);

  Map<String, dynamic> toJson() => _$CredentialsModelToJson(this);

  @override
  List<Object?> get props => [
    email, 
    password
  ];
}