import 'package:balance_home_app/config/api_contract.dart';
import 'package:balance_home_app/config/local_db_client.dart';
import 'package:balance_home_app/src/core/domain/failures/empty_failure.dart';
import 'package:balance_home_app/src/core/domain/failures/failure.dart';
import 'package:balance_home_app/src/core/domain/failures/no_local_entity_failure.dart';
import 'package:balance_home_app/src/features/auth/domain/entities/user_entity.dart';
import 'package:flutter/cupertino.dart';
import 'package:fpdart/fpdart.dart';

class UserLocalDataSource {
  @visibleForTesting
  final LocalDbClient localDbClient;
  @visibleForTesting
  final tableName = "user";
  @visibleForTesting
  final userId = "profile";

  /// Default constructor
  UserLocalDataSource({required this.localDbClient});

  Future<Either<Failure, UserEntity>> get() async {
    final jsonObj =
        await localDbClient.getById(tableName: tableName, id: userId);
    if (jsonObj == null) {
      return left(NoLocalEntityFailure(entityName: tableName, detail: ""));
    }
    try {
      return right(UserEntity.fromJson(jsonObj));
    } on Exception {
      return left(NoLocalEntityFailure(entityName: tableName, detail: ""));
    }
  }

  Future<Either<Failure, void>> put(UserEntity user) async {
    try {
      await localDbClient.putById(
          tableName: tableName, id: userId, content: user.toJson());
      return right(null);
    } on Exception {
      return left(const EmptyFailure());
    }
  }

  Future<Either<Failure, void>> delete() async {
    try {
      return right(
          await localDbClient.deleteById(tableName: tableName, id: userId));
    } on Exception {
      return left(NoLocalEntityFailure(entityName: tableName, detail: ""));
    }
  }
}
