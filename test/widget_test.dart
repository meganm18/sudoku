// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility that Flutter provides. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

//import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

//import 'package:suduko/main.dart';

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    /*
    // Build our app and trigger a frame.
    await tester.pumpWidget(MyApp());

    // Verify that our counter starts at 0.
    expect(find.text('0'), findsOneWidget);
    expect(find.text('1'), findsNothing);

    // Tap the '+' icon and trigger a frame.
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    // Verify that our counter has incremented.
    expect(find.text('0'), findsNothing);
    expect(find.text('1'), findsOneWidget);
*/

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


  });
}
