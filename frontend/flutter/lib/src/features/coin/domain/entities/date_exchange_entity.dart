import 'package:balance_home_app/src/features/coin/domain/entities/exchanges_list_entity.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'date_exchange_entity.freezed.dart';
part 'date_exchange_entity.g.dart';

/// [DateExchangeEntity] model
@freezed
class DateExchangeEntity with _$DateExchangeEntity {
  /// Factory constructor
  /// [exchanges] - [List] exchanges
  /// [date] - [DateTime] date
  // ignore: invalid_annotation_target
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory DateExchangeEntity(
      {required List<ExchangesListEntity> exchanges,
      required DateTime date}) = _DateExchangeEntity;

  // Serialization
  factory DateExchangeEntity.fromJson(Map<String, dynamic> json) =>
      _$DateExchangeEntityFromJson(json);
}
