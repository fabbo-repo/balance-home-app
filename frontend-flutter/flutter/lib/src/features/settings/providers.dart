import 'package:balance_home_app/src/core/providers.dart';
import 'package:balance_home_app/src/features/auth/application/settings_controller.dart';
import 'package:balance_home_app/src/features/settings/domain/repositories/settings_repository_interface.dart';
import 'package:balance_home_app/src/features/settings/infrastructure/datasources/local/theme_local_data_source.dart';
import 'package:balance_home_app/src/features/settings/infrastructure/repositories/settings_repository.dart';
import 'package:balance_home_app/src/features/auth/providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

///
/// Infrastructure dependencies
///

final settingsRepositoryProvider = Provider<SettingsRepositoryInterface>((ref) {
  return SettingsRepository(
    themeLocalDataSource: ThemeLocalDataSource(
        storageClient: ref.read(localPreferencesClientProvider)),
  );
});

///
/// Application dependencies
///

final settingsControllerProvider =
    StateNotifierProvider<SettingsController, AsyncValue<void>>((ref) {
  final authRepo = ref.read(authRepositoryProvider);
  final settingsRepo = ref.read(settingsRepositoryProvider);
  return SettingsController(authRepo, settingsRepo);
});
