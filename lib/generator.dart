import 'dart:collection';
import 'package:tuple/tuple.dart';
import 'dart:math';

/*
  QUESTIONS:
  Would it be better to keep track of # of possible #s per square too? - No?
  Should one possible left check if 0 are possible? - Yes?
  Initialize board with null or 0's? - null?
 */

class Generator {
  List<List<int>> board;
  List<List<int>> givenBoard;
  Set<int> unknowns;
  Set<int> knowns;
  HashMap<int, HashSet<int>> possible;

  Generator() {
    this.board = List.generate(9, (i) => List(9), growable: false);
    this.givenBoard = List.generate(9, (i) => List(9), growable: false);
    this.unknowns = <int>{
      0, 1, 2, 3, 4, 5, 6, 7, 8, 10, 11, 12, 13, 14, 15, 16, 17, 18,
      20, 21, 22, 23, 24, 25, 26, 27, 28, 30, 31, 32, 33, 34, 35, 36, 37, 38,
      40, 41, 42, 43, 44, 45, 46, 47, 48, 50, 51, 52, 53, 54, 55, 56, 57, 58,
      60, 61, 62, 63, 64, 65, 66, 67, 68, 70, 71, 72, 73, 74, 75, 76, 77, 78,
      80, 81, 82, 83, 84, 85, 86, 87, 88
    };
    this.knowns = Set<int>();
    this.possible = HashMap<int, HashSet<int>>();

    /*
    //for testing purposes
    var testBoard = [
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
    this.board = testBoard; */
  }

  /*
  Creates a new board (no difficulty level yet)
  @return   Returns the new (solved) board or if a problem, a board with null values
   */
  List<List<int>> makeBoard(){
    var i = 0;
    while (i < 10000) {
      i++;
      this.reset();
      var returnedBoard = this.makeSolvedBoard(
          this.board, this.unknowns, this.knowns, this.possible);
      if (returnedBoard[0][0] == null) {
        print("Error");
      }
      else {
        print("Success");
        this.solver();
        var boardError = this.isError();
        print("boardError: $boardError");
        if(!boardError) {
          break;
        }
      }
    }
  this.board = makeClues(this.board);
  return this.board;
  }

  /*
    Convert solved board into only the clues
    @return Board with clues and null for blank locations
   */
  List<List<int>> makeClues(List<List<int>> board){
    Set<int> knowns = <int>{
      0, 1, 2, 3, 4, 5, 6, 7, 8, 10, 11, 12, 13, 14, 15, 16, 17, 18,
      20, 21, 22, 23, 24, 25, 26, 27, 28, 30, 31, 32, 33, 34, 35, 36, 37, 38,
      40, 41, 42, 43, 44, 45, 46, 47, 48, 50, 51, 52, 53, 54, 55, 56, 57, 58,
      60, 61, 62, 63, 64, 65, 66, 67, 68, 70, 71, 72, 73, 74, 75, 76, 77, 78,
      80, 81, 82, 83, 84, 85, 86, 87, 88
    };
    Set<int> unknowns = {};
    Random random = new Random();
    //start with 81 possible
    int cantSolveCt = 0;
    int square = 0;
    int prior = 0;
    while(cantSolveCt < 5 && unknowns.length < 61){
      prior = square;
      square = knowns.toList()[random.nextInt(knowns.length)];
      int row = square ~/ 10;
      int col = square % 10;
      int value = board[row][col];
      unknowns.forEach((square) {
        this.board[square ~/ 10][square % 10] = null;
      });

      this.board[row][col] = null;
      var solvedBoard = this.solver();
      if(solvedBoard[0][0] == null){
        cantSolveCt++;
        this.board[row][col] = value;
        board[row][col] = value;
      }
      else{
        board[row][col] = null;
        print("just set ${this.board[row][col]}");
        print("prior ${board[prior ~/ 10][prior % 10]}");
        knowns.remove(square);
        unknowns.add(square);
      }
    }
    print("removed: ${unknowns.length}");
    unknowns.forEach((square) {
      this.board[square ~/ 10][square % 10] = null;
    });
    return board;
  }

