import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:show_code/utils.dart';
import 'package:show_code/type.dart';
import 'db/db.dart';

class Fetcher {
  final dbInstance = DbInstance();

  // 先从缓存拉取，如果缓存没有
  // 则从网络拉取
  Future<String> fetch(Type type, String name) async {
    String content = await dbInstance.getContentByType(type, name);
    if (Utils.notEmpty(content)) {
      return Future(() => content);
    } else {
      return fetchFromNet(type, name);
    }
  }

  // 如果新的sha和old的sha一致 说明内容没更改
  // 不需要发起请求，否则从网络拉取
  Future<String> fetchWithSha(Type type, String name, String newSha) async {
    String oldSha = await dbInstance.getShaByType(type, name);

    if (newSha == oldSha) {
      return fetch(type, name);
    } else {
      return fetchFromNet(type, name);
    }
  }

  // 从网络拉取sha和内容
  Future<String> fetchFromNet(Type type, String name) async {
    String typeName = Utils.getTypeName(type);
    final fetchUrl =
        "https://api.github.com/repos/taoszu/leetcode_notes/contents/$name/$typeName.md";

    try {
      final response = await Dio().get(fetchUrl);
      if (response != null && response.data != null) {
        final data = response.data;
        String base64Content = Utils.formatBase64(data["content"]);
        String content = utf8.decode(base64Decode(base64Content));
        String sha = data["sha"];

        dbInstance.storeContentByType(type, name, content);
        dbInstance.storeShaByType(type, name, sha);
        return Future(() => content);
      }
    } catch (e) {
      print(e);
    }
    return Future(() => "");
  }
}
