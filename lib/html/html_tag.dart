import 'package:html/dom.dart' as dom;


class HtmlTag {

  HtmlTag(this.self) {
    index = self.parentNode.children.indexOf(self);
  }

  // 当前节点
  final dom.Element self;

  // 当前节点在父节点的下标
  int index;

  // 标签
  get name => self.localName;

  get parentName => self.parent.localName;

  get realIndex => index + 1;
}

class TextTag extends HtmlTag {

  TextTag(dom.Element self):super(self) {
    text = self.text;
  }

  String text;

  get isEmpty => text == null || text.length == 0;
}

class ImgTag extends HtmlTag {

  ImgTag(dom.Element self):super(self) {
    src = self.attributes["src"];
  }

  String src;

}