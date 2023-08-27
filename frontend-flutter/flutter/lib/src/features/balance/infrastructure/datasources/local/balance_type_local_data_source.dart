import 'package:balance_home_app/src/core/clients/local_db_client.dart';
import 'package:balance_home_app/src/core/domain/failures/empty_failure.dart';
import 'package:balance_home_app/src/core/domain/failures/failure.dart';
import 'package:balance_home_app/src/core/domain/failures/no_local_entity_failure.dart';
import 'package:balance_home_app/src/features/balance/domain/entities/balance_type_entity.dart';
import 'package:balance_home_app/src/features/balance/domain/repositories/balance_type_mode.dart';
import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart';

class BalanceTypeLocalDataSource {
  @visibleForTesting
  final LocalDbClient localDbClient;
  static const tableName = "balanceType";

  BalanceTypeLocalDataSource({required this.localDbClient});

  Future<Either<Failure, BalanceTypeEntity>> get(
      final String name, final BalanceTypeMode typeMode) async {
    try {
      final id = "${typeMode.name}_$name";
      final jsonObj = await localDbClient.getById(tableName: tableName, id: id);
      if (jsonObj == null) {
        return left(
            const NoLocalEntityFailure(entityName: tableName, detail: ""));
      }
      return right(BalanceTypeEntity.fromJson(jsonObj));
    } on Exception {
      return left(
          const NoLocalEntityFailure(entityName: tableName, detail: ""));
    }
  }

  Future<Either<Failure, void>> put(
      BalanceTypeEntity balanceType, final BalanceTypeMode typeMode) async {
    try {
      final id = "${typeMode.name}_${balanceType.name}";
      await localDbClient.putById(
          tableName: tableName, id: id, content: balanceType.toJson());
      return right(null);
    } on Exception {
      return left(const EmptyFailure());
    }
  }

  Future<Either<Failure, List<BalanceTypeEntity>>> list(
      final BalanceTypeMode typeMode) async {
    try {
      final res = <BalanceTypeEntity>[];
      final jsonObj = await localDbClient.getAllWithIds(tableName: tableName);
      for (String id in jsonObj.keys) {
        if (id.startsWith(typeMode.name)) {
          final balanceTypeJson = Map<String, dynamic>.from(jsonObj[id]);
          res.add(BalanceTypeEntity.fromJson(balanceTypeJson));
        }
      }
      if (res.isEmpty) {
        return left(
            const NoLocalEntityFailure(entityName: tableName, detail: ""));
      }
      return right(res);
    } on Exception {
      return left(
          const NoLocalEntityFailure(entityName: tableName, detail: ""));
    }
  }

  Future<Either<Failure, void>> deleteAll(BalanceTypeMode typeMode) async {
    try {
      final jsonObj = await localDbClient.getAllWithIds(tableName: tableName);
      for (String jsonId in jsonObj.keys) {
        if (jsonId.startsWith(typeMode.name)) {
          await localDbClient.deleteById(tableName: tableName, id: jsonId);
        }
      }
      return right(null);
    } on Exception {
      return left(const EmptyFailure());
    }
  }
}
