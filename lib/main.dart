import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:show_code/page/about_us_page.dart';
import 'package:show_code/page/problem_page.dart';

import 'db/db.dart';
import 'package:show_code/entry/problem.dart';
import 'package:show_code/type.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.

  MyApp() {
    String path = "";
    if (defaultTargetPlatform == TargetPlatform.android) {
      path = "/data/user/0/com.taoszu.show_code/app_flutter";
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      path = "/data/user/0/com.taoszu.show_code/app_flutter";
    } else {
      path = "app";
    }
    Hive.init(path);
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarBrightness: Brightness.dark));

    return MaterialApp(
      title: '算法题解',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          primaryColor: Colors.white,
          backgroundColor: Colors.white,
          scaffoldBackgroundColor: Colors.white,
          appBarTheme: AppBarTheme(
            elevation: 0,
          )),
      home: HomePage(),
      routes: {"关于我们": (context) => AboutUs()},
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Problem> _problems = [];

  // 问题目录url
  final String _problemsDirUrl =
      "https://api.github.com/repos/taoszu/leetcode_notes/contents";

  _handleResult(data) {
    if (data != null && data is List) {
      List<Problem> problems = [];
      data.forEach((problem) {
        problems.add(Problem(problem["name"], problem["sha"]));
      });
      setState(() {
        _problems = problems;
      });
    }
  }

  _fetchProblems() {
    final dbInstance = DbInstance();
    dbInstance.getListByType(Type.dir, "home").then((data) {
      _handleResult(data);
    });

    try {
      Dio().get(_problemsDirUrl).then((response) {
        if (response != null && response.data != null) {
          dbInstance.storeListByType(Type.dir, "home", response.data);
          _handleResult(response.data);
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
    Widget content;
    /*if (_problems == null || _problems.length == 0) {
      content = Container(height: 3.0, child:
      LinearProgressIndicator(
        backgroundColor: Colors.white,
        valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
      ));
    } else {
      content
    }*/
    content = ListView.builder(
        itemCount: _problems.length,
        itemBuilder: (BuildContext context, int index) {
          return ListTile(
              title: Text("${index + 1}.  ${_problems[index].name}",
                  style: TextStyle(fontSize: 16)),
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => ProblemPage(_problems[index])));
              });
        });

    return Scaffold(
        appBar: AppBar(title: Text("首页"), actions: <Widget>[_normalPopMenu()]),
        body: Container(child: content));
  }

  Widget _normalPopMenu() {
    return new PopupMenuButton<String>(
        offset: Offset(0, 40),
        icon: Icon(Icons.menu),
        itemBuilder: (BuildContext context) => <PopupMenuItem<String>>[
              new PopupMenuItem<String>(
                  height: 40,
                  value: 'about',
                  child: Row(
                    children: <Widget>[
                      Padding(
                          padding: EdgeInsets.only(right: 8),
                          child: Icon(Icons.account_circle)),
                      Text('关于我们')
                    ],
                  )),
            ],
        onSelected: (String value) {
          switch(value) {
            case "about":
              Navigator.of(context).pushNamed("关于我们");
              break;
          }
        });
  }
}
