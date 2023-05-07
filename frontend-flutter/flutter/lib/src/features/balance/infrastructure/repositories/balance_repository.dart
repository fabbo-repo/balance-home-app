import 'package:balance_home_app/src/core/domain/failures/failure.dart';
import 'package:balance_home_app/src/core/domain/failures/http_connection_failure.dart';
import 'package:balance_home_app/src/features/balance/domain/entities/balance_entity.dart';
import 'package:balance_home_app/src/features/balance/infrastructure/datasources/local/balance_local_data_source.dart';
import 'package:balance_home_app/src/features/balance/infrastructure/datasources/remote/balance_remote_data_source.dart';
import 'package:balance_home_app/src/features/balance/domain/repositories/balance_repository_interface.dart';
import 'package:balance_home_app/src/features/balance/domain/repositories/balance_type_mode.dart';
import 'package:fpdart/fpdart.dart';

/// Balance Repository.
class BalanceRepository implements BalanceRepositoryInterface {
  final BalanceRemoteDataSource balanceRemoteDataSource;
  final BalanceLocalDataSource balanceLocalDataSource;

  BalanceRepository(
      {required this.balanceRemoteDataSource,
      required this.balanceLocalDataSource});

  /// Get [BalanceEntity] by `id`.
  @override
  Future<Either<Failure, BalanceEntity>> getBalance(
      int id, BalanceTypeMode balanceTypeMode) async {
    final response = await balanceRemoteDataSource.get(id, balanceTypeMode);
    return await response.fold((failure) async {
      if (failure is HttpConnectionFailure) {
        return await balanceLocalDataSource.get(id, balanceTypeMode);
      }
      return left(failure);
    }, (balance) async {
      // Store balance data
      await balanceLocalDataSource.put(balance, balanceTypeMode);
      return right(balance);
    });
  }

  /// Get a list of [BalanceEntity].
  @override
  Future<Either<Failure, List<BalanceEntity>>> getBalances(
      BalanceTypeMode balanceTypeMode,
      {DateTime? dateFrom,
      DateTime? dateTo}) async {
    final response = await balanceRemoteDataSource.list(balanceTypeMode,
        dateFrom: dateFrom, dateTo: dateTo);
    return await response.fold((failure) async {
      if (failure is HttpConnectionFailure) {
        return await balanceLocalDataSource.list(balanceTypeMode,
            dateFrom: dateFrom, dateTo: dateTo);
      }
      return left(failure);
    }, (balances) async {
      // Delete stored balance data
      await balanceLocalDataSource.deleteAll(balanceTypeMode);
      // Store balances data
      for (final balance in balances) {
        await balanceLocalDataSource.put(balance, balanceTypeMode);
      }
      return right(balances);
    });
  }

  /// Get a list of years related to existing [BalanceEntity] years.
  @override
  Future<Either<Failure, List<int>>> getBalanceYears(
      BalanceTypeMode balanceTypeMode) async {
    return await balanceRemoteDataSource.getYears(balanceTypeMode);
  }

  /// Store a [BalanceEntity].
  @override
  Future<Either<Failure, BalanceEntity>> createBalance(
      BalanceEntity balance, BalanceTypeMode balanceTypeMode) async {
    return await balanceRemoteDataSource.create(balance, balanceTypeMode);
  }

  /// Update a [BalanceEntity].
  @override
  Future<Either<Failure, BalanceEntity>> updateBalance(
      BalanceEntity balance, BalanceTypeMode balanceTypeMode) async {
    return await balanceRemoteDataSource.update(balance, balanceTypeMode);
  }

  /// Delete a [BalanceEntity].
  @override
  Future<Either<Failure, void>> deleteBalance(
      BalanceEntity balance, BalanceTypeMode balanceTypeMode) async {
    return await balanceRemoteDataSource.delete(balance, balanceTypeMode);
  }
}
