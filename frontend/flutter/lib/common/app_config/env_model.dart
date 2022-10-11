import 'package:flutter_dotenv/flutter_dotenv.dart';

class EnvModel {
  /// Backend service url
  static final String BASE_URL = dotenv.get('BASE_URL').replaceAll("\"", "");

  /// Loads all the environment variables from a file.
  /// 
  /// Default file name is '.env'
  static Future<void> loadEnvFile([String? fileName]) async {
    await dotenv.load(fileName: fileName ?? ".env");
  }

  /// Remoces all loaded environment variables.
  /// 
  /// Useful for testing
  static void clean() {
    dotenv.clean();
  }
}