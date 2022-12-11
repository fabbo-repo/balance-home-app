import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'monthly_balance_model.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class MonthlyBalanceModel extends Equatable {

  final double grossQuantity;
  final double expectedQuantity;
  final String coinType;
  final int year;
  final int month;
  final DateTime created;

  const MonthlyBalanceModel({
    required this.grossQuantity,
    required this.expectedQuantity,
    required this.coinType,
    required this.year,
    required this.month,
    required this.created,
  });

  // Json Serializable
  factory MonthlyBalanceModel.fromJson(Map<String, dynamic> json) =>
    _$MonthlyBalanceModelFromJson(json);

  Map<String, dynamic> toJson() => _$MonthlyBalanceModelToJson(this);

  @override
  List<Object?> get props => [
    year,
    month
  ];
}