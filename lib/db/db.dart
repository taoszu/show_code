import 'package:flutter/foundation.dart';
import 'package:sembast/sembast.dart';

//import 'package:sembast/sembast_io.dart';
import 'package:sembast/sembast_memory.dart';

class Store {
  static const String problem = "problem";
  static const String solution = "solution";
}

class DbInstance {
  // 单例公开访问点
  factory DbInstance() => _dbInstance();

  static DbInstance _instance;
  Database _database;

  DbInstance._();

  static DbInstance _dbInstance() {
    if (_instance == null) {
      _instance = DbInstance._();
    }
    return _instance;
  }

  Future<Database> getDatabase() async {
    Database database = _instance._database;
    if (database != null) {
      return Future<Database>(() => database);
    } else {
      //web不支持io持久化
      if (kIsWeb) {
      } else {
        // database = await databaseFactoryIo.openDatabase("app.db");
      }
      database = await databaseFactoryMemoryFs.openDatabase("app.db");
      if (database is Database) {
        _instance._database = database;
        return Future<Database>(() => database);
      } else {
        return Future<Database>(() => null);
      }
    }
  }

  Future<String> getProblem(String key) async {
    return _get(Store.problem, key);
  }

  void storeProblem(String key, String content) {
    _store(Store.problem, key, content);

  }

  Future<String> getSolution(String key) async {
    return _get(Store.solution, key);
  }

  void storeSolution(String key, String content) {
    _store(Store.solution, key, content);
  }

  void _store(String storeName, String key, String content) {
    getDatabase().then((db) {
      final store = stringMapStoreFactory.store(storeName);
      store.record(key).put(db, {"content": content});
    });
  }

  // [key] 问题的名字
  Future<String> _get(String storeName, String key) async {
    Database db = await getDatabase();
    if (db != null) {
      final store = stringMapStoreFactory.store(storeName);
      final record = await store.record(key).get(db);
      if (record == null) {
        return Future(() => null);
      } else {
        return Future(() => record["content"]);
      }
    }
    return Future(() => null);
  }

}
