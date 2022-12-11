import 'package:balance_home_app/src/features/coin/data/models/exchange_model.dart';
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'exchanges_list_model.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class ExchangesListModel extends Equatable {

  final String code;
  final List<ExchangeModel> exchanges;

  const ExchangesListModel({
      required this.code,
      required this.exchanges
  });

  // Json Serializable
  factory ExchangesListModel.fromJson(Map<String, dynamic> json) =>
    _$ExchangesListModelFromJson(json);

  Map<String, dynamic> toJson() => _$ExchangesListModelToJson(this);

  @override
  List<Object?> get props => [code, exchanges];
}