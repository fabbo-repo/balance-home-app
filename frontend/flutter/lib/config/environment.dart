import 'package:envied/envied.dart';

part 'environment.g.dart';

// This class contains all the environment variables
@Envied(path: '.env', obfuscate: true)
abstract class Environment {
  /// URL for API
  @EnviedField(varName: "API_URL")
  static final apiUrl = _Environment.apiUrl;
}