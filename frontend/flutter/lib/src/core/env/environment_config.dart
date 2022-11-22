import 'package:envied/envied.dart';

part 'environment_config.g.dart';

// This class contains all the environment variables
@Envied(path: '.env', obfuscate: true)
abstract class EnvironmentConfig {
  /// URL for API
  @EnviedField(varName: "API_URL")
  static final apiUrl = _EnvironmentConfig.apiUrl;
}