  /*
  Recursive helper method to aid in board generation
  @return   Returns the new (solved) board or if a problem, a board with null values
   */
  List<List<int>> makeSolvedBoard(List<List<int>> board, Set<int> unknowns, Set<int> knowns,
      HashMap<int, HashSet<int>> possible){
    Random random = new Random();
    var oldPossible = possible;
    // fill an unknown square at random and update parameters
    var fillSquare = unknowns.toList()[random.nextInt(unknowns.length)];
    int row = fillSquare ~/ 10;
    int col = fillSquare % 10;
    knowns.add(fillSquare);
    unknowns.remove(fillSquare);
    while(possible[fillSquare].length > 0){
      var fillValue = possible[fillSquare].toList()
        [random.nextInt(possible[fillSquare].length)];
      board[row][col] = fillValue;
      print("fillSquare: $fillSquare and fillValue: $fillValue");
      possible = this.updatePossibleBoard(possible, fillSquare, fillValue);
      // check if this was the last unknown square
      if(unknowns.length > 0) {
        // see if solvable (minimum number of clues for it to be solvable is 17)
        if(knowns.length >= 17){
          this.board = board;
          var solvedBoard = this.solver();
          if (solvedBoard[0][0] != null){
            return solvedBoard;
          }
        }
        var copyBoard = board;
        var copyUnknowns = unknowns;
        var copyKnowns = knowns;
        var copyPossible = possible;
        var recurseBoard = makeSolvedBoard(copyBoard, copyUnknowns, copyKnowns, copyPossible);
        if (recurseBoard[0][0] != null) {
          return recurseBoard;
        }
        else{
          // need to updo updatepossible
          // need this square to be a different value
          possible = oldPossible;
          possible[fillSquare].remove(fillValue);
        }
      }
      else{
        return board;
      }
    }
    print("nope");
    return List.generate(9, (i) => List(9), growable: false);
  }

  /*
  Resets board, givenBoard, unknowns, knowns, and possible
   */
  void reset() {
    this.board = List.generate(9, (i) => List(9), growable: false);
    this.givenBoard = List.generate(9, (i) => List(9), growable: false);
    this.knowns = Set<int>();
    for (var i = 0; i < 9; i++) {
      for (var j = 0; j < 9; j++) {
        var key = i * 10 + j;
        var value = HashSet<int>.from([1, 2, 3, 4, 5, 6, 7, 8, 9]);
        this.possible[key] = value;
        this.unknowns.add(key);
      } // for j
    } // for i
  }

  List<List<int>> solver() {
    // map key will be 2 digit #: first represents cell's row index, second is col index
    //may not need beginning -- may already be like that from generation process
    for (var i = 0; i < 9; i++) {
      for (var j = 0; j < 9; j++) {
        var key = i * 10 + j;
        if (this.board[i][j] == null) {
          var value = HashSet<int>.from([1, 2, 3, 4, 5, 6, 7, 8, 9]);
          this.possible[key] = value;
          this.unknowns.add(key);
        } // if not NA
        else {
          this.knowns.add(key);
        } // else is NA
      } // for j
    } // for i

    this.knowns.forEach((key) {
      int row = key ~/ 10;
      int col = key % 10;
      int value = this.board[row][col];
      this.updatePossible(key, value);
    });
    int i = 0;
    while (!this.isSolved() && i < 10000) {
      i++;
      var newKnowns = List<Tuple2<int, int>>();
      newKnowns = this.onePossibleLeft();
      if (newKnowns.isNotEmpty) {
        if (newKnowns[0].item1 == 99) {
          //error
          return List.generate(9, (i) => List(9), growable: false);
        }
      } else {
        newKnowns = this.oneLeftRowColBox();
        if (newKnowns.isEmpty) {
          var isChanged = this.pairsAndTriplets();
          if (!isChanged) {
            // no changes so solver cannot currently find a solution
            return List.generate(9, (i) => List(9), growable: false);
          }
        }
      }
      if (newKnowns ==
          [
            Tuple2(99, 99)
          ]) {
        return List.generate(9, (i) => List(9), growable: false);
      }
      if (newKnowns.isNotEmpty) {
        if (newKnowns[0].item1 == 99) {
          return List.generate(9, (i) => List(9), growable: false);
        }
      }
      if (!this.setNewKnowns(newKnowns)) {
        return List.generate(9, (i) => List(9), growable: false);
      }
    } // end while
    if (i == 10000){
      print("i: $i");
      return List.generate(9, (i) => List(9), growable: false);
    }
    return this.board;
  } // solver()

  /*
    Check for errors and set the values of the new known squares

    @param newKnowns  List of new known squares and their values
    @return bool      false if problem in the board, true otherwise
   */
  bool setNewKnowns(List<Tuple2<int, int>> newKnowns) {
    var isNewError = isNewKnownError(newKnowns);
    if (isNewError) {
      return false;
    }
    newKnowns.forEach((known) {
      var square = known.item1;
      int row = square ~/ 10;
      int col = square % 10;
      var value = known.item2;
      this.unknowns.remove(square);
      this.knowns.add(square);
      this.board[row][col] = value;
      this.possible[square] = null;
      this.updatePossible(square, value);
    });
    return true;
  }

