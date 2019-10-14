import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:markdown/markdown.dart' hide Text, Node;

import 'db/db.dart';
import 'html/html_view.dart';

class SolutionPage extends StatefulWidget {
  SolutionPage(this.name);

  final String name;

  @override
  _SolutionPageState createState() => _SolutionPageState();
}

class _SolutionPageState extends State<SolutionPage> {
  String solutionHtml = "";

  @override
  void initState() {
    super.initState();
    _fetchSolution();
  }

  _fetchSolution() {
    final dbInstance = DbInstance();
    dbInstance.getSolution(widget.name).then((solutionHtml) {
      if(solutionHtml != null) {
        setState(() {
          this.solutionHtml = solutionHtml;
        });
      } else {
        _fetchSolutionByNet();
      }
    });
  }

  _fetchSolutionByNet() {
    final solutionUrl =
        "https://raw.githubusercontent.com/taoszu/leetcode_notes/master/" +
            widget.name +
            "/solution.md";
    try {
      Dio().get(solutionUrl).then((response) {
        String html = markdownToHtml(response.data);
        DbInstance().storeSolution(widget.name, html);
        if (!mounted) return;

        setState(() {
          solutionHtml = html;
        });
      });
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text("答案")),
        backgroundColor: Colors.white,
        body: Padding(
            padding: EdgeInsets.all(12),
            child: HtmlView(data: solutionHtml)));
  }
}
