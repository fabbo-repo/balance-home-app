import 'package:freezed_annotation/freezed_annotation.dart';

part 'pagination_entity.freezed.dart';
part 'pagination_entity.g.dart';

/// [PaginationEntity] model
@freezed
class PaginationEntity with _$PaginationEntity {
  
  /// Factory constructor
  /// [count] - [PaginationEntity] number of elements in results
  /// [next] - [PaginationEntity] next page url
  /// [previous] - [PaginationEntity] previous page url
  /// [results] - [PaginationEntity] results list
  // ignore: invalid_annotation_target
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory PaginationEntity({
      required int count,
      String? next,
      String? previous,
      required List<dynamic> results,
  }) = _PaginationEntity;

  // Serialization
  factory PaginationEntity.fromJson(Map<String, dynamic> json) =>
    _$PaginationEntityFromJson(json);
}