  /*
   Update possible values of the squares in the same row, column, and block
   of the recently found square.

   @param possible  map of possible values for all of the squares
   @param key       key of the recently found square (row*10 + column)
   @param value     known value of the recently found square
   */
  void updatePossible(int key, int value) {
    int rowNum = key ~/ 10;
    int colNum = key % 10;
    // update row and column
    for (var i = 0; i < 9; i++) {
      var rowKey = rowNum * 10 + i;
      var colKey = i * 10 + colNum;
      if (this.possible[rowKey] != null) {
        this.possible[rowKey].remove(value);
      }
      if (this.possible[colKey] != null) {
        this.possible[colKey].remove(value);
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
        if (this.possible[blockKey] != null) {
          this.possible[blockKey].remove(value);
        }
      }
    }
  } // updatePossible()

  /*
   Update possible values of the squares in the same row, column, and block
   of the recently found square but update the passed in possible map.

   @param possible  map of possible values for all of the squares
   @param key       key of the recently found square (row*10 + column)
   @param value     known value of the recently found square
   @return          updated possible map
   */
  HashMap<int, HashSet<int>> updatePossibleBoard(HashMap<int,
      HashSet<int>> possible, int key, int value) {
    int rowNum = key ~/ 10;
    int colNum = key % 10;
    // update row and column
    for (var i = 0; i < 9; i++) {
      var rowKey = rowNum * 10 + i;
      var colKey = i * 10 + colNum;
      if (possible[rowKey] != null) {
        possible[rowKey].remove(value);
      }
      if (possible[colKey] != null) {
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
        if (possible[blockKey] != null) {
          possible[blockKey].remove(value);
        }
      }
    }
    return possible;
  } // updatePossibleBoard()

  /*
    Determines if the board is solved.

    @return true if board is solved, false otherwise
   */
  bool isSolved() {
    return this.unknowns.isEmpty;
  }

  /*
    Iterates through the unknown squares to check if there is only 1 possible left

    @param possible   map of possible values for each square
    @param unknowns   set of squares where the correct value is unknown
    @return           list of tuples of squares and their only possible value
   */
  List<Tuple2<int, int>> onePossibleLeft() {
    List<Tuple2<int, int>> newKnowns = new List<Tuple2<int, int>>();
    var error = false;
    this.unknowns.forEach((square) {
      if (this.possible[square].isEmpty) {
        // not possible to solve
        print("THE ERROR IS AT SQUARE $square");
        error = true;
        //return error; // gave an error when uncommented
      } else if (this.possible[square].length == 1) {
        // must be that square's value
        newKnowns.add(Tuple2<int, int>(square, this.possible[square].first));
      }
    });
    if (error) {
      return [Tuple2<int, int>(99, 99)];
    }
    return newKnowns;
  } // onePossibleLeft()

