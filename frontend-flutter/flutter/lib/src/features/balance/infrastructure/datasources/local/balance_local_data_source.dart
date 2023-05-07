import 'package:balance_home_app/config/local_db_client.dart';
import 'package:balance_home_app/src/core/domain/failures/empty_failure.dart';
import 'package:balance_home_app/src/core/domain/failures/failure.dart';
import 'package:balance_home_app/src/core/domain/failures/no_local_entity_failure.dart';
import 'package:balance_home_app/src/features/balance/domain/entities/balance_entity.dart';
import 'package:balance_home_app/src/features/balance/domain/repositories/balance_type_mode.dart';
import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart';

class BalanceLocalDataSource {
  @visibleForTesting
  final LocalDbClient localDbClient;
  static const tableName = "balance";

  BalanceLocalDataSource({required this.localDbClient});

  Future<Either<Failure, BalanceEntity>> get(
      final int id, final BalanceTypeMode typeMode) async {
    try {
      final jsonId = "${typeMode.name}_${id.toString()}";
      final jsonObj =
          await localDbClient.getById(tableName: tableName, id: jsonId);
      if (jsonObj == null) {
        return left(
            const NoLocalEntityFailure(entityName: tableName, detail: ""));
      }
      return right(BalanceEntity.fromJson(jsonObj));
    } on Exception {
      return left(
          const NoLocalEntityFailure(entityName: tableName, detail: ""));
    }
  }

  Future<Either<Failure, void>> put(
      BalanceEntity balance, final BalanceTypeMode typeMode) async {
    try {
      final jsonId = "${typeMode.name}_${balance.id.toString()}";
      final jsonBalance = balance.toJson();
      jsonBalance["balance_type"] = jsonBalance["balance_type"].toJson();
      await localDbClient.putById(
          tableName: tableName, id: jsonId, content: jsonBalance);
      return right(null);
    } on Exception {
      return left(const EmptyFailure());
    }
  }

  Future<Either<Failure, List<BalanceEntity>>> list(BalanceTypeMode typeMode,
      {DateTime? dateFrom, DateTime? dateTo}) async {
    try {
      final res = <BalanceEntity>[];
      final jsonObj = await localDbClient.getAllWithIds(tableName: tableName);
      for (String id in jsonObj.keys) {
        if (id.startsWith(typeMode.name)) {
          final balanceJson = Map<String, dynamic>.from(jsonObj[id]);
          balanceJson["balance_type"] =
              Map<String, dynamic>.from(balanceJson["balance_type"]);
          final balance = BalanceEntity.fromJson(balanceJson);
          if (dateFrom != null && balance.date.isBefore(dateFrom)) continue;
          if (dateTo != null && balance.date.isAfter(dateTo)) continue;
          res.add(balance);
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
