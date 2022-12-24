import 'package:balance_home_app/config/api_contract.dart';
import 'package:balance_home_app/src/core/domain/repositories/app_info_repository_interface.dart';
import 'package:balance_home_app/src/core/infrastructure/datasources/remote/http_service.dart';
import 'package:balance_home_app/src/core/presentation/models/app_version.dart';

/// App info Repositorys
class AppInfoRepository extends AppInfoRepositoryInterface {
  final HttpService httpService;

  AppInfoRepository({required this.httpService});

  /// Get app current last version
  @override
  Future<AppVersion> getVersion() async {
    HttpResponse response =
        await httpService.sendGetRequest(APIContract.frontendVersion);
    List<String> version = response.content["version"].split(".");
    return AppVersion(
        x: int.parse(version[0]),
        y: int.parse(version[1]),
        z: int.parse(version[2]));
  }
}