import 'package:flutter/material.dart';
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart';
import 'package:show_code/html/parse_helper.dart';

class HtmlView extends StatefulWidget {
  HtmlView({@required this.data});

  final String data;

  @override
  _HtmlViewState createState() => _HtmlViewState();
}

class _HtmlViewState extends State<HtmlView> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    String html = widget.data;
    final document = parse(html);
    print(document.outerHtml);
    final children = parseElement(document.body);
    print(children);

    return Scaffold(
      appBar: AppBar(title: Text("html_view")),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(12),
      child: RichText(text: TextSpan(text: "", children: children)),
    ));
  }

  // 解析html节点信息
  List<InlineSpan> parseElement(dom.Element childElement) {
    List<InlineSpan> children = [];
    String tagName = childElement.localName;

    print(childElement.children);

    // 如果还有html标签的话 继续遍历
    // 否则就是文本内容
    if (childElement.children.length > 0) {
      childElement.nodes.forEach((node) {
        if (node is dom.Element) {
          String nodeTagName = node.localName;

          if (ParseHelper.isBlockElement(nodeTagName)) {
            final textSpans = parseElement(node);
            if (textSpans.length > 0) {
              final lastSpan = textSpans.last;
              if(lastSpan is TextSpan) {
                textSpans.last = TextSpan(text: lastSpan.text + "\n", style: lastSpan.style);
              }
            }
            children.addAll(textSpans);

          } else if (ParseHelper.isStyleElement(nodeTagName)) {
            children.addAll(parseElement(node));
          }

        } else {
          final textSpan = genTextSpanWidget(text: node.text, textStyle: TextStyle(color: Colors.black54));
          if(textSpan != null) {
             children.add(textSpan);
          }
        }
      });

    } else {
      print(childElement);
      print(tagName);
      final textSpan = genText(childElement, tagName);
      print(textSpan);
      if(textSpan != null) {
        children.add(textSpan);
      }
    }
    return children;
  }

  // 生成text
  genText(dom.Element childElement, String tagName) {
    if (childElement == null || childElement.text == null || childElement.text.length == 0) {
      return null;
    }
    return genTextSpan(childElement.text, tagName);
  }

  genTextSpan(String data, String tagName) {
    String text = data;
    if (ParseHelper.isBlockElement(tagName)) {
      text = data + "\n";
    }
    if (ParseHelper.isStyleElement(tagName)) {
      if(ParseHelper.isFontStyleElement(tagName)) {
        return genTextSpanWidget(text:text, textStyle:handleStyleElement(tagName));

      } else if(ParseHelper.isBgStyleElement(tagName)) {
        WidgetSpan blockSpan = genBlockSpanWidget(text: text);
        return blockSpan;
      }
    } else {
      return genTextSpanWidget(text: text);
    }
  }

  genBlockSpanWidget({@required String text}) {
    return WidgetSpan(child: Container(
      color: Colors.grey[200],
      child: Text(text))
    );
  }

  genTextSpanWidget({@required String text, TextStyle textStyle}) {
    if (text == null || text.trim().length == 0 ) {
      return null;
    }

    TextStyle realStyle = textStyle;
    if(realStyle == null) {
      realStyle = TextStyle(fontSize: 16, color: Colors.black54);
    }
    return TextSpan(text: text, style: textStyle);
  }


  handleStyleElement(String tagName) {
    TextStyle textStyle = TextStyle(fontSize: 16, color: Colors.black54);
    TextStyle titleStyle = handleTitleStyle(tagName);
    if(titleStyle != null) {
      return textStyle.merge(titleStyle);
    } else {
      switch (tagName) {
        case StyleElements.strong:
          return textStyle.merge(TextStyle(fontWeight: FontWeight.bold));
      }
    }
    return textStyle;
  }

  // 处理title的标签样式
  handleTitleStyle(String tagName) {
    TextStyle titleStyle = TextStyle(fontWeight: FontWeight.bold);
    switch(tagName) {
      case StyleElements.h1:
        return titleStyle.merge(TextStyle(fontSize: 36));

      case StyleElements.h2:
        return titleStyle.merge(TextStyle(fontSize: 24));

      case StyleElements.h3:
        return titleStyle.merge(TextStyle(fontSize: 21));

      case StyleElements.h4:
        return titleStyle.merge(TextStyle(fontSize: 18));

      case StyleElements.h5:
        return titleStyle.merge(TextStyle(fontSize: 16));

      case StyleElements.h6:
        return titleStyle.merge(TextStyle(fontSize: 14));
    }
  }


}
