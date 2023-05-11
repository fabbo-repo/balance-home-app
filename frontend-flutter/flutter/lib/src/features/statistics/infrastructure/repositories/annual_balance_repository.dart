import 'package:balance_home_app/src/core/domain/failures/failure.dart';
import 'package:balance_home_app/src/core/domain/failures/http_connection_failure.dart';
import 'package:balance_home_app/src/features/statistics/infrastructure/datasources/local/annual_balance_local_data_source.dart';
import 'package:balance_home_app/src/features/statistics/infrastructure/datasources/remote/annual_balance_remote_data_source.dart';
import 'package:balance_home_app/src/features/statistics/domain/entities/annual_balance_entity.dart';
import 'package:balance_home_app/src/features/statistics/domain/repositories/annual_balance_repository_interface.dart';
import 'package:fpdart/fpdart.dart';

class AnnualBalanceRepository implements AnnualBalanceRepositoryInterface {
  final AnnualBalanceRemoteDataSource annualBalanceRemoteDataSource;
  final AnnualBalanceLocalDataSource annualBalanceLocalDataSource;

  AnnualBalanceRepository(
      {required this.annualBalanceRemoteDataSource,
      required this.annualBalanceLocalDataSource});

  /// Get [AnnualBalanceEntity] by `id`.
  @override
  Future<Either<Failure, AnnualBalanceEntity>> getAnnualBalance(int id) async {
    final res = await annualBalanceRemoteDataSource.get(id);
    return await res.fold((failure) => left(failure), (annualBalance) async {
      await annualBalanceLocalDataSource.put(annualBalance);
      return right(annualBalance);
    });
  }

  /// Get a list of [AnnualBalanceEntity].
  @override
  Future<Either<Failure, List<AnnualBalanceEntity>>> getAnnualBalances() async {
    final res = await annualBalanceRemoteDataSource.list();
    return await res.fold((failure) async {
      if (failure is HttpConnectionFailure) {
        return await annualBalanceLocalDataSource.list();
      }
      return left(failure);
    }, (annualBalances) async {
      await annualBalanceLocalDataSource.deleteAll();
      for (var annualBalance in annualBalances) {
        await annualBalanceLocalDataSource.put(annualBalance);
      }
      return right(annualBalances);
    });
  }
}
