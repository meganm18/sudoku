import 'dart:collection';
import 'package:tuple/tuple.dart';

/*
  QUESTIONS:
  Would it be better to keep track of # of possible #s per square too?
  Should one possible left check if 0 are possible? - Yes?
 */

class Generator {
  static void makeBoard() {
    print("hi");
  }

  static List<List<int>> solver(List<List<int>> input) {
    // map key will be 2 digit #: first represents cell's row index, second is col index
    HashMap possible = new HashMap<int, HashSet<int>>();
    var unknown = Set();
    var known = Set();
    // initialize possible #'s to be 1-9 ( can we do this above?)
    for (var i = 0; i < 9; i++) {
      for (var j = 0; j < 9; j++) {
        var key = i * 10 + j;
        if (input[i][j].isNaN) {
          var value = HashSet<int>.from([1, 2, 3, 4, 5, 6, 7, 8, 9]);
          possible[key] = value;
          unknown.add(key);
        } // if not NA
        else {
          known.add(key);
        } // else is NA
      } // for j
    } // for i
    return input; // will update but was error when included????
  } // solver

  /*
   Update possible values of the squares in the same row, column, and block
   of the recently found square.

   @param possible  map of possible values for all of the squares
   @param key       key of the recently found square (row*10 + column)
   @param value     known value of the recently found square
   @return          updated map of possible values
   */
  static HashMap<int, HashSet<int>> updatePossible(
      HashMap<int, HashSet<int>> possible, int key, int value) {
      int rowNum = key ~/ 10;
      int colNum = key % 10;
      // update row and column
      for (var i = 0; i < 9; i++){
        var rowKey = rowNum * 10 + i;
        var colKey = i * 10 + colNum;
        if (possible[rowKey] != null) {
          possible[rowKey].remove(value);
        }
        if (possible[colKey] != null){
          possible[colKey].remove(value);
        }
      }
      // update block of 9
      // find beginning of block based on relative position
      int rowIndex = rowNum % 3;
      int colIndex = colNum % 3;
      int firstRow = rowNum - rowIndex;
      int firstCol = colNum - colIndex;
      for (var r = firstRow; r <= firstRow + 2; r++) {
        for (var c = firstCol; c <= firstCol + 2; c++) {
          var blockKey = r * 10 + c;
          if (possible[blockKey] != null){
            possible[blockKey].remove(value);
          }
        }
      }

      return possible;
  }

  /*
    Iterates through the unknown squares to check if there is only 1 possible left

    @param possible   map of possible values for each square
    @param unknowns   set of squares where the correct value is unknown
    @return           list of tuples of squares and their only possible value
   */
  static List<Tuple2<int, int>> onePossibleLeft(
      HashMap<int, HashSet<int>> possible, HashSet<int> unknowns){
      List<Tuple2<int, int>> newKnowns = new List<Tuple2<int, int>>();
      unknowns.forEach((square){
        if(possible[square].isEmpty){
          // not possible to solve
          const error = const Tuple2<int, int>(99, 99);
          return [error];
        }
        else if(possible[square].length == 1){
          // must be that square's value
          newKnowns.add(Tuple2<int, int>(square, possible[square].first));
        }
      });
      return newKnowns;
  }

  /*
    Checks if any of these new values are duplicate values in the same
    row, column, or block of 9 squares

    @param newKnowns  List of new squares and their values
    @return           true if duplicate, false otherwise
   */
  static bool isNewKnownError(List<Tuple2<int, int>> newKnowns){
    if (newKnowns.length < 2){
      return false;
    }
    // list is probably small enough that it is faster to loop through
    // repeatedly as opposed to checking each row, col, and box of 9
    for(var i = 0; i < (newKnowns.length - 1); i++){
      var square = newKnowns[i].item1;
      int row = square ~/ 10;
      int col = square % 10;
      // boxes are numbered starting with 0 in row-major order
      int box = (row ~/ 3) * 3 + (col ~/ 3);
      var value = newKnowns[i].item2;
      for(var j = i; j < newKnowns.length; j++){
        if(newKnowns[j].item2 == value){
          var square2 = newKnowns[j].item1;
          int row2 = square2 ~/ 10;
          int col2 = square2 % 10;
          int box2 = (row2 ~/ 3) * 3 + (col2 ~/ 3);
          if ((row == row2) || (col == col2) || (box == box2)){
            return true;
          } // if duplicate values in row/col/group
        } // if duplicate values
      } // for j
    } // for i
   return false;
  } // isNewKnownError()

  /*
    Checks if there is a duplicate in a row/column/square of 9
    Would likely only possibly use for the starting board and
    maybe as a last check at end?

    @param board  current state of the board
    @return       true if duplicate, false otherwise
   */
  static bool isError(List<List<int>> board){
    // row
    for (var r = 0; r < 9; r++){
      var rowSet = HashSet<int>();
      for (var c = 0; c < 9; c++){
        var boardValue = board[r][c];
        if(boardValue != null){
          if(rowSet.contains(boardValue)){
            return true;
          }
          else{
            rowSet.add(boardValue);
          }
        } // if not null
      } // for col
    } // for row

    // column
    for (var c = 0; c < 9; c++){
      var columnSet = HashSet<int>();
      for (var r = 0; r < 9; r++){
        var boardValue = board[r][c];
        if(boardValue != null){
          if(columnSet.contains(boardValue)){
            return true;
          }
          else{
            columnSet.add(boardValue);
          }
        } // if not null
      } // for row
    } // for col

    // square of 9
    for(var rindex = 0; rindex < 3; rindex++){
      for(var cindex = 0; cindex < 3; cindex++){
        var groupSet = HashSet<int>();
        for(var r = 0; r < 3; r++){
          for(var c = 0; c < 3; c++){
            var row = rindex * 3 + r;
            var column = cindex * 3 + c;
            var boardValue = board[row][column];
            if(boardValue != null) {
              if (groupSet.contains(boardValue)) {
                return true;
              }
              else {
                groupSet.add(boardValue);
              }
            } // if not null
          } // for c
        } // for r
      } // for cindex
    } // for rindex

    return false;
  }

}