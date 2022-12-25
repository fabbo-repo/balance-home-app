import 'package:balance_home_app/src/features/coin/domain/entities/date_exchange_entity.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'date_exchanges_list_entity.freezed.dart';
part 'date_exchanges_list_entity.g.dart';

/// [DateExchangesListEntity] model
@freezed
class DateExchangesListEntity with _$DateExchangesListEntity {
  /// Factory constructor
  /// [dateExchanges] - [List] dateExchanges
  // ignore: invalid_annotation_target
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory DateExchangesListEntity(
          {required List<DateExchangeEntity> dateExchanges}) =
      _DateExchangesListEntity;

  // Serialization
  factory DateExchangesListEntity.fromJson(Map<String, dynamic> json) =>
      _$DateExchangesListEntityFromJson(json);
}
