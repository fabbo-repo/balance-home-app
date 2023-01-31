import 'package:balance_home_app/src/core/domain/failures/failure.dart';
import 'package:balance_home_app/src/features/coin/infrastructure/datasources/remote/coin_type_remote_data_source.dart';
import 'package:balance_home_app/src/features/coin/domain/entities/coin_type_entity.dart';
import 'package:balance_home_app/src/features/coin/domain/repositories/coin_type_repository_interface.dart';
import 'package:fpdart/fpdart.dart';

class CoinTypeRepository implements CoinTypeRepositoryInterface {
  final CoinTypeRemoteDataSource coinTypeRemoteDataSource;

  CoinTypeRepository({required this.coinTypeRemoteDataSource});

  /// Get [CoinTypeEntity] by `code`.
  @override
  Future<Either<Failure, CoinTypeEntity>> getCoinType(String code) async {
    return await coinTypeRemoteDataSource.get(code);
  }

  /// Get a list of [CoinTypeEntity].
  @override
  Future<Either<Failure, List<CoinTypeEntity>>> getCoinTypes() async {
    return await coinTypeRemoteDataSource.list();
  }
}
