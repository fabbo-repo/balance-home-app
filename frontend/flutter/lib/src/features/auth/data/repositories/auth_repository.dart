import 'package:balance_home_app/src/core/services/api_contract.dart';
import 'package:balance_home_app/src/core/services/http_service.dart';
import 'package:balance_home_app/src/features/auth/data/models/account_model.dart';

abstract class IAuthRepository {
  Future<AccountModel> getAccount();
}

class AuthRepository implements IAuthRepository {

  final HttpService httpService;

  AuthRepository({required this.httpService});

  @override
  Future<AccountModel> getAccount() async {
    HttpResponse response = await httpService.sendGetRequest(
      APIContract.userProfile
    );
    return AccountModel.fromJson(response.content);
  }
}