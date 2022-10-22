import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'account_model.g.dart';

@JsonSerializable()
class AccountModel extends Equatable {
  
  final String username;
  final String email;
  final String imageUrl;

  AccountModel({
    required this.username,
    required this.email,
    required this.imageUrl
  });

  // Json Serializable
  factory AccountModel.fromJson(Map<String, dynamic> json) =>
    _$AccountModelFromJson(json);

  Map<String, dynamic> toJson() => _$AccountModelToJson(this);

  @override
  List<Object?> get props => [
    username, 
    email
  ];
}