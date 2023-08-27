import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';

class LocalDbClient {
  @visibleForTesting
  final String dbName;
  @visibleForTesting
  final Set<String> tableNames;
  @visibleForTesting
  late final Future<BoxCollection> futureCollection;

  LocalDbClient(
      {List<int>? encryptionKey,
      required this.dbName,
      required this.tableNames}) {
    futureCollection = Future.microtask(() async {
      final path =
          kIsWeb ? "./" : (await getApplicationDocumentsDirectory()).path;
      final collection = await BoxCollection.open(
        dbName,
        tableNames,
        path: path,
      );
      return collection;
    });
  }

  Future<List<Map<String, dynamic>>> getAll({required String tableName}) async {
    final table = await (await futureCollection).openBox<Map>(tableName);
    final values = await table.getAllValues();
    return values.keys.map((key) {
      return Map<String, dynamic>.from(values[key]!);
    }).toList();
  }

  Future<Map<String, dynamic>> getAllWithIds(
      {required String tableName}) async {
    final table = await (await futureCollection).openBox<Map>(tableName);
    final values = await table.getAllValues();
    return Map<String, dynamic>.from(values);
  }

  Future<Map<String, dynamic>?> getById(
      {required String tableName, required String id}) async {
    final table = await (await futureCollection).openBox<Map>(tableName);
    final element = await table.get(id);
    return (element != null) ? Map<String, dynamic>.from(element) : null;
  }

  Future<void> putById(
      {required String tableName,
      required String id,
      required Map<String, dynamic> content}) async {
    final table = await (await futureCollection).openBox<Map>(tableName);
    await table.put(id, content);
  }

  Future<void> deleteById(
      {required String tableName, required String id}) async {
    final table = await (await futureCollection).openBox<Map>(tableName);
    await table.delete(id);
  }

  Future<void> deleteAll({required String tableName}) async {
    final table = await (await futureCollection).openBox<Map>(tableName);
    await table.clear();
  }

  Future<void> clearAllTables() async {
    for (final tableName in tableNames) {
      final table = await (await futureCollection).openBox<Map>(tableName);
      await table.clear();
    }
  }
}
