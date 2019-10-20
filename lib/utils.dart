import 'package:show_code/type.dart';

class Utils {

  // 取出type的字符串
  // 把Type.Problem 转为 problem
  static getTypeName(Type type) {
    String typeName = type.toString().toLowerCase();
    return typeName.replaceAll("type.", "");
  }

  // 移除base64多余的\n
  static formatBase64(String base64Content) {
    return base64Content.replaceAll(RegExp(r'\n'), "");
  }

  static notEmpty(String text) {
    return text != null && text.length > 0;
  }

}