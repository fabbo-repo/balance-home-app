import 'package:balance_home_app/config/environment.dart';
import 'package:balance_home_app/src/http_client.dart';
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

/// Exposes [HttpClient] instance
final httpClientProvider = Provider((ref) => HttpClient(Environment.apiUrl));

/// Triggered from bootstrap() to complete futures
Future<void> initializeProviders(ProviderContainer container) async {
  usePathUrlStrategy();

  /// Core
  container.read(secureStorageProvider);
  container.read(httpClientProvider);
  await container.read(sharedPreferencesProvider.future);
}
