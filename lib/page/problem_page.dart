import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:markdown/markdown.dart' hide Text, Node;
import 'package:show_code/db/db.dart';
import 'package:show_code/entry/problem.dart';
import 'package:show_code/entry/solution.dart';
import 'package:show_code/fetcher.dart';
import 'package:show_code/html/html_view.dart';
import 'package:show_code/page/solution_page.dart';
import 'package:show_code/utils.dart';

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
        html = markdownToHtml('''
        

## 导航
- [Flutter学习篇(一)—— Dialog的简单使用](https://juejin.im/post/5cf236d8f265da1bc23f5fbf)
- [Flutter学习篇(二)—— Drawer和水纹按压效果](https://juejin.im/post/5cf3a503e51d4555fd20a2e2)
- [Flutter学习篇(三)—— MobX的使用和原理](https://juejin.im/post/5cf63025e51d4510a5033575)
- [Flutter学习篇(四)—— 尺寸解惑](https://juejin.im/post/5d4820ec51882560b9544d17)
- [Flutter学习篇(五)——路由剖析前篇](https://juejin.im/post/5d6dc290e51d453b5f1a04dd)
- [Flutter学习篇(六)——路由剖析终篇](https://juejin.im/post/5d9db00be51d4577fc7b1c41)

## 前言
随着Flutter1.9的正式发布，Flutter web已经合并到Flutter的主Repo, 这意味着以后只要使用同一套基准代码，就可以构建出移动端和网页端的应用，真正进入全平台时代。

## 架构
先放出两张图：

![flutter_web](https://user-gold-cdn.xitu.io/2019/10/27/16e0c932648c8554?w=1137&h=465&f=png&s=56076)

![flutter](https://user-gold-cdn.xitu.io/2019/10/27/16e0c933e482ddc3?w=815&h=449&f=png&s=38960)

分别对应flutter web和flutter的架构图，很明显，Framework层是一致的，所以对于开发者来讲，无感知，写的是同一套代码，区别在于flutter web底层是把dart代码转为js，而移动端则是使用skia引擎。

## 环境
其实对于做移动开发的技术人员，他们多多少少会很渴望拥有个人网站，但奈何web开发不精通，成本太高，而用了flutter web，将不再苦恼。   

先从环境配置开始:
```dart
 flutter channel master
 flutter upgrade
 flutter config --enable-web
 cd <into project directory>
 flutter create .
```
这个过程可能会花一些时间，具体看网速情况。

运行:
```dart
 flutter run -d chrome
```
打包
```dart
 flutter build web
```
具体可以查看[Flutter中文网](https://flutter.cn/docs/get-started/web)。

打包之后的产物如下：

![](https://user-gold-cdn.xitu.io/2019/10/28/16e12b563af9f481?w=549&h=198&f=png&s=5971)

index.html是入口，代码逻辑都编译在main.dart.js里面。

## 部署
当完成上述操作，就意味着离我们的个人网站越来越近了，打包的产物已经有了，就差部署🔨了。这时候，有人会说，部署肯定很麻烦啊，又要买服务器，又要配乱七八糟的环境，你这标题党，几分钟肯定不行🤥。  

别急别急，有个神器，叫做[Github Page](https://pages.github.com/), 是github专门给开发者提供的免费站点，我们可以在上面部署自己的网站，很多知名博主就是把自己的博客部署在github page上面。在github page部署的项目可以通过以下形式的链接访问: 
`https://username.github.io/project`，这样一来就等于拥有了服务器和域名。

我猜还是会有人起哄，说这样没办法自动化部署，太鸡肋了。🙆还有我早有准备，其实，github还有另一个神器，叫做[Github Actions](https://github.com/features/actions), 主要是提供持续集成的服务。这样一来，我们就可以实现这样一个自动化部署的流程：
```! 
 提交项目代码到github，触发github actions，执行flutter build web命令，把生成的产物部署到项目的gh_pages分支，关联gitHub page。
``` 

如此一来，我们只要专注于编写自己的个人网站，其他部署等乱七八糟的事情就交给GitHub。当然，即使有这些准备，从0开始，几分钟还是不足以打造自己的个人网站的😵，不过呢，有了[demo](https://github.com/taoszu/personal_web)就不一样了😏，欢迎大家⭐。


## 个人网站
[少年阿涛](https://taoszu.cn)

## 参考
* [Flutter官方中文网](https://flutter.cn)  
* [GitHub Actions 入门教程](http://www.ruanyifeng.com/blog/2019/09/getting-started-with-github-actions.html)

        ''');
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
          child: HtmlView(
            data: problemHtml,
          ),
        ));
  }
}
