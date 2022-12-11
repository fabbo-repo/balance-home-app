import 'package:balance_home_app/src/features/coin/data/models/date_exchange_model.dart';
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'date_exchanges_list_model.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class DateExchangesListModel extends Equatable {

  final List<DateExchangeModel> dateExchanges;

  const DateExchangesListModel({
      required this.dateExchanges
  });

  // Json Serializable
  factory DateExchangesListModel.fromJson(Map<String, dynamic> json) =>
    _$DateExchangesListModelFromJson(json);

  Map<String, dynamic> toJson() => _$DateExchangesListModelToJson(this);

  @override
  List<Object?> get props => [dateExchanges];
}