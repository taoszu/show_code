import 'package:hive/hive.dart';

class Store {
  static const String problem = "problem";
  static const String solution = "solution";
}

class DbInstance {
  // 单例公开访问点
  factory DbInstance() => _dbInstance();

  static DbInstance _instance;

  DbInstance._();

  static DbInstance _dbInstance() {
    if (_instance == null) {
      _instance = DbInstance._();
    }
    return _instance;
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
    Hive.openBox(storeName).then((box) {
      if(box != null) {
        box.put(key, content);
      }
    });
  }

  // [key] 问题的名字
  Future<String> _get(String storeName, String key) async {
    final box = await Hive.openBox(storeName);
    if (box != null) {
      final content = box.get(key);
      return Future(() => content);
    }
    return Future(() => null);
  }

}
