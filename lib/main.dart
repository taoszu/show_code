import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';

import 'package:show_code/problem_page.dart';

import 'entry/problem.dart';


void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.

  MyApp() {
    Hive.init("db/app");
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarBrightness: Brightness.dark
    ));

    return MaterialApp(
      title: 'Show Code',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          primaryColor:Colors.white,
        backgroundColor: Colors.white,
          scaffoldBackgroundColor: Colors.white,
        appBarTheme: AppBarTheme(
          elevation: 0,
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
  List<Problem> _problems = [];

  // 问题目录url
  final String _problemsDirUrl = "https://api.github.com/repos/taoszu/leetcode_notes/contents";

  _fetchProblems() {
    try {
      Dio().get(_problemsDirUrl).then((response) {
        if(response != null && response.data != null) {
          List<Problem> problems = [];
          response.data.forEach((problem) => problems.add(
              Problem(problem["name"], problem["sha"])
          ));
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
          return ListTile(title: Text("${index+1}.  ${_problems[index].name}",
          style: TextStyle(fontSize: 16)), onTap: (){
            Navigator.of(context).push(MaterialPageRoute(builder: (context) => ProblemPage(_problems[index].name)));
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
