import 'package:balance_home_app/src/features/statistics/presentation/models/selected_exchange.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SelectedExchangeState extends StateNotifier<SelectedExchange> {
  SelectedExchangeState({required String coinFrom, required String coinTo})
      : super(SelectedExchange(coinFrom: coinFrom, coinTo: coinTo));

  void setSelectedExchange(SelectedExchange selectedExchange) {
    state = selectedExchange;
  }

  void setCoinFrom(String coinFrom) {
    state = state.copyWith(coinFrom: coinFrom);
  }

  void setCoinTo(String coinTo) {
    state = state.copyWith(coinTo: coinTo);
  }
}
