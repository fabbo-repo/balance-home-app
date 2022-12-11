import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'exchange_model.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class ExchangeModel extends Equatable {

  final String code;
  final double value;

  const ExchangeModel({
      required this.code,
      required this.value
  });

  // Json Serializable
  factory ExchangeModel.fromJson(Map<String, dynamic> json) =>
    _$ExchangeModelFromJson(json);

  Map<String, dynamic> toJson() => _$ExchangeModelToJson(this);

  @override
  List<Object?> get props => [code, value];
}