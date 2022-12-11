import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'annual_balance_model.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class AnnualBalanceModel extends Equatable {

  final double grossQuantity;
  final double expectedQuantity;
  final String coinType;
  final int year;
  final DateTime created;

  const AnnualBalanceModel({
    required this.grossQuantity,
    required this.expectedQuantity,
    required this.coinType,
    required this.year,
    required this.created,
  });

  // Json Serializable
  factory AnnualBalanceModel.fromJson(Map<String, dynamic> json) =>
    _$AnnualBalanceModelFromJson(json);

  Map<String, dynamic> toJson() => _$AnnualBalanceModelToJson(this);

  @override
  List<Object?> get props => [
    year
  ];
}