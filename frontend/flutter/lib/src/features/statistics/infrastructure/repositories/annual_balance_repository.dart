import 'package:balance_home_app/src/core/domain/failures/failure.dart';
import 'package:balance_home_app/src/features/statistics/infrastructure/datasources/remote/annual_balance_remote_data_source.dart';
import 'package:balance_home_app/src/features/statistics/domain/entities/annual_balance_entity.dart';
import 'package:balance_home_app/src/features/statistics/domain/repositories/annual_balance_repository_interface.dart';
import 'package:fpdart/fpdart.dart';

class AnnualBalanceRepository implements AnnualBalanceRepositoryInterface {
  final AnnualBalanceRemoteDataSource annualBalanceRemoteDataSource;

  AnnualBalanceRepository({required this.annualBalanceRemoteDataSource});

  /// Get [AnnualBalanceEntity] by `id`.
  @override
  Future<Either<Failure, AnnualBalanceEntity>> getAnnualBalance(int id) async {
    return await annualBalanceRemoteDataSource.get(id);
  }

  /// Get a list of [AnnualBalanceEntity].
  @override
  Future<Either<Failure, List<AnnualBalanceEntity>>> getAnnualBalances() async {
    return await annualBalanceRemoteDataSource.list();
  }

  /// Get last eight [AnnualBalanceEntity].
  @override
  Future<Either<Failure, List<AnnualBalanceEntity>>>
      getLastEightYearsAnnualBalances() async {
    return await annualBalanceRemoteDataSource.getLastEightYears();
  }
}
