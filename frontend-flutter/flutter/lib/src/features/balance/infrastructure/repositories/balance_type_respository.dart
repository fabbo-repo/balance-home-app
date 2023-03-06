import 'package:balance_home_app/src/core/domain/failures/failure.dart';
import 'package:balance_home_app/src/features/balance/infrastructure/datasources/remote/balance_type_remote_data_source.dart';
import 'package:balance_home_app/src/features/balance/domain/entities/balance_type_entity.dart';
import 'package:balance_home_app/src/features/balance/domain/repositories/balance_type_mode.dart';
import 'package:balance_home_app/src/features/balance/domain/repositories/balance_type_respository_interface.dart';
import 'package:fpdart/fpdart.dart';

/// Balance Type Repository.
class BalanceTypeRepository implements BalanceTypeRepositoryInterface {
  final BalanceTypeRemoteDataSource balanceTypeRemoteDataSource;

  BalanceTypeRepository({required this.balanceTypeRemoteDataSource});

  /// Get [BalanceTypeEntity] by `name`.
  @override
  Future<Either<Failure, BalanceTypeEntity>> getBalanceType(
      String name, BalanceTypeMode balanceTypeMode) async {
    return await balanceTypeRemoteDataSource.get(name, balanceTypeMode);
  }

  /// Get a list of all [BalanceTypeEntity].
  @override
  Future<Either<Failure, List<BalanceTypeEntity>>> getBalanceTypes(
      BalanceTypeMode balanceTypeMode) async {
    return await balanceTypeRemoteDataSource.list(balanceTypeMode);
  }
}
