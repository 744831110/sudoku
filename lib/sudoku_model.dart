enum SudokuCellBackgroundStatus { none, equal, tip, select, error }
enum SudokuCellNumStatus { normal, userFill, error }

class SudokuModel {
  List<List<SudokuCellModel>> datas = [];
  List<List<SudokuCellModel>> get rows => datas;
  List<List<SudokuCellModel>> columns = List.generate(9, (_) => []);
  List<List<SudokuCellModel>> blocks = List.generate(9, (_) => []);

  SudokuModel.fromString(String s) {
    int index = 0;
    List<SudokuCellModel> cellrow = [];
    while (s.length > index) {
      String ch = s.substring(index, index + 1);
      final model = SudokuCellModel(ch == "." ? 0 : int.parse(ch));
      cellrow.add(model);
      columns[index % 9].add(model);
      blocks[getBlockIndex(index ~/ 9, index % 9)].add(model);
      index += 1;
      if (index % 9 == 0) {
        datas.add(cellrow);
        cellrow = [];
      }
    }
    for (int i = 0; i < 9; i++) {
      for (int j = 0; j < 9; j++) {
        datas[i][j].candidates = getCandidate(i, j);
      }
    }
  }

  Set<int> getCandidate(int row, int col) {
    var result = {1, 2, 3, 4, 5, 6, 7, 8, 9};
    final rowValues = rows[row].map((e) => e.value).toSet();
    final colValues = columns[col].map((e) => e.value).toSet();
    final blockValues = blocks[getBlockIndex(row, col)].map((e) => e.value).toSet();
    result = result.difference(rowValues.union(colValues.union(blockValues)));
    return result;
  }

  int getBlockIndex(int row, int col) {
    return row - row % 3 + col ~/ 3;
  }
}

class SudokuCellModel {
  int value = 0;
  Set<int> userCandidates = {};
  Set<int> candidates = {};
  bool isOriginData = false;
  SudokuCellBackgroundStatus bgStatus = SudokuCellBackgroundStatus.none;
  SudokuCellNumStatus numStatus = SudokuCellNumStatus.normal;

  SudokuCellModel(this.value) {
    isOriginData = value != 0;
    if (value == 0) {
      numStatus = SudokuCellNumStatus.userFill;
    }
  }
}

class SudokuSolutionModel {
  int row;
  int col;
  int value;
  String expound;
  bool isFail;
  SudokuSolutionModel({required this.row, required this.col, required this.value, required this.expound, this.isFail = false});
  SudokuSolutionModel.fail()
      : row = -1,
        col = -1,
        value = -1,
        expound = "无法找到相应的解",
        isFail = true;
  String get describe {
    return "在$row行，$col列可以填入$value";
  }
}

  // void updateSudokuAtIndex(int index) {
  //   int r = index ~/ 9;
  //   int c = index % 9;
  // updateSudokuInRowAndColumn(r, c);
  // }

  // 更新行/列
  // void updateSudokuInRowAndColumn(int r, int c) {
  // final cellModel = datas[r][c];
  // final value = cellModel.value;
  // int b = r - r % 3 + c ~/ 3;
  // if (row[r] & (1 << value) != 0) {
  //   for (int j = 0; j < 9; j++) {
  //     final model = datas[r][j];
  //     if (model.value == value) {
  //       model.bgStatus = SudokuCellBackgroundStatus.error;
  //     }
  //   }
  // }
  // if (column[c] & (1 << value) != 0) {
  //   for (int i = 0; i < 9; i++) {
  //     final model = datas[i][c];
  //     if (model.value == value) {
  //       model.bgStatus = SudokuCellBackgroundStatus.error;
  //     }
  //   }
  // }
  // if (block[b] & (1 << value) != 0) {
  //   for (int i = 0; i < 3; i++) {
  //     for (int j = 0; j < 3; j++) {
  //       final model = datas[r - r % 3 + i][c ~/ 3 + j];
  //       if (model.value == value) {
  //         model.bgStatus = SudokuCellBackgroundStatus.error;
  //       }
  //     }
  //   }
  // }
  // }

//   void updateSudoku() {
//     for (int i = 0; i < 9; i++) {
//       for (int j = 0; j < 9; j++) {
//         updateSudokuInRowAndColumn(i, j);
//       }
//     }
//   }