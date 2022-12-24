import 'package:balance_home_app/src/features/coin/domain/entities/exchange_entity.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'exchanges_list_entity.freezed.dart';
part 'exchanges_list_entity.g.dart';

/// [ExchangesListEntity] model
@freezed
class ExchangesListEntity with _$ExchangesListEntity {
  /// Factory constructor
  /// [code] - [ExchangesListEntity] code
  /// [exchanges] - [ExchangesListEntity] exchanges
  // ignore: invalid_annotation_target
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory ExchangesListEntity(
      {required String code,
      required List<ExchangeEntity> exchanges}) = _ExchangesListEntity;

  // Serialization
  factory ExchangesListEntity.fromJson(Map<String, dynamic> json) =>
      _$ExchangesListEntityFromJson(json);
}
