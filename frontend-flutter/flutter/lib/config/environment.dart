import 'package:envied/envied.dart';

part 'environment.g.dart';

// This class contains all the environment variables
@Envied(path: 'app.env', requireEnvFile: true)
abstract class Environment {
  /// URL for API
  @EnviedField(varName: "API_URL", defaultValue: "localhost")
  static const String apiUrl = _Environment.apiUrl;
}