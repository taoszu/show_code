import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:markdown/markdown.dart' hide Text, Node;

import 'html/html_view.dart';

class Solution extends StatefulWidget {
  Solution(this.name);

  final String name;

  @override
  _SolutionState createState() => _SolutionState();
}

class _SolutionState extends State<Solution> {
  String solutionHtml = "";

  @override
  void initState() {
    super.initState();
    _fetchSolution();
  }

  _fetchSolution() {
    final solutionUrl =
        "https://raw.githubusercontent.com/taoszu/leetcode_notes/master/" +
            widget.name +
            "/solution.md";
    try {
      Dio().get(solutionUrl).then((response) {
        String html = markdownToHtml(response.data);
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
