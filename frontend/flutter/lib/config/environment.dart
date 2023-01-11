import 'package:envied/envied.dart';

part 'environment.g.dart';

// This class contains all the environment variables
@Envied(path: '.env')
abstract class Environment {
  /// URL for API
  @EnviedField(varName: "API_URL", obfuscate: true)
  static final apiUrl = _Environment.apiUrl;
}