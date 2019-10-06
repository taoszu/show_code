class ParseHelper {

  static const _blockElements = [
    BlockElements.div,
    BlockElements.p,
    StyleElements.pre,
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

  static const _bgStyleElements = [
    StyleElements.code,
    StyleElements.pre,
  ];


  static isStyleElement(String tagName) {
    return _fontStyleElements.contains(tagName) || _bgStyleElements.contains(tagName);
  }

  static isFontStyleElement(String tagName) {
    return _fontStyleElements.contains(tagName);
  }

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
}


class StyleElements {
  static const strong = "strong";
  static const code = "code";
  static const pre = "pre";
  static const h1 = "h1";
  static const h2 = "h2";
  static const h3 = "h3";
  static const h4 = "h4";
  static const h5 = "h5";
  static const h6 = "h6";
}