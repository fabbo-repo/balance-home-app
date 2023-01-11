import 'package:balance_home_app/src/http_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:shared_preferences/shared_preferences.dart';

///
/// Infrastructure dependencies
///

/// Exposes [FlutterSecureStorage] instance
final secureStorageProvider = Provider((ref) => const FlutterSecureStorage());

/// Exposes [SharedPreferences] instance
final sharedPreferencesProvider =
    FutureProvider((ref) => SharedPreferences.getInstance());

/// Exposes [HttpService] client
final httpServiceProvider = Provider<HttpService>((ref) {
  return HttpService(secureStorage: ref.read(secureStorageProvider));
});

/// Triggered from bootstrap() to complete futures
Future<void> initializeProviders(ProviderContainer container) async {
  usePathUrlStrategy();

  /// Core
  container.read(secureStorageProvider);
  await container.read(sharedPreferencesProvider.future);
  container.read(httpServiceProvider);
}
