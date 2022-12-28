import 'package:freezed_annotation/freezed_annotation.dart';

part 'selected_exchange.freezed.dart';

@freezed
class SelectedExchange with _$SelectedExchange {

  const factory SelectedExchange({
    required String coinFrom,
    required String coinTo,
  }) = _SelectedExchange;
}