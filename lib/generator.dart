import 'dart:collection';
import 'package:tuple/tuple.dart';

/*
  QUESTIONS:
  Would it be better to keep track of # of possible #s per square too?
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

  }
}