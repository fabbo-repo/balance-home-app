import 'package:balance_home_app/src/core/domain/failures/failure.dart';
import 'package:balance_home_app/src/core/domain/failures/http_connection_failure.dart';
import 'package:balance_home_app/src/features/statistics/infrastructure/datasources/local/monthly_balance_local_data_source.dart';
import 'package:balance_home_app/src/features/statistics/infrastructure/datasources/remote/monthly_balance_remote_data_source.dart';
import 'package:balance_home_app/src/features/statistics/domain/entities/monthly_balance_entity.dart';
import 'package:balance_home_app/src/features/statistics/domain/repositories/monthly_balance_repository_interface.dart';
import 'package:fpdart/fpdart.dart';

class MonthlyBalanceRepository implements MonthlyBalanceRepositoryInterface {
  final MonthlyBalanceRemoteDataSource monthlyBalanceRemoteDataSource;
  final MonthlyBalanceLocalDataSource monthlyBalanceLocalDataSource;

  MonthlyBalanceRepository(
      {required this.monthlyBalanceRemoteDataSource,
      required this.monthlyBalanceLocalDataSource});

  /// Get [MonthlyBalanceEntity] by `id`.
  @override
  Future<Either<Failure, MonthlyBalanceEntity>> getMonthlyBalance(
      int id) async {
    final res = await monthlyBalanceRemoteDataSource.get(id);
    return await res.fold((failure) => left(failure), (monthlyBalance) async {
      await monthlyBalanceLocalDataSource.put(monthlyBalance);
      return right(monthlyBalance);
    });
  }

  /// Get a list of [MonthlyBalanceEntity].
  @override
  Future<Either<Failure, List<MonthlyBalanceEntity>>> getMonthlyBalances(
      {int? year}) async {
    final res = await monthlyBalanceRemoteDataSource.list(year: year);
    return await res.fold((failure) async {
      if (failure is HttpConnectionFailure) {
        return await monthlyBalanceLocalDataSource.list(year: year);
      }
      return left(failure);
    }, (monthlyBalances) async {
      await monthlyBalanceLocalDataSource.deleteAll();
      for (var monthlyBalance in monthlyBalances) {
        await monthlyBalanceLocalDataSource.put(monthlyBalance);
      }
      return right(monthlyBalances);
    });
  }
}
