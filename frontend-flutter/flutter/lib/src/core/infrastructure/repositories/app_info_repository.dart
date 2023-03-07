import 'package:balance_home_app/src/core/domain/failures/failure.dart';
import 'package:balance_home_app/src/core/domain/repositories/app_info_repository_interface.dart';
import 'package:balance_home_app/src/core/infrastructure/datasources/remote/app_version_remote_data_source.dart';
import 'package:balance_home_app/src/core/presentation/models/app_version.dart';
import 'package:fpdart/fpdart.dart';

/// App info Repositorys
class AppInfoRepository extends AppInfoRepositoryInterface {
  final AppVersionRemoteDataSource appVersionRemoteDataSource;

  AppInfoRepository({required this.appVersionRemoteDataSource});

  /// Get app current last version
  @override
  Future<Either<Failure, AppVersion>> getVersion() async {
    return await appVersionRemoteDataSource.get();
  }
}