  List<Tuple2<int, int>> oneLeftRowColBox() {
    List<Tuple2<int, int>> newKnowns = new List<Tuple2<int, int>>();

    // rows
    for (var r = 0; r < 9; r++) {
      Map<int, int> counts = {
        1: 0,
        2: 0,
        3: 0,
        4: 0,
        5: 0,
        6: 0,
        7: 0,
        8: 0,
        9: 0
      };
      var onlyOne = HashSet<int>();
      for (var c = 0; c < 9; c++) {
        int key = r * 10 + c;
        if (unknowns.contains(key)) {
          this.possible[key].forEach((possible) {
            counts[possible]++;
            if (counts[possible] == 1) {
              onlyOne.add(possible);
            } else if (onlyOne.contains(possible)) {
              onlyOne.remove(possible);
            }
          });
        }
      } // for col
      //only one square can have a certain value for this row
      if (onlyOne.isNotEmpty) {
        for (var c = 0; c < 9; c++) {
          int key = r * 10 + c;
          if (unknowns.contains(key)) {
            this.possible[key].forEach((possible) {
              if (onlyOne.contains(possible)) {
                newKnowns.add(Tuple2<int, int>(key, possible));
              }
            });
          }
        } // for col
      } // if onlyOne not empty
    } //for row

    // columns
    for (var c = 0; c < 9; c++) {
      Map<int, int> counts = {
        1: 0,
        2: 0,
        3: 0,
        4: 0,
        5: 0,
        6: 0,
        7: 0,
        8: 0,
        9: 0
      };
      var onlyOne = HashSet<int>();
      for (var r = 0; r < 9; r++) {
        int key = r * 10 + c;
        if (unknowns.contains(key)) {
          this.possible[key].forEach((possible) {
            counts[possible]++;
            if (counts[possible] == 1) {
              onlyOne.add(possible);
            } else if (onlyOne.contains(possible)) {
              onlyOne.remove(possible);
            }
          });
        }
      } // for row
      //only one square can have a certain value for this row
      if (onlyOne.isNotEmpty) {
        for (var r = 0; r < 9; r++) {
          int key = r * 10 + c;
          if (unknowns.contains(key)) {
            this.possible[key].forEach((possible) {
              if (onlyOne.contains(possible) && !newKnowns.contains(key)) {
                newKnowns.add(Tuple2<int, int>(key, possible));
              }
            });
          }
        } // for row
      } // if onlyOne not empty
    } //for column

    // for box of 9
    // boxes are numbered from 0 in row-major order
    // first 2 for loops iterate through the rows/columns of groups of 9
    // inner 2 for loops iterate through the rows/columns of that group of 9
    for (var rIndex = 0; rIndex < 3; rIndex++) {
      for (var cIndex = 0; cIndex < 3; cIndex++) {
        // can now identify a box of 9
        Map<int, int> counts = {
          1: 0,
          2: 0,
          3: 0,
          4: 0,
          5: 0,
          6: 0,
          7: 0,
          8: 0,
          9: 0
        };
        var onlyOne = HashSet<int>();
        for (var r = 0; r < 3; r++) {
          for (var c = 0; c < 3; c++) {
            var row = rIndex * 3 + r;
            var col = cIndex * 3 + c;
            var key = row * 10 + col;
            if (unknowns.contains(key)) {
              this.possible[key].forEach((possible) {
                counts[possible]++;
                if (counts[possible] == 1) {
                  onlyOne.add(possible);
                } else if (onlyOne.contains(possible)) {
                  onlyOne.remove(possible);
                }
              });
            }
          } // for c
        } // for r
        if (onlyOne.isNotEmpty) {
          for (var r = 0; r < 3; r++) {
            for (var c = 0; c < 3; c++) {
              var row = rIndex * 3 + r;
              var col = cIndex * 3 + c;
              int key = row * 10 + col;
              if (unknowns.contains(key)) {
                this.possible[key].forEach((possible) {
                  if (onlyOne.contains(possible) && !newKnowns.contains(key)) {
                    newKnowns.add(Tuple2<int, int>(key, possible));
                  }
                });
              }
            } // for c
          } // for r
        } // if onlyOne not empty
      } // for cIndex
    } // for rIndex

    return newKnowns;
  } // oneLeftRowColBox()

