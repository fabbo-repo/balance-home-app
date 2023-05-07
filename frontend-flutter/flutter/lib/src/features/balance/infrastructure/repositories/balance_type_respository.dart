import 'package:balance_home_app/src/core/domain/failures/failure.dart';
import 'package:balance_home_app/src/core/domain/failures/http_connection_failure.dart';
import 'package:balance_home_app/src/features/balance/infrastructure/datasources/local/balance_type_local_data_source.dart';
import 'package:balance_home_app/src/features/balance/infrastructure/datasources/remote/balance_type_remote_data_source.dart';
import 'package:balance_home_app/src/features/balance/domain/entities/balance_type_entity.dart';
import 'package:balance_home_app/src/features/balance/domain/repositories/balance_type_mode.dart';
import 'package:balance_home_app/src/features/balance/domain/repositories/balance_type_respository_interface.dart';
import 'package:fpdart/fpdart.dart';

/// Balance Type Repository.
class BalanceTypeRepository implements BalanceTypeRepositoryInterface {
  final BalanceTypeRemoteDataSource balanceTypeRemoteDataSource;
  final BalanceTypeLocalDataSource balanceTypeLocalDataSource;

  BalanceTypeRepository(
      {required this.balanceTypeRemoteDataSource,
      required this.balanceTypeLocalDataSource});

  /// Get [BalanceTypeEntity] by `name`.
  @override
  Future<Either<Failure, BalanceTypeEntity>> getBalanceType(
      String name, BalanceTypeMode balanceTypeMode) async {
    final response =
        await balanceTypeRemoteDataSource.get(name, balanceTypeMode);
    return await response.fold((failure) async {
      if (failure is HttpConnectionFailure) {
        return await balanceTypeLocalDataSource.get(name, balanceTypeMode);
      }
      return left(failure);
    }, (balanceType) async {
      // Store balance type data
      await balanceTypeLocalDataSource.put(balanceType, balanceTypeMode);
      return right(balanceType);
    });
  }

  /// Get a list of all [BalanceTypeEntity].
  @override
  Future<Either<Failure, List<BalanceTypeEntity>>> getBalanceTypes(
      BalanceTypeMode balanceTypeMode) async {
    final response = await balanceTypeRemoteDataSource.list(balanceTypeMode);
    return await response.fold((failure) async {
      if (failure is HttpConnectionFailure) {
        return await balanceTypeLocalDataSource.list(balanceTypeMode);
      }
      return left(failure);
    }, (balanceTypes) async {
      // Delete stored balance types data
      await balanceTypeLocalDataSource.deleteAll(balanceTypeMode);
      // Store balance types data
      for (final balanceType in balanceTypes) {
        await balanceTypeLocalDataSource.put(balanceType, balanceTypeMode);
      }
      return right(balanceTypes);
    });
  }
}
