import 'package:balance_home_app/src/core/providers/localization_state.dart';
import 'package:balance_home_app/src/core/providers/localization_state_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// StateNotifier
final localizationStateNotifierProvider = StateNotifierProvider<LocalizationStateNotifier, LocalizationState>(
  (StateNotifierProviderRef<LocalizationStateNotifier, LocalizationState> ref) => 
    LocalizationStateNotifier()
);