import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'balance_years_model.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class BalanceYearsModel extends Equatable {

  final List<int> years;

  const BalanceYearsModel({
    required this.years
  });

  // Json Serializable
  factory BalanceYearsModel.fromJson(Map<String, dynamic> json) =>
    _$BalanceYearsModelFromJson(json);

  Map<String, dynamic> toJson() => _$BalanceYearsModelToJson(this);

  @override
  List<Object?> get props => [
    years
  ];
}