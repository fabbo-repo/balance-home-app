import 'package:balance_home_app/src/core/clients/local_db_client.dart';
import 'package:balance_home_app/src/core/domain/failures/empty_failure.dart';
import 'package:balance_home_app/src/core/domain/failures/failure.dart';
import 'package:balance_home_app/src/core/domain/failures/no_local_entity_failure.dart';
import 'package:balance_home_app/src/features/currency/domain/entities/currency_type_entity.dart';
import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart';

class CurrencyTypeLocalDataSource {
  @visibleForTesting
  final LocalDbClient localDbClient;
  static const tableName = "currencyType";

  CurrencyTypeLocalDataSource({required this.localDbClient});

  Future<Either<Failure, CurrencyTypeEntity>> get(String code) async {
    try {
      final jsonObj =
          await localDbClient.getById(tableName: tableName, id: code);
      if (jsonObj == null) {
        return left(const NoLocalEntityFailure(entityName: tableName, detail: ""));
      }
      return right(CurrencyTypeEntity.fromJson(jsonObj));
    } on Exception {
      return left(const NoLocalEntityFailure(entityName: tableName, detail: ""));
    }
  }

  Future<Either<Failure, void>> put(CurrencyTypeEntity currencyType) async {
    try {
      await localDbClient.putById(
          tableName: tableName,
          id: currencyType.code,
          content: currencyType.toJson());
      return right(null);
    } on Exception {
      return left(const EmptyFailure());
    }
  }

  Future<Either<Failure, List<CurrencyTypeEntity>>> list() async {
    try {
      final jsonObjList = await localDbClient.getAll(tableName: tableName);
      if (jsonObjList.isEmpty) {
        return left(const NoLocalEntityFailure(entityName: tableName, detail: ""));
      }
      return right(
          jsonObjList.map((e) => CurrencyTypeEntity.fromJson(e)).toList());
    } on Exception {
      return left(const NoLocalEntityFailure(entityName: tableName, detail: ""));
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
