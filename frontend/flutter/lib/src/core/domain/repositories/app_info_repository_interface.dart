import 'package:balance_home_app/src/core/presentation/models/app_version.dart';

/// App info Repository Interface
abstract class AppInfoRepositoryInterface {
  /// Get app current last version
  Future<AppVersion> getVersion();
}