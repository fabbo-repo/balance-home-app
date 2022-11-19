import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'revenue_type_model.g.dart';

@JsonSerializable()
class RevenueTypeModel extends Equatable {

  final String name;
  final String image;
  
  const RevenueTypeModel({
    required this.name,
    required this.image,
  });

  // Json Serializable
  factory RevenueTypeModel.fromJson(Map<String, dynamic> json) =>
    _$RevenueTypeModelFromJson(json);

  Map<String, dynamic> toJson() => _$RevenueTypeModelToJson(this);

  @override
  List<Object?> get props => [
    name
  ];
}
