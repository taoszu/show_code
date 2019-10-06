import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:markdown/markdown.dart' hide Text, Node;
import 'package:flutter_html/flutter_html.dart';
import 'package:html/dom.dart' as dom;
import 'package:show_code/html/html_view.dart';
import 'package:show_code/solution.dart';

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
    final problemUrl =
        "https://raw.githubusercontent.com/taoszu/leetcode_notes/master/" +
            widget.name +
            "/problem.md";
    try {
      Dio().get(problemUrl).then((response) {
        String html = markdownToHtml(response.data);
        setState(() {
          problemHtml = html;
          print(problemHtml);
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
                  String data = '''
      <pre>public class Q1_TwoSum {
	public int[] twoSum(int[] nums, int target) {
		if (null == nums || nums.length < 2)
			return null;
		//保留結果
		int[] result = new int[2];
		Map<Integer, Integer> resultMap = new Hashtable<Integer, Integer>();
		for (int i = 0; i < nums.length; i++) {
			//求差
			int differ = target - nums[i];
			//存在k，说明符合条件
			if (resultMap.containsKey(differ)) {
				int tmpResult = resultMap.get(differ);
				if (tmpResult > i) {
					//输出正确的数组下标
					result[0] = i;
					result[1] = tmpResult;
				} else {
					result[0] = tmpResult;
					result[1] = i;
				}
				return result;
			} else {
				//k-v存储
				resultMap.put(nums[i], i);
			}
		}
		return null;
	}
}</pre>
            ''';
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
