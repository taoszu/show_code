import 'package:hive/hive.dart';

class Store {
  // 存放文件指纹信息
  static const String sha = "sha";
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

  // 获取问题目录sha
  Future<String> getDirSha(String key) async {
    return _get(Store.sha, key + "_dir");
  }


  void storeDirSha(String key, String content) {
    _store(Store.sha, key + "_dir", content);
  }

  Future<String> getSha(String key) async {
    return _get(Store.sha, key);
  }

  void storeSha(String key, String content) {
    _store(Store.sha, key, content);
  }

  void storeShaMap(Map<String, String> shaMap) {
    Hive.openBox(Store.sha).then((box) {
      if(box != null) {
        box.putAll(shaMap);
      }
    });
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
