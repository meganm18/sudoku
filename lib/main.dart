import 'package:flutter/material.dart';

import 'generator.dart';

// import 'dart:async';
// import 'package:path/path.dart';
// import 'package:sqflite/sqflite.dart';

void main() {
  // testing
  Generator.makeBoard();
  Generator g = Generator();
  List<List<int>> testBoard = [
    [7, 2, null, null, 9, 6, null, null, 3],
    [null, null, null, 2, null, 5, null, null, null],
    [null, 8, null, null, null, 4, null, 2, null],
    [null, null, null, null, null, null, null, 6, null],
    [1, null, 6, 5, null, 3, 8, null, 7],
    [null, 4, null, null, null, null, null, null, null],
    [null, 3, null, 8, null, null, null, 9, null],
    [null, null, null, 7, null, 2, null, null, null],
    [2, null, null, 4, 3, null, null, 1, 8]
  ];
  g.board = testBoard;
  g.solver();
  for (var r = 0; r < 9; r ++){
    for(var c = 0; c < 9; c++){
      print("$r, $c: ${g.board[r][c]}");
    }
  }
  /*List<List<int>> testBoard = [
    [null, null, null, null, null, 4, null, 2, 8],
    [4, null, 6, null, null, null, null, null, 5],
    [1, null, null, null, 3, null, 6, null, null],
    [null, null, null, 3, null, 1, null, null, null],
    [null, 8, 7, null, null, null, 1, 4, null],
    [null, null, null, 7, null, 9, null, null, null],
    [null, null, 2, null, 1, null, null, null, 3],
    [9, null, null, null, null, null, 5, null, 7],
    [6, 7, null, 4, null, null, null, null, null]
  ];*/
  /*var newKnowns = g.onePossibleLeft();
  if(newKnowns.length > 0) {
    newKnowns.forEach((element) {
      print(element);
    });
  }
  print("________________________");
  newKnowns = g.oneLeftRowColBox();
  if(newKnowns.length > 0) {
    newKnowns.forEach((element) {
      print(element);
    });
  }
  print("________________________");
  print(g.setNewKnowns(newKnowns));
  for (var r = 0; r < 9; r ++){
    for(var c = 0; c < 9; c++){
      print("$r, $c: ${g.board[r][c]}");
    }
  }*/
  /*
  List<List<int>> testBoard = [
  [null, null, null, 1, null, 5, null, null, null],
  [1, 4, null, null, null, null, 6, 7, null],
  [null, 8, null, null, null, 2, 4, null, null],
  [null, 6, 3, null, 7, null, null, 1, null],
  [9, null, null, null, null, null, null, null, 3],
  [null, 1, null, null, 9, null, 5, 2, null],
  [null, null, 7, 2, null, null, null, 8, null],
  [null, 2, 6, null, null, null, null, 3, 5],
  [null, null, null, 4, null, 9, null, null, null]
  ];
  g.board = testBoard;
  g.solver();
  var newKnowns = g.onePossibleLeft();
  newKnowns.forEach((element) {
    print(element);
  });
  print("________________________");
  print(g.setNewKnowns(newKnowns));
  newKnowns = g.onePossibleLeft();
  newKnowns.forEach((element) {
    print(element);
  });
  print("__________________________");
  print(g.setNewKnowns(newKnowns));
  newKnowns = g.onePossibleLeft();
  newKnowns.forEach((element) {
    print(element);
  });
  print("___________________________");
  print(g.setNewKnowns(newKnowns));
  newKnowns = g.onePossibleLeft();
  newKnowns.forEach((element) {
    print(element);
  });
  print("___________________________");
  print(g.setNewKnowns(newKnowns));
  newKnowns = g.onePossibleLeft();
  newKnowns.forEach((element) {
    print(element);
  });
  print("___________________________");
  print(g.setNewKnowns(newKnowns));
  newKnowns = g.onePossibleLeft();
  newKnowns.forEach((element) {
    print(element);
  });
  print("___________________________");
  print(g.setNewKnowns(newKnowns));
  newKnowns = g.onePossibleLeft();
  newKnowns.forEach((element) {
    print(element);
  });
  print("___________________________");
  print(g.setNewKnowns(newKnowns));
  newKnowns = g.onePossibleLeft();
  newKnowns.forEach((element) {
    print(element);
  });
  print("___________________________");
  print(g.setNewKnowns(newKnowns));
  newKnowns = g.onePossibleLeft();
  newKnowns.forEach((element) {
    print(element);
  });
  print("___________________________");
  print(g.setNewKnowns(newKnowns));
  newKnowns = g.onePossibleLeft();
  newKnowns.forEach((element) {
    print(element);
  });
  print("___________________________");
  print(g.setNewKnowns(newKnowns));
  newKnowns = g.onePossibleLeft();
  newKnowns.forEach((element) {
    print(element);
  });
  print("___________________________");
  print(g.setNewKnowns(newKnowns));
  newKnowns = g.onePossibleLeft();
  newKnowns.forEach((element) {
    print(element);
  });
  print("___________________________");
  print(g.setNewKnowns(newKnowns));
  newKnowns = g.onePossibleLeft();
  newKnowns.forEach((element) {
    print(element);
  });
  print("___________________________");
  print(g.isSolved());
  for (var r = 0; r < 9; r ++){
    for(var c = 0; c < 9; c++){
      print("$r, $c: ${g.board[r][c]}");
    }
  }
   */

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.green,
        // This makes the visual density adapt to the platform that you run
        // the app on. For desktop platforms, the controls will be smaller and
        // closer together (more dense) than on mobile platforms.
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Suduko'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headline4,
            ),
            Expanded(
              child: _buildGrid(),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  Widget _buildSquare(String num) => Container(
      decoration: BoxDecoration(
        border: Border.all(width: 5, color: Colors.black26),
      ),
      alignment: Alignment(0, 0),
      child: Container(
          child:
          TextField(
             decoration: InputDecoration(
               hintText: num
             )
          )
      ));

  Widget _buildBox(int ct) => Row(children: [
        Flexible(
            child: Container(
                decoration: BoxDecoration(
                    border: Border.all(width: 5, color: Colors.black)),
                child: GridView.count(
                    crossAxisCount: 3, children: _buildSquareList(9))))
      ]);

  List<Container> _buildSquareList(int ct) => List.generate(
      9, (i) => Container(child: _buildSquare((i + 1).toString())));

  Widget _buildGrid() => Row(children: [
        Flexible(
            child: Container(
                decoration: BoxDecoration(
                    border: Border.all(width: 5, color: Colors.black)),
                child: GridView.count(
                    crossAxisCount: 3, children: _buildBoxList())))
      ]);

  List<Container> _buildBoxList() =>
      List.generate(9, (i) => Container(child: _buildBox(i)));
}
