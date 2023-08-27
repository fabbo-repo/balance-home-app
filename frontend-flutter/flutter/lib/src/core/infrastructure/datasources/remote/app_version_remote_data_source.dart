import 'package:balance_home_app/config/api_contract.dart';
import 'package:balance_home_app/src/core/clients/api_client.dart';
import 'package:balance_home_app/src/core/domain/failures/failure.dart';
import 'package:balance_home_app/src/core/presentation/models/app_version.dart';
import 'package:fpdart/fpdart.dart';

class AppVersionRemoteDataSource {
  final ApiClient apiClient;

  /// Default constructor for [AppVersionRemoteDataSource]
  AppVersionRemoteDataSource({required this.apiClient});

  Future<Either<Failure, AppVersion>> get() async {
    final response = await apiClient.getRequest(APIContract.frontendVersion);
    // Check if there is a request failure
    return response.fold((failure) => left(failure), (value) {
      List<String> version = value.data["version"].split(".");
      return right(AppVersion(
          x: int.parse(version[0]),
          y: int.parse(version[1]),
          z: int.parse(version[2])));
    });
  }
}
