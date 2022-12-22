import 'package:balance_home_app/src/features/balance/data/models/balance_type_enum.dart';
import 'package:balance_home_app/src/features/balance/data/models/balance_type_model.dart';
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'balance_model.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class BalanceModel extends Equatable {

  final int id;
  final String name;
  final String description;
  final double quantity;
  final DateTime date;
  final String coinType;
  final BalanceTypeModel balanceType;

  const BalanceModel({
    required this.id,
    required this.name,
    required this.description,
    required this.quantity,
    required this.date,
    required this.coinType,
    required this.balanceType,
  });

  // Json Serializable
  factory BalanceModel.fromJson(Map<String, dynamic> json) =>
    _$BalanceModelFromJson(json);

  Map<String, dynamic> toJson() => _$BalanceModelToJson(this);

  @override
  List<Object?> get props => [
    id
  ];
}