import 'package:balance_home_app/src/core/domain/failures/failure.dart';
import 'package:balance_home_app/src/features/statistics/infrastructure/datasources/remote/monthly_balance_remote_data_source.dart';
import 'package:balance_home_app/src/features/statistics/domain/entities/monthly_balance_entity.dart';
import 'package:balance_home_app/src/features/statistics/domain/repositories/monthly_balance_repository_interface.dart';
import 'package:fpdart/fpdart.dart';

class MonthlyBalanceRepository implements MonthlyBalanceRepositoryInterface {
  final MonthlyBalanceRemoteDataSource monthlyBalanceRemoteDataSource;

  MonthlyBalanceRepository({required this.monthlyBalanceRemoteDataSource});

  /// Get [MonthlyBalanceEntity] by `id`.
  @override
  Future<Either<Failure, MonthlyBalanceEntity>> getMonthlyBalance(
      int id) async {
    return await monthlyBalanceRemoteDataSource.get(id);
  }

  /// Get a list of [MonthlyBalanceEntity].
  @override
  Future<Either<Failure, List<MonthlyBalanceEntity>>> getMonthlyBalances(
      {int? year}) async {
    return await monthlyBalanceRemoteDataSource.list(year: year);
  }
}
