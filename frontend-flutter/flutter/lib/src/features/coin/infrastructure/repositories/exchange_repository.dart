import 'package:balance_home_app/src/core/domain/failures/failure.dart';
import 'package:balance_home_app/src/features/coin/infrastructure/datasources/remote/exchange_remote_data_source.dart';
import 'package:balance_home_app/src/features/coin/domain/entities/date_exchanges_list_entity.dart';
import 'package:balance_home_app/src/features/coin/domain/entities/exchanges_list_entity.dart';
import 'package:balance_home_app/src/features/coin/domain/repositories/exchange_repository_interface.dart';
import 'package:fpdart/fpdart.dart';

class ExchangeRepository implements ExchangeRepositoryInterface {
  final ExchangeRemoteDataSource exchangeRemoteDataSource;

  ExchangeRepository({required this.exchangeRemoteDataSource});

  /// Get [ExchangesListEntity] by `code`.
  @override
  Future<Either<Failure, ExchangesListEntity>> getExchanges(String code) async {
    return await exchangeRemoteDataSource.get(code);
  }

  /// Get [DateExchangesListEntity] by `days`.
  @override
  Future<Either<Failure, DateExchangesListEntity>> getLastDateExchanges(
      {required int days}) async {
    return await exchangeRemoteDataSource.getLastDate(days: days);
  }
}
