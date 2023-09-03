import 'package:envied/envied.dart';

part 'app_environment.g.dart';

// This class contains all the environment variables
@Envied(path: 'app.env', requireEnvFile: true)
abstract class AppEnvironment {
  /// Balhom API URL
  @EnviedField(varName: "API_URL", defaultValue: "localhost")
  static const String apiUrl = _AppEnvironment.apiUrl;
  
  /// Keycloak URL
  @EnviedField(varName: "KEYCLOAK_URL", defaultValue: "localhost")
  static const String keycloakUrl = _AppEnvironment.keycloakUrl;

  /// Keycloak Realm
  @EnviedField(varName: "KEYCLOAK_REALM", defaultValue: "balhom")
  static const String keycloakRealm = _AppEnvironment.keycloakRealm;

  /// Keycloak Client Id
  @EnviedField(varName: "KEYCLOAK_CLIENT_ID", defaultValue: "balhom")
  static const String keycloakClientId = _AppEnvironment.keycloakClientId;
}