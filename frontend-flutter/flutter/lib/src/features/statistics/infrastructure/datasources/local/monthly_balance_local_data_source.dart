import 'package:balance_home_app/config/local_db_client.dart';
import 'package:balance_home_app/src/core/domain/failures/empty_failure.dart';
import 'package:balance_home_app/src/core/domain/failures/failure.dart';
import 'package:balance_home_app/src/core/domain/failures/no_local_entity_failure.dart';
import 'package:balance_home_app/src/features/statistics/domain/entities/monthly_balance_entity.dart';
import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart';

class MonthlyBalanceLocalDataSource {
  @visibleForTesting
  final LocalDbClient localDbClient;
  static const tableName = "monthlyBalance";

  MonthlyBalanceLocalDataSource({required this.localDbClient});

  Future<Either<Failure, MonthlyBalanceEntity>> get(int month, int year) async {
    try {
      final jsonId = "${month.toString()}_${year.toString()}";
      final jsonObj =
          await localDbClient.getById(tableName: tableName, id: jsonId);
      if (jsonObj == null) {
        return left(
            const NoLocalEntityFailure(entityName: tableName, detail: ""));
      }
      return right(MonthlyBalanceEntity.fromJson(jsonObj));
    } on Exception {
      return left(
          const NoLocalEntityFailure(entityName: tableName, detail: ""));
    }
  }

  Future<Either<Failure, void>> put(MonthlyBalanceEntity monthlyBalance) async {
    try {
      final jsonId =
          "${monthlyBalance.month.toString()}_${monthlyBalance.year.toString()}";
      await localDbClient.putById(
          tableName: tableName, id: jsonId, content: monthlyBalance.toJson());
      return right(null);
    } on Exception {
      return left(const EmptyFailure());
    }
  }

  Future<Either<Failure, List<MonthlyBalanceEntity>>> list(
      {required int? year}) async {
    try {
      final jsonObjList = await localDbClient.getAll(tableName: tableName);
      if (jsonObjList.isEmpty) {
        return left(
            const NoLocalEntityFailure(entityName: tableName, detail: ""));
      }
      final resList = <MonthlyBalanceEntity>[];
      for (final jsonObj in jsonObjList) {
        final monthlyBalance = MonthlyBalanceEntity.fromJson(jsonObj);
        if (year == null || monthlyBalance.year == year) {
          resList.add(monthlyBalance);
        }
      }
      return right(resList);
    } on Exception {
      return left(
          const NoLocalEntityFailure(entityName: tableName, detail: ""));
    }
  }

  Future<Either<Failure, void>> deleteAll() async {
    try {
      await localDbClient.deleteAll(tableName: tableName);
      return right(null);
    } on Exception {
      return left(const EmptyFailure());
    }
  }
}
