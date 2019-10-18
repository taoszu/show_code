import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:markdown/markdown.dart' hide Text, Node;
import 'package:flutter_html/flutter_html.dart';
import 'package:show_code/solution_page.dart';

import 'db/db.dart';
import 'entry/problem.dart';
import 'entry/solution.dart';
import 'dart:convert';

class ProblemPage extends StatefulWidget {
  ProblemPage(this.problem);

  final Problem problem;

  @override
  _ProblemPageState createState() => _ProblemPageState();
}

class _ProblemPageState extends State<ProblemPage> {
  String problemHtml = "";
  Solution solution;
  final dbInstance = DbInstance();
  String key = "";

  @override
  void initState() {
    super.initState();
    key = widget.problem.name;

    final newSha = widget.problem.sha;
    dbInstance.getDirSha(key).then((oldSha) {
      if (oldSha == newSha) {
        // 如果sha沒有改变 说明问题的文件夹内容没有更改
        // 不需要重新发请求 使用缓存内容既可
        _fetchProblem();
      } else {
        _fetchProblemDirSha(newSha);
      }
    });
  }

  // 拉取问题描述和答案的sha
  // 用来判断问题和答案是否更改
  _fetchProblemDirSha(String newDirSha) {
    final problemUrl =
        "https://api.github.com/repos/taoszu/leetcode_notes/contents/" +
            key;

    try {
      Dio().get(problemUrl).then((response) {
        if (!mounted) return;
        if (response != null && response.data is List) {
          response.data.forEach((item) {
            if (item["name"] == "problem.md") {
              _fetchProblemWithSha(item["sha"]);
            } else if (item["name"] == "solution.md") {
              solution = Solution(key, item["sha"]);
            }
          });
        }
      });
    } catch (e) {
      print(e);
    }
  }

  _fetchProblemWithSha(String newProblemSha) {
    dbInstance.getSha(key).then((oldSha) {
      if (newProblemSha == oldSha) {
        _fetchProblem();
      } else {
        _fetchProblemByNet();
      }
    });
  }

  // 如果有缓存则不请求
  _fetchProblem() {
    final dbInstance = DbInstance();
    dbInstance.getProblem(key).then((problemContent) {
      if (problemContent != null) {
        String problemHtml = markdownToHtml(problemContent);
        setState(() {
          this.problemHtml = problemHtml;
        });
      } else {
        _fetchProblemByNet();
      }
    });
  }

  _fetchProblemByNet() {
    final problemUrl = "https://api.github.com/repos/taoszu/leetcode_notes/contents/" +
        widget.problem.name +
        "/problem.md";

    try {
      Dio().get(problemUrl).then((response) {
        if (!mounted) return;
        final data = response.data;
        if (data != null) {
          String base64Content = data["content"].replaceAll(new RegExp(r'\n'), "");
          String problemContent = utf8.decode(base64Decode(base64Content));
          dbInstance.storeProblem(key, problemContent);
          dbInstance.storeSha(key, data["sha"]);

          String html = markdownToHtml(problemContent);
          setState(() {
            problemHtml = html;
          });
        }
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
                      builder: (context) => SolutionPage(widget.problem.name)));
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
