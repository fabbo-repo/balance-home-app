import 'package:balance_home_app/config/api_contract.dart';
import 'package:balance_home_app/src/core/domain/failures/failure.dart';
import 'package:balance_home_app/src/core/presentation/models/app_version.dart';
import 'package:balance_home_app/src/http_client.dart';
import 'package:fpdart/fpdart.dart';

class AppVersionRemoteDataSource {
  final HttpClient client;

  /// Default constructor for [AppVersionRemoteDataSource]
  AppVersionRemoteDataSource(this.client);

  Future<Either<Failure, AppVersion>> get() async {
    HttpResponse response =
        await client.sendGetRequest(APIContract.frontendVersion);
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
