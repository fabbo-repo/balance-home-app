import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';

class LocalDbClient {
  @visibleForTesting
  final Uint8List encryptionKey;
  @visibleForTesting
  final String dbName;
  @visibleForTesting
  final Set<String> tableNames;
  @visibleForTesting
  late final Future<BoxCollection> futureCollection;

  LocalDbClient(
      {required this.encryptionKey,
      required this.dbName,
      required this.tableNames}) {
    futureCollection = BoxCollection.open(
      dbName,
      tableNames,
      path: './', // Only used for Dart IO
      key: HiveAesCipher(encryptionKey),
    );
  }

  Future<Map> getAll({required String tableName}) async {
    final table = await (await futureCollection).openBox<Map>(tableName);
    return await table.getAllValues();
  }

  Future<Map?> getById({required String tableName, required String id}) async {
    final table = await (await futureCollection).openBox<Map>(tableName);
    return await table.get(id);
  }

  Future<void> putById(
      {required String tableName,
      required String id,
      required Map content}) async {
    final table = await (await futureCollection).openBox<Map>(tableName);
    await table.put(id, content);
  }

  Future<void> deleteById(
      {required String tableName, required String id}) async {
    final table = await (await futureCollection).openBox<Map>(tableName);
    await table.delete(id);
  }
}