  /*
    Looks for pairs/triplets of cells that must be 1 of 2 or 3 values
    and updates the possibilities for the cells in rest of row/column/box
    Method (1): 2 values that are the only 2 that can be those 2 values so
    those squares should not have any other possibilities
    Method (2): 2 squares can only be those 2 values so the rest should
    not view those values as a possibility
    Replace 2 with 3 for triplets

    @return   true if it made a change to the possibilities, false otherwise
   */
  bool pairsAndTriplets() {
    var returnValue = false;
    // rows
    for (var r = 0; r < 9; r++) {
      // key is the value in square (1-9)
      // value is all of the squares that could be that value
      // for Method (1) as described above
      HashMap<int, HashSet<int>> valueCounts = HashMap<int, HashSet<int>>();
      valueCounts.addEntries({
        1: HashSet<int>(),
        2: HashSet<int>(),
        3: HashSet<int>(),
        4: HashSet<int>(),
        5: HashSet<int>(),
        6: HashSet<int>(),
        7: HashSet<int>(),
        8: HashSet<int>(),
        9: HashSet<int>()
      }.entries);
      // for Method (2) as described above
      var possiblePairs = List<int>();
      var possibleTriples = List<int>();
      for (var c = 0; c < 9; c++) {
        var key = r * 10 + c;
        if (this.possible.containsKey(key) && this.unknowns.contains(key)) {
          if (this.possible[key].length == 2) {
            possiblePairs.add(key);
          } else if (this.possible[key].length == 3) {
            possibleTriples.add(key);
          }
          this.possible[key].forEach((value) {
            if (valueCounts.containsKey(value)) {
              valueCounts[value].add(key);
            } else {
              var newSet = HashSet<int>();
              newSet.add(key);
              valueCounts[value] = newSet;
            }
          });
        }
      } // for col

      // for Method (1)
      var possiblePairValues = List<int>();
      var possibleTripleValues = List<int>();
      for (var i = 1; i < 10; i++) {
        if (valueCounts[i].length == 2) {
          possiblePairValues.add(i);
        } else if (valueCounts[i].length == 3) {
          possibleTripleValues.add(i);
        }
      }
      // Method (1) as described above
      if (possiblePairValues.length >= 2) {
        for (var i = 0; i < (possiblePairValues.length - 1); i++) {
          for (var j = i + 1; j < possiblePairValues.length; j++) {
            // if those 2 squares are the same
            var value1 = possiblePairValues[i];
            var value2 = possiblePairValues[j];
            if (valueCounts[value1].intersection(valueCounts[value2]).length ==
                2) {
              returnValue = true;
              // update so these 2 squares have no other possibilities but these 2 values
              valueCounts[value1].forEach((element) {
                this.possible[element].clear();
                this.possible[element].add(value1);
                this.possible[element].add(value2);
              });
            }
          } // for j
        } // for i
      } // if possiblePairValues.length >= 2

      // Method (1) but for triples
      if (possibleTripleValues.length >= 3) {
        for (var i = 0; i < (possibleTripleValues.length - 2); i++) {
          for (var j = i + 1; j < (possibleTripleValues.length - 1); j++) {
            for (var k = j + 1; k < possibleTripleValues.length; k++) {
              // if those 3 squares are the same
              var value1 = possibleTripleValues[i];
              var value2 = possibleTripleValues[j];
              var value3 = possibleTripleValues[k];
              if (valueCounts[value1]
                      .intersection(
                          valueCounts[value2].intersection(valueCounts[value3]))
                      .length ==
                  3) {
                returnValue = true;
                // update so these 2 squares have no other possibilities but these 2 values
                valueCounts[value1].forEach((element) {
                  this.possible[element].clear();
                  this.possible[element].add(value1);
                  this.possible[element].add(value2);
                });
              }
            } // for k
          } // for j
        } // for i
      } // if possibleTripleValues.length >= 3

      // Method (2) as described above (pairs)
      if (possiblePairs.length >= 2) {
        for (var i = 0; i < (possiblePairs.length - 1); i++) {
          for (var j = i + 1; j < possiblePairs.length; j++) {
            var key1 = possiblePairs[i];
            var key2 = possiblePairs[j];
            // if there is a pair
            if (this.possible[key1].intersection(this.possible[key2]).length ==
                2) {
              returnValue = true;
              // the rest of the squares should not have these as possible
              var firstValue = this.possible[key1].toList()[0];
              var secondValue = this.possible[key2].toList()[1];
              for (var col2 = 0; col2 < 9; col2++) {
                var key = r * 10 + col2;
                if (key != key1 && key != key2 && this.unknowns.contains(key)) {
                  this.possible[key].remove(firstValue);
                  this.possible[key].remove(secondValue);
                }
              }
            } // if there is a complete overlap
          } // for j
        } // for i
      } // if possiblePairs.length >= 2

      // Method (2) as described above but for triplets
      if (possibleTriples.length >= 3) {
        for (var i = 0; i < (possibleTriples.length - 2); i++) {
          for (var j = i + 1; j < (possibleTriples.length - 1); j++) {
            for (var k = j + 1; k < possibleTriples.length; k++) {
              var key1 = possibleTriples[i];
              var key2 = possibleTriples[j];
              var key3 = possibleTriples[k];
              // if there is a pair
              if (this
                      .possible[key1]
                      .intersection(this.possible[key2])
                      .intersection(this.possible[key3])
                      .length ==
                  3) {
                returnValue = true;
                // the rest of the squares should not have these as possible
                var firstValue = this.possible[key1].toList()[0];
                var secondValue = this.possible[key2].toList()[1];
                var thirdValue = this.possible[key3].toList()[2];
                for (var col2 = 0; col2 < 9; col2++) {
                  var key = r * 10 + col2;
                  if (key != key1 &&
                      key != key2 &&
                      key != key3 &&
                      this.unknowns.contains(key)) {
                    this.possible[key].remove(firstValue);
                    this.possible[key].remove(secondValue);
                    this.possible[key].remove(thirdValue);
                  }
                }
              } // if the 3 completely overlap
            } // for k
          } // for j
        } // for i
      } // if possibleTriples.length >= 3

    } // for row

    //////////////////////////////////////////////////////////////////////////
    // Columns
    for (var c = 0; c < 9; c++) {
      // key is the value in square (1-9)
      // value is all of the squares that could be that value
      // for Method (1) as described above
      HashMap<int, HashSet<int>> valueCounts = HashMap<int, HashSet<int>>();
      valueCounts.addEntries({
        1: HashSet<int>(),
        2: HashSet<int>(),
        3: HashSet<int>(),
        4: HashSet<int>(),
        5: HashSet<int>(),
        6: HashSet<int>(),
        7: HashSet<int>(),
        8: HashSet<int>(),
        9: HashSet<int>()
      }.entries);
      // for Method (2) as described above
      var possiblePairs = List<int>();
      var possibleTriples = List<int>();
      for (var r = 0; r < 9; r++) {
        var key = r * 10 + c;
        if (this.possible.containsKey(key) && this.unknowns.contains(key)) {
          if (this.possible[key].length == 2) {
            possiblePairs.add(key);
          } else if (this.possible[key].length == 3) {
            possibleTriples.add(key);
          }
          this.possible[key].forEach((value) {
            if (valueCounts.containsKey(value)) {
              valueCounts[value].add(key);
            } else {
              var newSet = HashSet<int>();
              newSet.add(key);
              valueCounts[value] = newSet;
            }
          });
        }
      } // for row

      // for Method (1)
      var possiblePairValues = List<int>();
      var possibleTripleValues = List<int>();
      for (var i = 1; i < 10; i++) {
        if (valueCounts[i].length == 2) {
          possiblePairValues.add(i);
        } else if (valueCounts[i].length == 3) {
          possibleTripleValues.add(i);
        }
      }
      // Method (1) as described above
      if (possiblePairValues.length >= 2) {
        for (var i = 0; i < (possiblePairValues.length - 1); i++) {
          for (var j = i + 1; j < possiblePairValues.length; j++) {
            // if those 2 squares are the same
            var value1 = possiblePairValues[i];
            var value2 = possiblePairValues[j];
            if (valueCounts[value1].intersection(valueCounts[value2]).length ==
                2) {
              returnValue = true;
              // update so these 2 squares have no other possibilities but these 2 values
              valueCounts[value1].forEach((element) {
                this.possible[element].clear();
                this.possible[element].add(value1);
                this.possible[element].add(value2);
              });
            }
          } // for j
        } // for i
      } // if possiblePairValues.length >= 2

      // Method (1) but for triples
      if (possibleTripleValues.length >= 3) {
        for (var i = 0; i < (possibleTripleValues.length - 2); i++) {
          for (var j = i + 1; j < (possibleTripleValues.length - 1); j++) {
            for (var k = j + 1; k < possibleTripleValues.length; k++) {
              // if those 3 squares are the same
              var value1 = possibleTripleValues[i];
              var value2 = possibleTripleValues[j];
              var value3 = possibleTripleValues[k];
              if (valueCounts[value1]
                      .intersection(
                          valueCounts[value2].intersection(valueCounts[value3]))
                      .length ==
                  3) {
                returnValue = true;
                // update so these 2 squares have no other possibilities but these 2 values
                valueCounts[value1].forEach((element) {
                  this.possible[element].clear();
                  this.possible[element].add(value1);
                  this.possible[element].add(value2);
                });
              }
            } // for k
          } // for j
        } // for i
      } // if possibleTripleValues.length >= 3

      // Method (2) as described above (pairs)
      if (possiblePairs.length >= 2) {
        for (var i = 0; i < (possiblePairs.length - 1); i++) {
          for (var j = i + 1; j < possiblePairs.length; j++) {
            var key1 = possiblePairs[i];
            var key2 = possiblePairs[j];
            // if there is a pair
            if (this.possible[key1].intersection(this.possible[key2]).length ==
                2) {
              returnValue = true;
              // the rest of the squares should not have these as possible
              var firstValue = this.possible[key1].toList()[0];
              var secondValue = this.possible[key2].toList()[1];
              for (var row2 = 0; row2 < 9; row2++) {
                var key = row2 * 10 + c;
                if (key != key1 && key != key2 && this.unknowns.contains(key)) {
                  this.possible[key].remove(firstValue);
                  this.possible[key].remove(secondValue);
                }
              }
            } // if there is a complete overlap
          } // for j
        } // for i
      } // if possiblePairs.length >= 2

      // Method (2) as described above but for triplets
      if (possibleTriples.length >= 3) {
        for (var i = 0; i < (possibleTriples.length - 2); i++) {
          for (var j = i + 1; j < (possibleTriples.length - 1); j++) {
            for (var k = j + 1; k < possibleTriples.length; k++) {
              var key1 = possibleTriples[i];
              var key2 = possibleTriples[j];
              var key3 = possibleTriples[k];
              // if there is a pair
              if (this
                      .possible[key1]
                      .intersection(this.possible[key2])
                      .intersection(this.possible[key3])
                      .length ==
                  3) {
                returnValue = true;
                // the rest of the squares should not have these as possible
                var firstValue = this.possible[key1].toList()[0];
                var secondValue = this.possible[key2].toList()[1];
                var thirdValue = this.possible[key3].toList()[2];
                for (var row2 = 0; row2 < 9; row2++) {
                  var key = row2 * 10 + c;
                  if (key != key1 &&
                      key != key2 &&
                      key != key3 &&
                      this.unknowns.contains(key)) {
                    this.possible[key].remove(firstValue);
                    this.possible[key].remove(secondValue);
                    this.possible[key].remove(thirdValue);
                  }
                }
              } // if there is a complete overlap
            } // for k
          } // for j
        } // for i
      } // if possibleTriples.length >= 3
    } // for each column

    ///////////////////////////////////////////////////////////////////////////
    // for each box of 9
    // boxes are indexed started at 0 and labeled in row-major order
    // rowIndex and colIndex are for row and column index of the box
    // r and c refer to row and column index within each box
    for (var rowIndex = 0; rowIndex < 3; rowIndex++) {
      for (var colIndex = 0; colIndex < 3; colIndex++) {
        // for Method (1) as described above
        HashMap<int, HashSet<int>> valueCounts = HashMap<int, HashSet<int>>();
        valueCounts.addEntries({
          1: HashSet<int>(),
          2: HashSet<int>(),
          3: HashSet<int>(),
          4: HashSet<int>(),
          5: HashSet<int>(),
          6: HashSet<int>(),
          7: HashSet<int>(),
          8: HashSet<int>(),
          9: HashSet<int>()
        }.entries);
        // for Method (2) as described above
        var possiblePairs = List<int>();
        var possibleTriples = List<int>();

        for (var r = 0; r < 3; r++) {
          for (var c = 0; c < 3; c++) {
            var row = rowIndex * 3 + r;
            var col = colIndex * 3 + c;
            var key = row * 10 + col;
            if (this.possible.containsKey(key) && this.unknowns.contains(key)) {
              if (this.possible[key].length == 2) {
                possiblePairs.add(key);
              } else if (this.possible[key].length == 3) {
                possibleTriples.add(key);
              }
              this.possible[key].forEach((value) {
                if (valueCounts.containsKey(value)) {
                  valueCounts[value].add(key);
                } else {
                  var newSet = HashSet<int>();
                  newSet.add(key);
                  valueCounts[value] = newSet;
                }
              });
            }
          } // for c
        } // for r

        // for Method (1)
        var possiblePairValues = List<int>();
        var possibleTripleValues = List<int>();
        for (var i = 1; i < 10; i++) {
          if (valueCounts[i].length == 2) {
            possiblePairValues.add(i);
          } else if (valueCounts[i].length == 3) {
            possibleTripleValues.add(i);
          }
        }
        // Method (1) as described above
        if (possiblePairValues.length >= 2) {
          for (var i = 0; i < (possiblePairValues.length - 1); i++) {
            for (var j = i + 1; j < possiblePairValues.length; j++) {
              // if those 2 squares are the same
              var value1 = possiblePairValues[i];
              var value2 = possiblePairValues[j];
              if (valueCounts[value1]
                      .intersection(valueCounts[value2])
                      .length ==
                  2) {
                returnValue = true;
                // update so these 2 squares have no other possibilities but these 2 values
                valueCounts[value1].forEach((element) {
                  this.possible[element].clear();
                  this.possible[element].add(value1);
                  this.possible[element].add(value2);
                });
              }
            } // for j
          } // for i
        } // if possiblePairValues.length >= 2

        // Method (1) but for triples
        if (possibleTripleValues.length >= 3) {
          for (var i = 0; i < (possibleTripleValues.length - 2); i++) {
            for (var j = i + 1; j < (possibleTripleValues.length - 1); j++) {
              for (var k = j + 1; k < possibleTripleValues.length; k++) {
                // if those 3 squares are the same
                var value1 = possibleTripleValues[i];
                var value2 = possibleTripleValues[j];
                var value3 = possibleTripleValues[k];
                if (valueCounts[value1]
                        .intersection(valueCounts[value2]
                            .intersection(valueCounts[value3]))
                        .length ==
                    3) {
                  returnValue = true;
                  // update so these 2 squares have no other possibilities but these 2 values
                  valueCounts[value1].forEach((element) {
                    this.possible[element].clear();
                    this.possible[element].add(value1);
                    this.possible[element].add(value2);
                  });
                }
              } // for k
            } // for j
          } // for i
        } // if possibleTripleValues.length >= 3

        // Method (2) as described above (pairs)
        if (possiblePairs.length >= 2) {
          for (var i = 0; i < (possiblePairs.length - 1); i++) {
            for (var j = i + 1; j < possiblePairs.length; j++) {
              var key1 = possiblePairs[i];
              var key2 = possiblePairs[j];
              // if there is a pair
              if (this
                      .possible[key1]
                      .intersection(this.possible[key2])
                      .length ==
                  2) {
                returnValue = true;
                // the rest of the squares should not have these as possible
                var firstValue = this.possible[key1].toList()[0];
                var secondValue = this.possible[key2].toList()[1];
                for (var row2 = 0; row2 < 9; row2++) {
                  for (var col2 = 0; col2 < 3; col2++) {
                    var row = rowIndex * 3 + row2;
                    var col = colIndex * 3 + col2;
                    var key = row * 10 + col;
                    if (key != key1 &&
                        key != key2 &&
                        this.unknowns.contains(key)) {
                      this.possible[key].remove(firstValue);
                      this.possible[key].remove(secondValue);
                    }
                  } // for col2
                } // for row2
              } // if there is a complete overlap
            } // for j
          } // for i
        } // if possiblePairs.length >= 2

        // Method (2) as described above but for triplets
        if (possibleTriples.length >= 3) {
          for (var i = 0; i < (possibleTriples.length - 2); i++) {
            for (var j = i + 1; j < (possibleTriples.length - 1); j++) {
              for (var k = j + 1; k < possibleTriples.length; k++) {
                var key1 = possibleTriples[i];
                var key2 = possibleTriples[j];
                var key3 = possibleTriples[k];
                // if there is a pair
                if (this
                        .possible[key1]
                        .intersection(this.possible[key2])
                        .intersection(this.possible[key3])
                        .length ==
                    3) {
                  returnValue = true;
                  // the rest of the squares should not have these as possible
                  var firstValue = this.possible[key1].toList()[0];
                  var secondValue = this.possible[key2].toList()[1];
                  var thirdValue = this.possible[key3].toList()[2];
                  for (var row2 = 0; row2 < 9; row2++) {
                    for (var col2 = 0; col2 < 3; col2++) {
                      var row = rowIndex * 3 + row2;
                      var col = colIndex * 3 + col2;
                      var key = row * 10 + col;
                      if (key != key1 &&
                          key != key2 &&
                          key != key3 &&
                          this.unknowns.contains(key)) {
                        this.possible[key].remove(firstValue);
                        this.possible[key].remove(secondValue);
                        this.possible[key].remove(thirdValue);
                      }
                    }
                  }
                } // if there is a complete overlap
              } // for k
            } // for j
          } // for i
        } // if possibleTriples.length >= 3
      } // for colIndex
    } // for rowIndex

    return returnValue;
  }

