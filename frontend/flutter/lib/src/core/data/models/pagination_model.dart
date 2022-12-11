import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'pagination_model.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class PaginationModel extends Equatable {

  final int count;
  final String? next;
  final String? previous;
  final List<dynamic> results;

  const PaginationModel({
      required this.count,
      this.next,
      this.previous,
      required this.results,
  });

  // Json Serializable
  factory PaginationModel.fromJson(Map<String, dynamic> json) =>
    _$PaginationModelFromJson(json);

  Map<String, dynamic> toJson() => _$PaginationModelToJson(this);

  @override
  List<Object?> get props => [];
}