import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:markdown/markdown.dart' hide Text, Node;
import 'package:flutter_html/flutter_html.dart';
import 'package:html/dom.dart' as dom;
import 'package:show_code/html/html_view.dart';
import 'package:show_code/solution.dart';

import 'db/db.dart';

class Problem extends StatefulWidget {
  Problem(this.name);

  final String name;

  @override
  _ProblemState createState() => _ProblemState();
}

class _ProblemState extends State<Problem> {
  String problemHtml = "";

  @override
  void initState() {
    super.initState();
    _fetchProblem();
  }

  _fetchProblem() {
    final dbInstance = DbInstance();
    dbInstance.getProblem(widget.name).then((problemHtml) {
      if(problemHtml != null) {
        setState(() {
          this.problemHtml = problemHtml;
        });
      } else {
        _fetchProblemByNet();
      }
    });
  }

  _fetchProblemByNet() {
    final problemUrl =
        "https://raw.githubusercontent.com/taoszu/leetcode_notes/master/" +
            widget.name +
            "/problem.md";
    try {
      Dio().get(problemUrl).then((response) {
        String html = markdownToHtml(response.data);
        DbInstance().storeProblem(widget.name, html);
        if (!mounted) return;

        setState(() {
          problemHtml = html;
        });
      });
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("问题"),
          actions: <Widget>[
            IconButton(
                icon: Icon(Icons.question_answer),
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => Solution(widget.name)));
                })
          ],
        ),
        body: Container(
          child: Html(
            data: problemHtml,
            padding: EdgeInsets.only(left: 12, right: 12, top: 18),
          ),
        ));
  }
}
