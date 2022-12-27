import 'package:balance_home_app/config/api_contract.dart';
import 'package:balance_home_app/src/core/domain/failures/failure.dart';
import 'package:balance_home_app/src/core/domain/repositories/app_info_repository_interface.dart';
import 'package:balance_home_app/src/http_service.dart';
import 'package:balance_home_app/src/core/presentation/models/app_version.dart';
import 'package:fpdart/fpdart.dart';

/// App info Repositorys
class AppInfoRepository extends AppInfoRepositoryInterface {
  final HttpService httpService;

  AppInfoRepository({required this.httpService});

  /// Get app current last version
  @override
  Future<Either<Failure, AppVersion>> getVersion() async {
    HttpResponse response =
        await httpService.sendGetRequest(APIContract.frontendVersion);
    if (response.hasError) {
      return left(Failure.badRequest(message: response.errorMessage));
    }
    List<String> version = response.content["version"].split(".");
    return right(AppVersion(
        x: int.parse(version[0]),
        y: int.parse(version[1]),
        z: int.parse(version[2])));
  }
}
