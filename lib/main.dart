import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'generator.dart';

// import 'dart:async';
// import 'package:path/path.dart';
// import 'package:sqflite/sqflite.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  final textFieldController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.green,
        // This makes the visual density adapt to the platform that you run
        // the app on. For desktop platforms, the controls will be smaller and
        // closer together (more dense) than on mobile platforms.
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Sudoku'),
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
  Generator _generator = Generator();
  final _formKey = new GlobalKey<FormState>();

  void _solveBoard() {
    setState(() {
      _counter++;
      _generator.board = _generator.solvedBoard;
      _formKey.currentState.reset();
      _buildGrid();
    });
  }

  void _makeBoard(){
    setState(() {
      _counter++;
      _generator.board = _generator.makeBoard();
      _formKey.currentState.reset();
      _buildGrid();
    });
  }

  /*void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }*/

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
              '$_counter',
              style: Theme.of(context).textTheme.headline4,
            ),
            Expanded(
              child: Form(
                key: _formKey,
                child: _buildGrid(),
              )
            ),
      ],),),
         floatingActionButton: Row(
        children: <Widget>[
          Spacer(),
            FloatingActionButton(
                heroTag: null,
                backgroundColor: Colors.amber,
                onPressed: _makeBoard,
                tooltip: 'Increment',
                child: Text("Make"),
            ),
             FloatingActionButton(
                heroTag: null,
                backgroundColor: Colors.amber,
                onPressed: _solveBoard,
                tooltip: 'Increment',
                child: Text("Solve"),
            ),
          ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
      /*floatingActionButton: FloatingActionButton(
        onPressed: _solveBoard,
        tooltip: 'Increment',
        child: Text("Solve"),
      ),*/ // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  /*
    Converts the number the square has (box # and where within the box)
    to the starting value in the grid (based on key based on row and column overall)
   */
  String squareNumToValue(int num) {
    int box = num ~/ 10;
    int boxRow = box ~/ 3;
    int boxCol = box % 3;

    int within = num % 10;
    int withinRow = within ~/ 3;
    int withinCol = within % 3;

    int row = boxRow * 3 + withinRow;
    int col = boxCol * 3 + withinCol;
    int value = _generator.board[row][col];
    if(value == null){
      return " ";
    }
    return value.toString();
  }

  /*
    Returns whether the square is a given clue (true) or not (false)
    Used for differentiating color when displaying a board after the user
    presses Solve
   */
  bool isSquareGiven(int num) {
    int box = num ~/ 10;
    int boxRow = box ~/ 3;
    int boxCol = box % 3;

    int within = num % 10;
    int withinRow = within ~/ 3;
    int withinCol = within % 3;

    int row = boxRow * 3 + withinRow;
    int col = boxCol * 3 + withinCol;
    int value = _generator.givenBoard[row][col];
    if(value == null){
      return false;
    }
    return true;
  }

  Widget _buildSquare(int num) {
    Widget child;
    String value = squareNumToValue(num);
    if (value == " ") {
      child = new TextFormField(
        textAlign: TextAlign.center,
        style: TextStyle(fontWeight: FontWeight.bold),
        keyboardType: TextInputType.number,
        inputFormatters: <TextInputFormatter>[
          WhitelistingTextInputFormatter.digitsOnly
        ],
      );
    }
    else {
      if(isSquareGiven(num)){
        child = Text(
          value,
          style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
        );}

      else {
        child = new TextFormField(
          textAlign: TextAlign.center,
          style: TextStyle(fontWeight: FontWeight.bold),
          decoration: InputDecoration(hintText: value,),
          keyboardType: TextInputType.number,
          inputFormatters: <TextInputFormatter>[
            WhitelistingTextInputFormatter.digitsOnly
          ],
        );
      }
    }
    return Container(
        decoration: BoxDecoration(
          border: Border.all(width: 5, color: Colors.black26),
        ),
        alignment: Alignment(0, 0),
        child: Container(
            child: child));
  }

    List<Container> _buildSquareList(int ct) =>
        List.generate(9, (i) => Container(child: _buildSquare((ct * 10 + i))));

    Widget _buildBox(int ct) =>
        Row(children: [
          Flexible(
              child: Container(
                  decoration: BoxDecoration(
                      border: Border.all(width: 5, color: Colors.black)),
                  child: GridView.count(
                      crossAxisCount: 3, children: _buildSquareList(ct))))
        ]);

    List<Container> _buildBoxList() =>
        List.generate(9, (i) => Container(child: _buildBox(i)));

    Widget _buildGrid() =>
        Row(children: [
          Flexible(
              child: Container(
                  decoration: BoxDecoration(
                      border: Border.all(width: 5, color: Colors.black)),
                  // couldn't figure out how to change input with GridView.count()
                  child: GridView.count(
                      crossAxisCount: 3, children: _buildBoxList())))
        ]);

}
