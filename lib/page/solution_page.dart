import 'package:flutter/material.dart';
import 'package:markdown/markdown.dart' hide Text, Node;
import 'package:show_code/db/db.dart';
import 'package:show_code/entry/solution.dart';
import 'package:show_code/fetcher.dart';
import 'package:show_code/html/html_view.dart';
import 'package:show_code/utils.dart';

import 'package:show_code/type.dart';

class SolutionPage extends StatefulWidget {
  SolutionPage(this.solution);

  final Solution solution;

  @override
  _SolutionPageState createState() => _SolutionPageState();
}

class _SolutionPageState extends State<SolutionPage> with Fetcher {
  String solutionHtml = "";
  String name = "";

  @override
  void initState() {
    super.initState();
    name = widget.solution.name;
    final newSha = widget.solution.sha;

    _fetchWithSha(newSha);
  }

  _fetchWithSha(String newSha) {
    final dbInstance = DbInstance();
    var result;
    if (widget.solution.ignoreSha) {
      result = fetch(Type.solution, name);
      _handleFetchResult(result);

    } else {
      dbInstance.getShaByType(Type.solution, name).then((oldSha) {
        if (newSha == oldSha) {
          result = fetch(Type.solution, name);
        } else {
          result = fetchWithSha(Type.solution, name, newSha);
        }
        _handleFetchResult(result);
      });
    }
  }

  _handleFetchResult(Future<String> result) {
    result.then((content) {
      if (Utils.notEmpty(content)) {
        String html = markdownToHtml(content);
        if (mounted) {
          setState(() {
            this.solutionHtml = html;
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text("答案")),
        backgroundColor: Colors.white,
        body: Padding(
            padding: EdgeInsets.all(12), child: HtmlView(data: solutionHtml)));
  }
}
