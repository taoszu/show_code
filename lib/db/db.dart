import 'package:hive/hive.dart';

import '../utils.dart';
import 'package:show_code/type.dart';

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

  void storeContentByType(String typeName, String name, String content) {
    _store(typeName, _appendSuffix(name, "content"), content);
  }

  Future<String> getContentByType(Type type, String name) {
    String typeName = Utils.getTypeName(type);
    return _get(typeName, _appendSuffix(name, "content"));
  }

  void storeShaByType(Type type, String name, String sha) {
    String typeName = Utils.getTypeName(type);
    _store(typeName, _appendSuffix(name, "sha"), sha);
  }

  Future<String> getShaByType(Type type, String name) {
    String typeName = Utils.getTypeName(type);
    return _get(typeName,  _appendSuffix(name, "sha"));
  }

  _appendSuffix(String name, String suffix) {
    return "${name}_$suffix";
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
