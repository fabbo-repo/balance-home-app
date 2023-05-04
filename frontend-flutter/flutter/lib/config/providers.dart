import 'package:balance_home_app/config/api_client.dart';
import 'package:balance_home_app/config/local_preferences_client.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:universal_io/io.dart';

///
/// Infrastructure dependencies
///

/// Exposes [LocalPreferencesClient] instance
final localPreferencesClientProvider =
    Provider((ref) => LocalPreferencesClient());

/// Exposes [HttpClient] instance
final apiClientProvider = Provider((ref) {
  return ApiClient();
});

/// Triggered from bootstrap() to complete futures
Future<void> initializeProviders(ProviderContainer container) async {
  usePathUrlStrategy();

  /// Core
  container.read(apiClientProvider);
  container.read(localPreferencesClientProvider);
}
