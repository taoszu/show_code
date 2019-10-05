import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

import 'package:show_code/problem.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Show Code',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          primaryColor:Colors.grey[100],
        appBarTheme: AppBarTheme(
          elevation: 0
        )
      ),
      home: HomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class HomePage extends StatefulWidget {
  HomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<String> _problems = [];

  // 问题目录url
  final String _problemsDirUrl = "https://api.github.com/repos/taoszu/leetcode_notes/contents";

  _fetchProblems() async {
    try {
      Dio().get(_problemsDirUrl).then((response) {
        if(response != null && response.data != null) {
          List<String> problems = [];
          response.data.forEach((problem) => problems.add(problem["name"]));
          setState(() {
            _problems = problems;
          });
        }
      });
    } catch (e) {
      print(e);
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchProblems();
  }

  @override
  Widget build(BuildContext context) {
    final problemsList =
    ListView.builder(
        itemCount: _problems.length,
        itemBuilder: (BuildContext context, int index) {
          return ListTile(title: Text("${index+1}.  ${_problems[index]}"), onTap: (){
            Navigator.of(context).push(MaterialPageRoute(builder: (context) => Problem(_problems[index])));
          });
        }
    );


    return Scaffold(
        appBar: AppBar(title: Text("首页")),
        body: Container(
      child: problemsList,
    ));
  }
}
