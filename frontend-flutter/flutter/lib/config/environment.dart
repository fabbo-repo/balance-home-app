import 'package:envied/envied.dart';

part 'environment.g.dart';

// This class contains all the environment variables
@Envied(path: 'app.env', requireEnvFile: true)
abstract class Environment {
  /// Balhom API URL
  @EnviedField(varName: "API_URL", defaultValue: "localhost")
  static const String apiUrl = _Environment.apiUrl;
  
  /// Keycloak URL
  @EnviedField(varName: "KEYCLOAK_URL", defaultValue: "localhost")
  static const String keycloakUrl = _Environment.keycloakUrl;

  /// Keycloak Realm
  @EnviedField(varName: "KEYCLOAK_REALM", defaultValue: "balhom")
  static const String keycloakRealm = _Environment.keycloakRealm;

  /// Keycloak Client Id
  @EnviedField(varName: "KEYCLOAK_CLIENT_ID", defaultValue: "balhom")
  static const String keycloakClientId = _Environment.keycloakClientId;
}