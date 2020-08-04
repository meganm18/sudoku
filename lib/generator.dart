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
  List<List<int>> solvedBoard;
  Set<int> unknowns;
  Set<int> knowns;
  HashMap<int, HashSet<int>> possible;

  Generator() {
    this.board = List.generate(9, (i) => List(9), growable: false);
    this.solvedBoard = List.generate(9, (i) => List(9), growable: false);
    this.unknowns = <int>{
      0, 1, 2, 3, 4, 5, 6, 7, 8, 10, 11, 12, 13, 14, 15, 16, 17, 18,
      20, 21, 22, 23, 24, 25, 26, 27, 28, 30, 31, 32, 33, 34, 35, 36, 37, 38,
      40, 41, 42, 43, 44, 45, 46, 47, 48, 50, 51, 52, 53, 54, 55, 56, 57, 58,
      60, 61, 62, 63, 64, 65, 66, 67, 68, 70, 71, 72, 73, 74, 75, 76, 77, 78,
      80, 81, 82, 83, 84, 85, 86, 87, 88
    };
    this.knowns = Set<int>();
    this.possible = HashMap<int, HashSet<int>>();
    this.givenBoard = this.makeBoard();
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
      this.board = this.makeSolvedBoard(
          this.board, this.unknowns, this.knowns, this.possible);

      // need to make a deep copy between this.board and this.solvedBoard
      for(int r = 0; r < 9; r++){
        for(int c = 0; c < 9; c++){
          this.solvedBoard[r][c] = this.board[r][c];
        }
      }

      if (solvedBoard[0][0] == null) {
        print("Error");
      }
      else {
        print("Success");
        this.solver();
        var boardError = this.isError(false);
        print("boardError: $boardError");
        if(!boardError) {
          break;
        }
      }
    }

    this.givenBoard = makeClues(this.board);
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
      var solverBoard = this.solver();
      if(solverBoard[0][0] == null){
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
          var solverBoard = this.solver();
          if (solverBoard[0][0] != null){
            return solverBoard;
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
      print("==========================================i: $i");
      for(int r1 = 0; r1 < 9; r1++){
        print("${this.board[r1][0]}   ${this.board[r1][1]}   ${this.board[r1][2]}   ${this.board[r1][3]}   ${this.board[r1][4]}   ${this.board[r1][5]}   ${this.board[r1][6]}   ${this.board[r1][7]}   ${this.board[r1][8]}     ");
      }
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

  /*
    Sees if only one square can have a possible value for the row/column/box

    @return   List of squares and the values they have to be (square, value)
              These are the newly discovered squares.
   */
  List<Tuple2<int, int>> oneLeftRowColBox() {
    List<Tuple2<int, int>> newKnowns = new List<Tuple2<int, int>>();

    // Rows and Columns
    List<Map<int, int>> rowCounts = List.generate(9, (i) => {1: 0, 2:0,
    3: 0, 4: 0, 5: 0, 6: 0, 7: 0, 8: 0, 9: 0});
    List<Map<int, int>> columnCounts = List.generate(9, (i) => {1: 0, 2:0,
      3: 0, 4: 0, 5: 0, 6: 0, 7: 0, 8: 0, 9: 0});
    List<Map<int, int>> rowOnlyOne = List.generate(9, (i) => HashMap<int, int>());
    List<HashMap<int, int>> columnOnlyOne = List.generate(9, (i) => HashMap<int, int>());
    for(var r = 0; r < 0; r++){
      for(var c = 0; c < 9; c++){
        var key = r * 10 + c;
        if(unknowns.contains(key)){
          this.possible[key].forEach((possible) {
            rowCounts[r][possible]++;
            columnCounts[c][possible]++;
            if(rowCounts[r][possible] == 1){
              rowOnlyOne[r].putIfAbsent(possible, () => key);
            }
            else if(rowOnlyOne[r][possible] == 2){
              rowOnlyOne[r].remove(possible);
            }
            if(columnCounts[c][possible] == 1){
              columnOnlyOne[c].putIfAbsent(possible, () => key);
            }
            else if(columnOnlyOne[c][possible] == 2){
              columnOnlyOne[c].remove(possible);
            }
          });
        } // if this square is unknown
      } // for column
    } // for row

    for(var i = 0; i < 9; i++){
      // if only one square can have a certain value for this row or column
      rowOnlyOne[i].forEach((possible, squareKey) {
        newKnowns.add(Tuple2<int, int>(squareKey, possible));
      });
      columnOnlyOne[i].forEach((squareKey, possible) {
        newKnowns.add(Tuple2<int, int>(squareKey, possible));
      });
    }

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
    // change returnValue to true when identifying a possible pair or triplet
    var returnValue = false;
    // key is the value of the square (1-9) for rows/columns
    // for box of 9, value index starts at 0 and goes in row-major order
    // value is all of the squares that could be in that spuare
    // for method (1) as described above
    List<HashMap<int, HashSet<int>>> rowValueCounts =
      List.generate(9, (i) => HashMap<int, HashSet<int>>());
    List<HashMap<int, HashSet<int>>> columnValueCounts =
      List.generate(9, (i) => HashMap<int, HashSet<int>>());
    List<HashMap<int, HashSet<int>>> boxValueCounts =
      List.generate(9, (i) => HashMap<int, HashSet<int>>());
    for(var i = 0; i < 9; i++) {
      rowValueCounts[i].addEntries({
        1: HashSet<int>(),
        2: HashSet<int>(),
        3: HashSet<int>(),
        4: HashSet<int>(),
        5: HashSet<int>(),
        6: HashSet<int>(),
        7: HashSet<int>(),
        8: HashSet<int>(),
        9: HashSet<int>(),
      }.entries);
      columnValueCounts[i].addEntries({
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
      boxValueCounts[i].addEntries({
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
    }

    // for Method (2) as described above
    var rowPossiblePairs = List.generate(9, (i) => List<int>());
    var rowPossibleTriples = List.generate(9, (i) => List<int>());
    var columnPossiblePairs = List.generate(9, (i) => List<int>());
    var columnPossibleTriples = List.generate(9, (i) => List<int>());
    var boxPossiblePairs = List.generate(9, (i) => List<int>());
    var boxPossibleTriples = List.generate(9, (i) => List<int>());

    for (var r = 0; r < 9; r++) { // for each row
      for (var c = 0; c < 9; c++) { // for each column
        var key = r * 10 + c;
        int boxRow = r ~/ 3;
        int boxCol = c ~/ 3;
        // box index number
        int b = boxRow * 3 + boxCol;
        if (this.possible.containsKey(key) && this.unknowns.contains(key)) {
          if (this.possible[key].length == 2) {
            rowPossiblePairs[r].add(key);
            columnPossiblePairs[c].add(key);
            boxPossiblePairs[b].add(key);
          } else if (this.possible[key].length == 3) {
            rowPossibleTriples[r].add(key);
            columnPossibleTriples[c].add(key);
            boxPossibleTriples[b].add(key);
          }
          this.possible[key].forEach((value) {
            rowValueCounts[r][value].add(key);
            columnValueCounts[c][value].add(key);
            boxValueCounts[b][value].add(key);
          });
        }
      } // for col
    } // for row

    // for Method (1)
    var rowPossiblePairValues = List.generate(9, (i) => List<int>());
    var rowPossibleTripleValues = List.generate(9, (i) => List<int>());
    var columnPossiblePairValues = List.generate(9, (i) => List<int>());
    var columnPossibleTripleValues = List.generate(9, (i) => List<int>());
    var boxPossiblePairValues = List.generate(9, (i) => List<int>());
    var boxPossibleTripleValues = List.generate(9, (i) => List<int>());
    for(var i = 0; i < 9; i++){
      for(var j = 1; j <= 9; j++){
        // rows
        if(rowValueCounts[i].length == 2){
          rowPossiblePairValues[i].add(j);
        }
        else if(rowValueCounts[i].length == 3){
          rowPossibleTripleValues[i].add(j);
        }

        // columns
        if(columnValueCounts[i].length == 2){
          columnPossiblePairValues[i].add(j);
        }
        else if(columnValueCounts[i].length == 3){
          columnPossibleTripleValues[i].add(j);
        }

        // boxes
        if(boxValueCounts[i].length == 2){
          boxPossiblePairValues[i].add(j);
        }
        else if(boxValueCounts[i].length == 3){
          boxPossibleTripleValues[i].add(j);
        }
      } // end for j
    } // end for i

    // i is row index, column index, or box index
    for(var i = 0; i < 9; i++){
      // Method (1)
      // Rows
      // Method (1) as described above for row pairs
      if(rowPossiblePairValues[i].length >= 2){
        for(var j = 0; j < (rowPossiblePairValues[i].length - 1); j++){
          for(var k = j + 1; k < rowPossiblePairValues[i].length; k++){
            // check if 2 values have the same possibles squares
            var value1 = rowPossiblePairValues[i][j];
            var value2 = rowPossiblePairValues[i][k];
            // if there are 2 overlapping squares for these values,
            // then they are a pair
            if (rowValueCounts[i][value1].intersection
                (rowValueCounts[i][value2]).length == 2){
                returnValue = true;

                // update so these 2 squares have no other possibilities but
                // these 2 values
                rowValueCounts[i][value1].forEach((element) {
                  this.possible[element].clear();
                  this.possible[element].add(value1);
                  this.possible[element].add(value2);
                });
            } // end if intersection is 2
          } // end for k
        } // end for j
      } // end if rowPossiblePairValues[i].length >= 2

      // Method (1) as described above for row triples
      if(rowPossibleTripleValues[i].length >= 2){
        for(var j = 0; j < (rowPossibleTripleValues[i].length - 2); j++){
          for(var k = j + 1; k < (rowPossibleTripleValues[i].length - 1); k++){
            for(var l = k + 1; l < rowPossibleTripleValues[i].length; l++) {
              // check if these 3 values have the same possible squares
              var value1 = rowPossibleTripleValues[i][j];
              var value2 = rowPossibleTripleValues[i][k];
              var value3 = rowPossibleTripleValues[i][l];
              // if there are 3 overlapping squares for these values,
              // then they are a triple
              if (rowValueCounts[i][value1].intersection(
                rowValueCounts[i][value2]).intersection(
                rowValueCounts[i][value3]).length == 3) {
                returnValue = true;

                // update so these 3 squares have no other possibilities than
                // these 3 values
                rowValueCounts[i][value1].forEach((element) {
                  this.possible[element].clear();
                  this.possible[element].add(value1);
                  this.possible[element].add(value2);
                  this.possible[element].add(value3);
                });
              } // end if intersection is 3
            } // for l
          } // for k
        } // for j
      } // end if rowPossibleTripleValues[i].length >= 2

      // Columns
      // Method (1) as described above for column pairs
      if(columnPossiblePairValues[i].length >= 2){
        for(var j = 0; j < (columnPossiblePairValues[i].length - 1); j++){
          for(var k = j + 1; k < columnPossiblePairValues[i].length; k++){
            // check if 2 values have the same possibles squares
            var value1 = columnPossiblePairValues[i][j];
            var value2 = columnPossiblePairValues[i][k];
            // if there are 2 overlapping squares for these values,
            // then they are a pair
            if (columnValueCounts[i][value1].intersection
              (columnValueCounts[i][value2]).length == 2){
              returnValue = true;

              // update so these 2 squares have no other possibilities but
              // these 2 values
              columnValueCounts[i][value1].forEach((element) {
                this.possible[element].clear();
                this.possible[element].add(value1);
                this.possible[element].add(value2);
              });
            } // end if intersection is 2
          } // end for k
        } // end for j
      } // end if columnPossiblePairValues[i].length >= 2

      // Method (1) as described above for column triples
      if(columnPossibleTripleValues[i].length >= 2){
        for(var j = 0; j < (columnPossibleTripleValues[i].length - 2); j++){
          for(var k = j + 1; k < (columnPossibleTripleValues[i].length - 1); k++){
            for(var l = k + 1; l < columnPossibleTripleValues[i].length; l++) {
              // check if these 3 values have the same possible squares
              var value1 = columnPossibleTripleValues[i][j];
              var value2 = columnPossibleTripleValues[i][k];
              var value3 = columnPossibleTripleValues[i][l];
              // if there are 3 overlapping squares for these values,
              // then they are a triple
              if (columnValueCounts[i][value1].intersection(
                  columnValueCounts[i][value2]).intersection(
                  columnValueCounts[i][value3]).length == 3) {
                returnValue = true;

                // update so these 3 squares have no other possibilities than
                // these 3 values
                columnValueCounts[i][value1].forEach((element) {
                  this.possible[element].clear();
                  this.possible[element].add(value1);
                  this.possible[element].add(value2);
                  this.possible[element].add(value3);
                });
              } // end if intersection is 3
            } // for l
          } // for k
        } // for j
      } // end if columnPossibleTripleValues[i].length >= 2

      // Subboxes
      // Method (1) as described above for box pairs
      if(boxPossiblePairValues[i].length >= 2){
        for(var j = 0; j < (boxPossiblePairValues[i].length - 1); j++){
          for(var k = j + 1; k < boxPossiblePairValues[i].length; k++){
            // check if 2 values have the same possibles squares
            var value1 = boxPossiblePairValues[i][j];
            var value2 = boxPossiblePairValues[i][k];
            // if there are 2 overlapping squares for these values,
            // then they are a pair
            if (boxValueCounts[i][value1].intersection
              (boxValueCounts[i][value2]).length == 2){
              returnValue = true;

              // update so these 2 squares have no other possibilities but
              // these 2 values
              boxValueCounts[i][value1].forEach((element) {
                this.possible[element].clear();
                this.possible[element].add(value1);
                this.possible[element].add(value2);
              });
            } // end if intersection is 2
          } // end for k
        } // end for j
      } // end if boxPossiblePairValues[i].length >= 2

      // Method (1) as described above for box triples
      if(boxPossibleTripleValues[i].length >= 2){
        for(var j = 0; j < (boxPossibleTripleValues[i].length - 2); j++){
          for(var k = j + 1; k < (boxPossibleTripleValues[i].length - 1); k++){
            for(var l = k + 1; l < boxPossibleTripleValues[i].length; l++) {
              // check if these 3 values have the same possible squares
              var value1 = boxPossibleTripleValues[i][j];
              var value2 = boxPossibleTripleValues[i][k];
              var value3 = boxPossibleTripleValues[i][l];
              // if there are 3 overlapping squares for these values,
              // then they are a triple
              if (boxValueCounts[i][value1].intersection(
                  boxValueCounts[i][value2]).intersection(
                  boxValueCounts[i][value3]).length == 3) {
                returnValue = true;

                // update so these 3 squares have no other possibilities than
                // these 3 values
                boxValueCounts[i][value1].forEach((element) {
                  this.possible[element].clear();
                  this.possible[element].add(value1);
                  this.possible[element].add(value2);
                  this.possible[element].add(value3);
                });
              } // end if intersection is 3
            } // for l
          } // for k
        } // for j
      } // end if boxPossibleTripleValues[i].length >= 2

      // Method (2)
      // Rows
      // Method (2) as described above (pairs)
      if (rowPossiblePairs[i].length >= 2){
        for (var j = 0; j < (rowPossiblePairs[i].length -1); j++) {
          for (var k = j + 1; k < rowPossiblePairs[i].length; k++){
            // look through 2 squares to see if pair
            var key1 = rowPossiblePairs[i][j];
            var key2 = rowPossiblePairs[i][k];

            // check intersection is see if this is a pair
            if(this.possible[key1].intersection(this.possible[key2]).length == 2){
              returnValue = true;

              // The rest of the squares should not have these as possible values
              var firstValue = this.possible[key1].toList()[0];
              var secondValue = this.possible[key2].toList()[1];
              for(var col2 = 0; col2 < 9; col2++){
                var key3 = i * 10 + col2;
                if(key3 != key1 && key3 != key2 && this.unknowns.contains(key3)){
                  this.possible[key3].remove(firstValue);
                  this.possible[key3].remove(secondValue);
                }
              }
            } // if intersection length is 2
          } // for k
        } // for j
      } // if rowPossiblePairs[i].length >= 2

      // Method (2) as described above (triples)
      if(rowPossibleTriples[i].length >= 3){
        for(var j = 0; j < (rowPossibleTriples[i].length - 2); j++) {
          for (var k = j + 1; k < (rowPossibleTriples[i].length - 1); k++){
            for( var l = k + 1; l < rowPossibleTriples[i].length; l++){
              // look through 3 squares to see if a triple
              var key1 = rowPossibleTriples[i][j];
              var key2 = rowPossibleTriples[i][k];
              var key3 = rowPossibleTriples[i][l];

              // check intersection length to see if triple
              if(this.possible[key1].intersection(
                this.possible[key2]).intersection(
                this.possible[key3]).length == 3) {
                returnValue = true;

                // the rest of the squares should not have these values as possible
                var firstValue = this.possible[key1].toList()[0];
                var secondValue = this.possible[key1].toList()[1];
                var thirdValue = this.possible[key1].toList()[2];
                for(var col2 = 0; col2 < 9; col2++){
                  var key4 = i * 10 + col2;
                  if(key4 != key1 && key4 != key2 && key4 != key3 &&
                      this.unknowns.contains(key4)){
                    this.possible[key4].remove(firstValue);
                    this.possible[key4].remove(secondValue);
                    this.possible[key4].remove(thirdValue);
                  }
                } // for each column
              } // if intersection length is 3
            } // for l
          } // for k
        } // for j
      } // if rowPossibleTriples[i].length >= 3

      // Columns
      // Method (2) as described above for column pairs
      if (columnPossiblePairs[i].length >= 2){
        for (var j = 0; j < (columnPossiblePairs[i].length -1); j++) {
          for (var k = j + 1; k < columnPossiblePairs[i].length; k++){
            // look through 2 squares to see if pair
            var key1 = columnPossiblePairs[i][j];
            var key2 = columnPossiblePairs[i][k];

            // check intersection is see if this is a pair
            if(this.possible[key1].intersection(this.possible[key2]).length == 2){
              returnValue = true;

              // The rest of the squares should not have these as possible values
              var firstValue = this.possible[key1].toList()[0];
              var secondValue = this.possible[key2].toList()[1];
              for(var row2 = 0; row2 < 9; row2++){
                var key3 = row2 * 10 + i;
                if(key3 != key1 && key3 != key2 && this.unknowns.contains(key3)){
                  this.possible[key3].remove(firstValue);
                  this.possible[key3].remove(secondValue);
                }
              }
            } // if intersection length is 2
          } // for k
        } // for j
      } // if columnPossiblePairs[i].length >= 2

      // Method (2) as described above (triples)
      if(columnPossibleTriples[i].length >= 3){
        for(var j = 0; j < (columnPossibleTriples[i].length - 2); j++) {
          for (var k = j + 1; k < (columnPossibleTriples[i].length - 1); k++){
            for( var l = k + 1; l < columnPossibleTriples[i].length; l++){
              // look through 3 squares to see if a triple
              var key1 = columnPossibleTriples[i][j];
              var key2 = columnPossibleTriples[i][k];
              var key3 = columnPossibleTriples[i][l];

              // check intersection length to see if triple
              if(this.possible[key1].intersection(
                  this.possible[key2]).intersection(
                  this.possible[key3]).length == 3) {
                returnValue = true;

                // the rest of the squares should not have these values as possible
                var firstValue = this.possible[key1].toList()[0];
                var secondValue = this.possible[key1].toList()[1];
                var thirdValue = this.possible[key1].toList()[2];
                for(var row2 = 0; row2 < 9; row2++){
                  var key4 = row2 * 10 + i;
                  if(key4 != key1 && key4 != key2 && key4 != key3 &&
                      this.unknowns.contains(key4)){
                    this.possible[key4].remove(firstValue);
                    this.possible[key4].remove(secondValue);
                    this.possible[key4].remove(thirdValue);
                  }
                } // for each column
              } // if intersection length is 3
            } // for l
          } // for k
        } // for j
      } // if columnPossibleTriples[i].length >= 3

      // Boxes
      // Method (2) as described above for box pairs
      if (boxPossiblePairs[i].length >= 2){
        for (var j = 0; j < (boxPossiblePairs[i].length -1); j++) {
          for (var k = j + 1; k < boxPossiblePairs[i].length; k++){
            // look through 2 squares to see if pair
            var key1 = boxPossiblePairs[i][j];
            var key2 = boxPossiblePairs[i][k];

            // check intersection is see if this is a pair
            if(this.possible[key1].intersection(this.possible[key2]).length == 2){
              returnValue = true;

              // The rest of the squares should not have these as possible values
              var firstValue = this.possible[key1].toList()[0];
              var secondValue = this.possible[key2].toList()[1];
              int boxRow = i ~/ 3;
              int boxCol = i % 3;
              for(var row2 = 0; row2 < 3; row2++){
                for(var col2 = 0; col2 < 3; col2++){
                  var row = boxRow * 3 + row2;
                  var col = boxCol * 3 + col2;
                  var key3 = row * 10 + col;
                  if(key3 != key1 && key3 != key2 && this.unknowns.contains(key3)) {
                    this.possible[key3].remove(firstValue);
                    this.possible[key3].remove(secondValue);
                  }
                } // for col2
              } // for row2
            } // if intersection length is 2
          } // for k
        } // for j
      } // if boxPossiblePairs[i].length >= 2

      // Method (2) as described above (triples)
      if(boxPossibleTriples[i].length >= 3){
        for(var j = 0; j < (boxPossibleTriples[i].length - 2); j++) {
          for (var k = j + 1; k < (boxPossibleTriples[i].length - 1); k++){
            for( var l = k + 1; l < boxPossibleTriples[i].length; l++){
              // look through 3 squares to see if a triple
              var key1 = boxPossibleTriples[i][j];
              var key2 = boxPossibleTriples[i][k];
              var key3 = boxPossibleTriples[i][l];

              // check intersection length to see if triple
              if(this.possible[key1].intersection(
                  this.possible[key2]).intersection(
                  this.possible[key3]).length == 3) {
                returnValue = true;

                // the rest of the squares should not have these values as possible
                var firstValue = this.possible[key1].toList()[0];
                var secondValue = this.possible[key1].toList()[1];
                var thirdValue = this.possible[key1].toList()[2];
                int boxRow = i ~/ 10;
                int boxCol = i % 10;
                for(var row2 = 0; row2 < 3; row2++){
                  for(var col2 = 0; col2 < 3; col2++){
                    var row = boxRow * 3 + row2;
                    var col = boxCol * 3 + col2;
                    var key4 = row * 10 + col;
                    if(key4 != key1 && key4 != key2 && key4 != key3 &&
                    this.unknowns.contains(key4)){
                      this.possible[key4].remove(firstValue);
                      this.possible[key4].remove(secondValue);
                      this.possible[key4].remove(thirdValue);
                    }
                  } // for each column
                } // for each row
              } // if intersection length is 3
            } // for l
          } // for k
        } // for j
      } // if boxPossibleTriples[i].length >= 3
    } // end for i
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
    // already know newKnowns doesn't have a conflict with currently set numbers
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

    @param acceptNull   true if allow null values, false otherwise
    @return             true if duplicate, false otherwise
   */
  bool isError(bool acceptNull) {
    print("is Error---------------------------------------------------");
    for(var r = 0; r < 9; r ++){
      print(" ${this.board[r][0]}   ${this.board[r][1]}   ${this.board[r][2]}   ${this.board[r][3]}   ${this.board[r][4]}   ${this.board[r][5]}   ${this.board[r][6]}   ${this.board[r][7]}   ${this.board[r][8]}  ");
    }
    var row = List.generate(9, (i) => List.generate(9, (j) => false), growable: false);
    var col = List.generate(9, (i) => List.generate(9, (j) => false), growable: false);
    var box = List.generate(9, (i) => List.generate(9, (j) => false), growable: false);

    for(var r = 0; r < 9; r++){
      for(var c = 0; c < 9; c++) {
        int val = this.board[r][c];
        if (val != null) {
          val--; //convert from value to index
          int boxr = r ~/ 3;
          int boxc = c ~/ 3;
          int boxnum = boxr * 3 + boxc;
          if (row[r][val] || col[c][val] || box[boxnum][val]) {
            return true;
          }
          row[r][val] = true;
          col[c][val] = true;
          box[boxnum][val] = true;
        }
        else if(!acceptNull){
          return true;
        }
      }
    }
    return false;
  } // isError()

}
