import 'package:balance_home_app/src/features/expense/data/models/expense_type_model.dart';
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'expense_model.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class ExpenseModel extends Equatable {

  final int id;
  final String name;
  final String description;
  final double quantity;
  final DateTime date;
  final String coinType;
  final ExpenseTypeModel expType;

  const ExpenseModel({
    required this.id,
    required this.name,
    required this.description,
    required this.quantity,
    required this.date,
    required this.coinType,
    required this.expType,
  });

  // Json Serializable
  factory ExpenseModel.fromJson(Map<String, dynamic> json) =>
    _$ExpenseModelFromJson(json);

  Map<String, dynamic> toJson() => _$ExpenseModelToJson(this);

  @override
  List<Object?> get props => [
    id
  ];
}