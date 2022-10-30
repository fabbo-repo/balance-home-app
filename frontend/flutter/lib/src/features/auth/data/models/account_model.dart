import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'account_model.g.dart';

@JsonSerializable()
class AccountModel extends Equatable {

  final String username;
  final String email;
  @JsonKey(name: 'receive_email_balance')
  final bool receiveEmailBalance;
  final int balance;
  @JsonKey(name: 'expected_annual_balance')
  final int expectedAnnualBalance;
  @JsonKey(name: 'expected_monthly_balance')
  final int expectedMonthlyBalance;
  final String language;
  @JsonKey(name: 'pref_coin_type')
  final String prefCoinType;
  final String image;
  @JsonKey(name: 'last_login')
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