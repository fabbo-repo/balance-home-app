import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'account_model.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class AccountModel extends Equatable {

  final String username;
  final String email;
  final bool receiveEmailBalance;
  final double balance;
  final double expectedAnnualBalance;
  final double expectedMonthlyBalance;
  final String language;
  final String prefCoinType;
  final String image;
  final DateTime? lastLogin;

  const AccountModel({
        required this.username,
        required this.email,
        required this.receiveEmailBalance,
        required this.balance,
        required this.expectedAnnualBalance,
        required this.expectedMonthlyBalance,
        required this.language,
        required this.prefCoinType,
        required this.image,
        required this.lastLogin,
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