import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'pagination_entity.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class PaginationEntity extends Equatable {

  final int count;
  final String? next;
  final String? previous;
  final List<dynamic> results;

  const PaginationEntity({
      required this.count,
      this.next,
      this.previous,
      required this.results,
  });

  // Json Serializable
  factory PaginationEntity.fromJson(Map<String, dynamic> json) =>
    _$PaginationEntityFromJson(json);

  Map<String, dynamic> toJson() => _$PaginationEntityToJson(this);

  @override
  List<Object?> get props => [];
}