import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart';
import 'package:show_code/html/html_tag.dart';
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
    if (html == null || html.isEmpty) {
      return Container();
    }

    final document = parse(html);
    final children = parseElement(document.body);

    return SingleChildScrollView(
      physics: BouncingScrollPhysics(),
      child: RichText(text: TextSpan(text: "", children: children)),
    );
  }

  // 解析html节点信息
  List<InlineSpan> parseElement(dom.Element selfElement) {
    List<InlineSpan> children = [];
    // 如果还有html标签的话 继续遍历
    // 否则就是文本内容
    if (selfElement.children.length > 0) {
      selfElement.nodes.forEach((node) {
        if (node is dom.Element) {
          String nodeTagName = node.localName;

          if (ParseHelper.isBlockElement(nodeTagName)) {

            final textSpans = parseElement(node);
            if (textSpans.length > 0) {
              final lastSpan = textSpans.last;
              if (lastSpan is TextSpan) {
                textSpans.last =
                    TextSpan(text: lastSpan.text + "\n", style: lastSpan.style);
              }
            }
            children.addAll(textSpans);
          } else if (ParseHelper.isStyleElement(nodeTagName)) {
            children.addAll(parseElement(node));
          }
        } else {

          final textSpan = genTextSpanWidget(
              text: node.text, textStyle: TextStyle(color: Colors.black54));
          if (textSpan != null) {
            children.add(textSpan);
          }
        }
      });
    } else {

      final textSpan = genTag(selfElement);
      if (textSpan != null) {
        children.add(textSpan);
      }
    }
    return children;
  }

  genTag(dom.Element selfElement) {
    String tagName = selfElement.localName ;
    switch(tagName) {
      default:
        final textTag = TextTag(selfElement);
        return genText(textTag);
    }
  }


  // 生成text
  genText(TextTag textTag) {
    if (textTag.isEmpty) {
      return null;
    }
    return genTextSpan(textTag);
  }

  genTextSpan(TextTag textTag) {
    String data = textTag.text;
    String text = data;
    String tagName = textTag.name;

    if (ParseHelper.isBlockElement(tagName)) {
      text = data + "\n";
    }
    if (ParseHelper.isStyleElement(tagName)) {
      if (ParseHelper.isFontStyleElement(tagName)) {
        return genTextSpanWidget(
            text: text, textStyle: handleStyleElement(tagName));

      } else if (ParseHelper.isBgStyleElement(tagName)) {
        // web的WidgetSpan有bug
        if (kIsWeb) {
          return genTextSpanWidget(text: text);
        } else {
          WidgetSpan blockSpan = genBlockSpanWidget(text: text);
          return blockSpan;
        }

      }
    } else if(ParseHelper.isDecorationStyleElement(tagName)) {
      print(textTag.parentName);
      if(ParseHelper.isListElement(textTag.parentName)) {
        return genUlWidget(textTag);
      }
    } else {
      return genTextSpanWidget(text: text);
    }
  }

  genUlWidget(TextTag textTag) {
    if(BlockElements.ol == textTag.parentName) {
      String liText = '   ${textTag.realIndex}.  ${textTag.text}';
      return genLiTextSpanWidget(text: liText);

    } else if(BlockElements.ul == textTag.parentName) {
      String liText = '   •  ${textTag.text}';
      return genLiTextSpanWidget(text: liText);
    }
    return null;
  }

  genLiTextSpanWidget({@required String text}) {
    if (text == null || text.trim().length == 0) {
      return null;
    }

    TextStyle realStyle = TextStyle(fontSize: 16, color: Color(0xFF333333));
    return TextSpan(text: text, style: realStyle);
  }

  genBlockSpanWidget({@required String text}) {
    return WidgetSpan(
        child: DecoratedBox(
            decoration: BoxDecoration(color: Color(0XFFF8F8F8)),
            child: SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.all(12),
              child: Text(text, style: TextStyle(
                color: Color(0xFF333333),
                height: 1.75
              )),
            )));
  }

  genTextSpanWidget({@required String text, TextStyle textStyle}) {
    if (text == null || text.trim().length == 0) {
      return null;
    }

    TextStyle realStyle = textStyle;
    if (realStyle == null) {
      realStyle = TextStyle(fontSize: 16, color: Color(0xFF333333));
    }
    return TextSpan(text: text, style: realStyle);
  }

  handleStyleElement(String tagName) {
    TextStyle textStyle = TextStyle(fontSize: 16, color: Color(0xFF333333));
    TextStyle titleStyle = handleTitleStyle(tagName);
    if (titleStyle != null) {
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
    switch (tagName) {
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
