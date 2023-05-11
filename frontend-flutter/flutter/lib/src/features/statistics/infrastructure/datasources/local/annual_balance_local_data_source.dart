import 'package:balance_home_app/config/local_db_client.dart';
import 'package:balance_home_app/src/core/domain/failures/empty_failure.dart';
import 'package:balance_home_app/src/core/domain/failures/failure.dart';
import 'package:balance_home_app/src/core/domain/failures/no_local_entity_failure.dart';
import 'package:balance_home_app/src/features/statistics/domain/entities/annual_balance_entity.dart';
import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart';

class AnnualBalanceLocalDataSource {
  @visibleForTesting
  final LocalDbClient localDbClient;
  static const tableName = "annualBalance";

  AnnualBalanceLocalDataSource({required this.localDbClient});

  Future<Either<Failure, AnnualBalanceEntity>> get(int year) async {
    try {
      final jsonObj = await localDbClient.getById(
          tableName: tableName, id: year.toString());
      if (jsonObj == null) {
        return left(
            const NoLocalEntityFailure(entityName: tableName, detail: ""));
      }
      return right(AnnualBalanceEntity.fromJson(jsonObj));
    } on Exception {
      return left(
          const NoLocalEntityFailure(entityName: tableName, detail: ""));
    }
  }

  Future<Either<Failure, void>> put(AnnualBalanceEntity annualBalance) async {
    try {
      final jsonAnnualBalance = annualBalance.toJson();
      await localDbClient.putById(
          tableName: tableName,
          id: annualBalance.year.toString(),
          content: jsonAnnualBalance);
      return right(null);
    } on Exception {
      return left(const EmptyFailure());
    }
  }

  Future<Either<Failure, List<AnnualBalanceEntity>>> list() async {
    try {
      final jsonObjList = await localDbClient.getAll(tableName: tableName);
      if (jsonObjList.isEmpty) {
        return left(
            const NoLocalEntityFailure(entityName: tableName, detail: ""));
      }
      return right(
          jsonObjList.map((e) => AnnualBalanceEntity.fromJson(e)).toList());
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
