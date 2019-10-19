import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:markdown/markdown.dart' hide Text, Node;
import 'package:flutter_html/flutter_html.dart';
import 'package:show_code/fetcher.dart';
import 'package:show_code/solution_page.dart';
import 'package:show_code/utils.dart';

import 'db/db.dart';
import 'entry/problem.dart';
import 'entry/solution.dart';
import 'package:show_code/type.dart';

class ProblemPage extends StatefulWidget {
  ProblemPage(this.problem);

  final Problem problem;

  @override
  _ProblemPageState createState() => _ProblemPageState();
}

class _ProblemPageState extends State<ProblemPage> with Fetcher {
  String problemHtml = "";
  Solution solution;
  final dbInstance = DbInstance();
  String name = "";

  @override
  void initState() {
    super.initState();
    name = widget.problem.name;
    solution = Solution(name, null, ignoreSha: true);

    final newSha = widget.problem.sha;

    _fetchWithDirSha(newSha);
  }

  _fetchWithDirSha(String newSha) {
    dbInstance.getShaByType(Type.dir, name).then((oldSha) {
      if (oldSha == newSha) {
        // 如果sha沒有改变 说明问题的文件夹内容没有更改
        // 不需要重新发请求 使用缓存内容既可
        final result = fetch(Type.problem, name);
        _handleFetchResult(result);
      } else {
        _fetchDirSha(newSha);
      }
    });
  }

  // 拉取问题描述和答案的sha
  // 用来判断问题和答案是否更改
  _fetchDirSha(String newDirSha) {
    final dirUrl =
        "https://api.github.com/repos/taoszu/leetcode_notes/contents/" + name;

    try {
      Dio().get(dirUrl).then((response) {
        if (!mounted) return;
        if (response != null && response.data is List) {
          dbInstance.storeShaByType(Type.dir, name, newDirSha);

          response.data.forEach((item) {
            if (item["name"] == "problem.md") {
              final result = fetchWithSha(Type.problem, name, item["sha"]);
              _handleFetchResult(result);

            } else if (item["name"] == "solution.md") {
              solution = Solution(name, item["sha"], ignoreSha: false);
            }
          });
        }
      });
    } catch (e) {
      print(e);
    }
  }

  _handleFetchResult(Future<String> result) {
    result.then((content) {
      if (Utils.notEmpty(content)) {
        String html = markdownToHtml(content);
        if (mounted) {
          setState(() {
            this.problemHtml = html;
          });
        }
      }
    });
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
                      builder: (context) => SolutionPage(solution)));
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
