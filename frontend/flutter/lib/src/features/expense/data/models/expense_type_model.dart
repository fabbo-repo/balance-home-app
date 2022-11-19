import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'expense_type_model.g.dart';

@JsonSerializable()
class ExpenseTypeModel extends Equatable {

  final String name;
  final String image;
  
  const ExpenseTypeModel({
    required this.name,
    required this.image,
  });

  // Json Serializable
  factory ExpenseTypeModel.fromJson(Map<String, dynamic> json) =>
    _$ExpenseTypeModelFromJson(json);

  Map<String, dynamic> toJson() => _$ExpenseTypeModelToJson(this);

  @override
  List<Object?> get props => [
    name
  ];
}
