import 'package:balance_home_app/src/features/coin/data/models/exchanges_list_model.dart';
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'date_exchange_model.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class DateExchangeModel extends Equatable {

  final List<ExchangesListModel> exchanges;
  final DateTime date;

  const DateExchangeModel({
      required this.exchanges,
      required this.date
  });

  // Json Serializable
  factory DateExchangeModel.fromJson(Map<String, dynamic> json) =>
    _$DateExchangeModelFromJson(json);

  Map<String, dynamic> toJson() => _$DateExchangeModelToJson(this);

  @override
  List<Object?> get props => [date, exchanges];
}