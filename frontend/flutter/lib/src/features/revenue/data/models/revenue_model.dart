import 'package:balance_home_app/src/features/revenue/data/models/revenue_type_model.dart';
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'revenue_model.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class RevenueModel extends Equatable {

  final int id;
  final String name;
  final String description;
  final int quantity;
  final DateTime date;
  final String coinType;
  final RevenueTypeModel revType;

  const RevenueModel({
    required this.id,
    required this.name,
    required this.description,
    required this.quantity,
    required this.date,
    required this.coinType,
    required this.revType,
  });

  // Json Serializable
  factory RevenueModel.fromJson(Map<String, dynamic> json) =>
    _$RevenueModelFromJson(json);

  Map<String, dynamic> toJson() => _$RevenueModelToJson(this);

  @override
  List<Object?> get props => [
    id
  ];
}