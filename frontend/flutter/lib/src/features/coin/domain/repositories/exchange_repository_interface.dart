import 'package:balance_home_app/config/api_contract.dart';
import 'package:balance_home_app/src/core/infrastructure/datasources/remote/http_service.dart';
import 'package:balance_home_app/src/features/coin/domain/entities/date_exchanges_list_entity.dart';
import 'package:balance_home_app/src/features/coin/domain/entities/exchanges_list_entity.dart';

/// Exchange Repository Interface.
abstract class ExchangeRepositoryInterface {
  /// Get [ExchangesListEntity] by `code`.
  Future<ExchangesListEntity> getExchanges(String code);

  /// Get [DateExchangesListEntity] by `days`.
  Future<DateExchangesListEntity> getLastDateExchanges({required int days});
}
