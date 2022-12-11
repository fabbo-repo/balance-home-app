import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'years_model.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class YearsModel extends Equatable {

  final List<int> years;

  const YearsModel({
    required this.years,
  });

  // Json Serializable
  factory YearsModel.fromJson(Map<String, dynamic> json) =>
    _$YearsModelFromJson(json);

  Map<String, dynamic> toJson() => _$YearsModelToJson(this);

  @override
  List<Object?> get props => [];
}