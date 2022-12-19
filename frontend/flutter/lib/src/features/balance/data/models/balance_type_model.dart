import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'balance_type_model.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class BalanceTypeModel extends Equatable {

  final String name;
  final String image;
  
  const BalanceTypeModel({
    required this.name,
    required this.image,
  });

  // Json Serializable
  factory BalanceTypeModel.fromJson(Map<String, dynamic> json) =>
    _$BalanceTypeModelFromJson(json);

  Map<String, dynamic> toJson() => _$BalanceTypeModelToJson(this);

  @override
  List<Object?> get props => [
    name
  ];
}