  /*
    Checks if any of these new values are duplicate values in the same
    row, column, or block of 9 squares

    @param newKnowns  List of new known squares and their values
    @return           true if duplicate, false otherwise
   */
  bool isNewKnownError(List<Tuple2<int, int>> newKnowns) {
    if (newKnowns.length < 2) {
      return false;
    }
    // list is probably small enough that it is faster to loop through
    // repeatedly as opposed to checking each row, col, and box of 9
    for (var i = 0; i < (newKnowns.length - 1); i++) {
      var square = newKnowns[i].item1;
      int row = square ~/ 10;
      int col = square % 10;
      // boxes are numbered starting with 0 in row-major order
      int box = (row ~/ 3) * 3 + (col ~/ 3);
      var value = newKnowns[i].item2;
      for (var j = i + 1; j < newKnowns.length; j++) {
        if (newKnowns[j].item2 == value) {
          var square2 = newKnowns[j].item1;
          int row2 = square2 ~/ 10;
          int col2 = square2 % 10;
          int box2 = (row2 ~/ 3) * 3 + (col2 ~/ 3);
          if (((row == row2) || (col == col2) || (box == box2)) &&
              square != square2) {
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
  bool isError() {
    // row
    for (var r = 0; r < 9; r++) {
      var rowSet = HashSet<int>();
      for (var c = 0; c < 9; c++) {
        var boardValue = this.board[r][c];
        if (boardValue != null) {
          if (rowSet.contains(boardValue)) {
            return true;
          } else {
            rowSet.add(boardValue);
          }
        } // if not null
      } // for col
    } // for row

    // column
    for (var c = 0; c < 9; c++) {
      var columnSet = HashSet<int>();
      for (var r = 0; r < 9; r++) {
        var boardValue = this.board[r][c];
        if (boardValue != null) {
          if (columnSet.contains(boardValue)) {
            return true;
          } else {
            columnSet.add(boardValue);
          }
        } // if not null
      } // for row
    } // for col

    // square of 9
    for (var rindex = 0; rindex < 3; rindex++) {
      for (var cindex = 0; cindex < 3; cindex++) {
        var groupSet = HashSet<int>();
        for (var r = 0; r < 3; r++) {
          for (var c = 0; c < 3; c++) {
            var row = rindex * 3 + r;
            var column = cindex * 3 + c;
            var boardValue = this.board[row][column];
            if (boardValue != null) {
              if (groupSet.contains(boardValue)) {
                return true;
              } else {
                groupSet.add(boardValue);
              }
            } // if not null
          } // for c
        } // for r
      } // for cindex
    } // for rindex

    return false;
  } // isError()

}
