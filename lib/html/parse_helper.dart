class ParseHelper {

  static const _blockElements = [
    BlockElements.div,
    BlockElements.p,
    StyleElements.pre,
    BlockElements.ul,
    BlockElements.ol,
    BlockElements.li,

    StyleElements.h1,
    StyleElements.h2,
    StyleElements.h3,
    StyleElements.h4,
    StyleElements.h5,
    StyleElements.h6,
  ];

  static const _fontStyleElements = [
    StyleElements.strong,
    StyleElements.h1,
    StyleElements.h2,
    StyleElements.h3,
    StyleElements.h4,
    StyleElements.h5,
    StyleElements.h6,
  ];

  static const _decorationStyleElements = [
    StyleElements.li,
  ];

  static const _bgStyleElements = [
    StyleElements.code,
    StyleElements.pre,
  ];

  static isStyleElement(String tagName) {
    return _fontStyleElements.contains(tagName) || _bgStyleElements.contains(tagName);
  }

  static isListElement(String tagName) {
    return BlockElements.ol == tagName || BlockElements.ul == tagName;
  }

  // 字体样式的标签
  // 如 h1 h2
  static isFontStyleElement(String tagName) {
    return _fontStyleElements.contains(tagName);
  }

  // 修饰样式的标签
  // 如 li
  static isDecorationStyleElement(String tagName) {
    return _decorationStyleElements.contains(tagName);
  }

  // 背景样式的标签
  // 如 pre code等
  static isBgStyleElement(String tagName) {
    return _bgStyleElements.contains(tagName);
  }

  static isBlockElement(String tagName) {
    return _blockElements.contains(tagName);
  }

}




class BlockElements {
  static const p = "p";
  static const div = "div";

  static const ul = "ul";
  static const ol = "ol";
  static const li = "li";

  static const img = "img";
}


class StyleElements {
  static const strong = "strong";
  static const code = "code";
  static const pre = "pre";
  static const li = "li";

  static const h1 = "h1";
  static const h2 = "h2";
  static const h3 = "h3";
  static const h4 = "h4";
  static const h5 = "h5";
  static const h6 = "h6";

}