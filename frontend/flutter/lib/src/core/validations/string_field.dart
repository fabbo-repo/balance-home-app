import 'package:freezed_annotation/freezed_annotation.dart';

part 'string_field.freezed.dart';

@freezed
class StringField with _$StringField {
  const factory StringField(
    {
      required String value,
      @Default('') String errorMessage,
      @Default(false) bool isValid
    }
  ) = _StringField;
}