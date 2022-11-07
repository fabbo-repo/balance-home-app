import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'coin_type_model.g.dart';

@JsonSerializable()
class CoinTypeModel extends Equatable {

  final String code;

  const CoinTypeModel({
      required this.code
  });

  // Json Serializable
  factory CoinTypeModel.fromJson(Map<String, dynamic> json) =>
    _$CoinTypeModelFromJson(json);

  Map<String, dynamic> toJson() => _$CoinTypeModelToJson(this);

  @override
  List<Object?> get props => [code];
}