import 'package:balance_home_app/src/core/domain/failures/bad_request_failure.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'input_bad_request_failure.g.dart';

/// Represents an input error in a bad request
@JsonSerializable(fieldRename: FieldRename.snake)
class InputBadRequestFailure extends BadRequestFailure {
  final List<InputField> fields;

  const InputBadRequestFailure({required String detail, required this.fields})
      : super(detail: detail);

  // Serialization
  factory InputBadRequestFailure.fromJson(Map<String, dynamic> json) =>
      _$InputBadRequestFailureFromJson(json);

  bool containsFieldName(String name) {
    for (final field in fields) {
      if (field.name == name) return true;
    }
    return false;
  }

  String getFieldDetail(String name) {
    for (final field in fields) {
      if (field.name == name) return field.detail;
    }
    return "";
  }
}

@JsonSerializable(fieldRename: FieldRename.snake)
class InputField {
  final String name;
  final String detail;

  const InputField({required this.name, required this.detail});

  // Serialization
  factory InputField.fromJson(Map<String, dynamic> json) =>
      _$InputFieldFromJson(json);
}
