import 'dart:math';

import 'package:balance_home_app/config/platform_utils.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';

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
      return await BoxCollection.open(
        dbName,
        tableNames,
        path: './', // Only used for Dart IO
        key: HiveAesCipher(await generateEncryptionKey()),
      );
    });
  }

  @visibleForTesting
  Future<List<int>> generateEncryptionKey() async {
    final deviceInfoPlugin = DeviceInfoPlugin();
    final platformUtils = PlatformUtils();
    String key = "";
    if (platformUtils.isWeb) {
      key = (await deviceInfoPlugin.webBrowserInfo).userAgent ?? "";
    } else if (platformUtils.isAndroid) {
      key = (await deviceInfoPlugin.androidInfo).id;
    } else if (platformUtils.isIOS) {
      key = (await deviceInfoPlugin.iosInfo).identifierForVendor ?? "";
    } else if (platformUtils.isWindows) {
      key = (await deviceInfoPlugin.windowsInfo).deviceId;
    } else if (platformUtils.isLinux) {
      key = (await deviceInfoPlugin.linuxInfo).id;
    } else if (platformUtils.isMacOS) {
      key = (await deviceInfoPlugin.macOsInfo).computerName;
    }
    if (key.isEmpty) {
      return List<int>.generate(32, (_) => Random().nextInt(50));
    } else {
      return List<int>.generate(32, (i) => key.codeUnitAt(i % key.length));
    }
  }

  Future<List<Map<String, dynamic>>> getAll({required String tableName}) async {
    final table = await (await futureCollection).openBox<Map>(tableName);
    final values = await table.getAllValues();
    return values.keys.map((key) {
      return Map<String, dynamic>.from(values[key]!);
    }).toList();
  }

  Future<Map<String, dynamic>?> getById(
      {required String tableName, required String id}) async {
    final table = await (await futureCollection).openBox<Map>(tableName);
    return Map<String, dynamic>.from((await table.get(id))!);
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
}
