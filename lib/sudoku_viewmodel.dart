import 'package:sudoku/sudoku_datasource.dart';
import 'package:sudoku/sudoku_model.dart';
import 'package:sudoku/sudoku_num_view.dart';
import 'package:collection/collection.dart';

class SudokuDataViewModel {
  List<String> datas = [];
  SudokuModel? currentModel;
  int currentIndex = -1;
  Future<List<String>> _requestNetworkData() async {
    List<String> list = await SudokuDataSource.requestMagictourData();
    return list;
  }

  Future<void> swtichSudokuWithIndex(int index) async {
    if (datas.isEmpty) {
      datas = await _requestNetworkData();
    }
    if (index < datas.length) {
      currentModel = SudokuModel.fromString(datas[index]);
      currentIndex = index;
    }
  }
}

class SudokuViewModel {
  SudokuModel? currentModel;
  SudokuSolution? solution;

  int currentSelectIndex = 0;

  int get currentSelectRow {
    return currentSelectIndex ~/ 9;
  }

  int get currentSelectColumn {
    return currentSelectIndex % 9;
  }

  SudokuCellModel get currentCellModel {
    if (currentModel == null) {
      return SudokuCellModel(0);
    }
    return currentModel!.datas[currentSelectRow][currentSelectColumn];
  }

  List<SudokuNumStatus> get selectNumStatus {
    if (currentModel == null) {
      return List.filled(9, SudokuNumStatus.normal);
    }
    if (currentCellModel.isOriginData) {
      return List.filled(9, SudokuNumStatus.normal);
    }
    List<SudokuNumStatus> status = List.filled(9, SudokuNumStatus.normal);
    if (currentCellModel.value != 0) {
      status[currentCellModel.value - 1] = SudokuNumStatus.select;
    } else {
      for (int candidate in currentCellModel.userCandidates) {
        status[candidate - 1] = SudokuNumStatus.candidate;
      }
    }
    return status;
  }

  void selectCellModel(int row, int col) {
    currentSelectIndex = 9 * row + col;
    updateSudokuStatus();
  }

  void updateSudokuStatus() {
    updateCurrentCellBgStatus();
    checkAllError();
  }

  void updateCurrentCellBgStatus() {
    if (currentModel == null) {
      return;
    }
    for (int i = 0; i < currentModel!.datas.length; i++) {
      for (int j = 0; j < currentModel!.datas.length; j++) {
        final cellModel = currentModel!.datas[i][j];
        cellModel.bgStatus = SudokuCellBackgroundStatus.none;
        if (i == currentSelectRow) {
          cellModel.bgStatus = SudokuCellBackgroundStatus.tip;
        }
        if (j == currentSelectColumn) {
          cellModel.bgStatus = SudokuCellBackgroundStatus.tip;
        }
        int iIndex = currentSelectRow ~/ 3;
        int jIndex = currentSelectColumn ~/ 3;
        if (i >= iIndex * 3 && i < iIndex * 3 + 3 && j >= jIndex * 3 && j < jIndex * 3 + 3) {
          cellModel.bgStatus = SudokuCellBackgroundStatus.tip;
        }
        if (currentCellModel.value != 0 && cellModel.value == currentCellModel.value) {
          cellModel.bgStatus = SudokuCellBackgroundStatus.equal;
        }
        if (currentSelectRow == i && currentSelectColumn == j) {
          cellModel.bgStatus = SudokuCellBackgroundStatus.select;
        }
      }
    }
  }

  void checkAllError() {
    checkError(currentModel!.rows);
    checkError(currentModel!.columns);
    checkError(currentModel!.blocks);
  }

  void checkError(List<List<SudokuCellModel>> list) {
    list
        .map((element) {
          return element.where((e) => e.value != 0).toList();
        })
        .where((element) => element.isNotEmpty)
        .expand((element) {
          return groupBy<SudokuCellModel, int>(element, (model) => model.value).values.where((element) => element.length > 1).expand((element) => element);
        })
        .forEach((element) {
          element.bgStatus = SudokuCellBackgroundStatus.error;
        });
  }

  void updateCellCandidate() {}

  void didClickIndexNum(int numIndex) {
    if (currentModel == null) {
      return;
    }
    if (currentCellModel.isOriginData) {
      return;
    }
    List<SudokuNumStatus> status = selectNumStatus;
    final selectStatus = status[numIndex];
    switch (selectStatus) {
      case SudokuNumStatus.normal:
        currentCellModel.value = numIndex + 1;
        break;
      case SudokuNumStatus.candidate:
        currentCellModel.value = numIndex + 1;
        break;
      case SudokuNumStatus.select:
        currentCellModel.value = 0;
        break;
    }
    updateSudokuStatus();
  }

  void didLongpressIndexNum(int numIndex) {
    if (currentModel == null) {
      return;
    }
    if (currentCellModel.isOriginData) {
      return;
    }
    List<SudokuNumStatus> status = selectNumStatus;
    final selectStatus = status[numIndex];
    switch (selectStatus) {
      case SudokuNumStatus.normal:
        if (currentCellModel.value != 0) {
          currentCellModel.userCandidates.add(currentCellModel.value);
        }
        currentCellModel.userCandidates.add(numIndex + 1);
        currentCellModel.value = 0;
        break;
      case SudokuNumStatus.candidate:
        currentCellModel.userCandidates.remove(numIndex + 1);
        break;
      case SudokuNumStatus.select:
        if (currentCellModel.value != 0) {
          currentCellModel.userCandidates.add(currentCellModel.value);
          currentCellModel.value = 0;
        }
        if (currentCellModel.value != numIndex + 1) {
          currentCellModel.userCandidates.add(numIndex + 1);
        }
    }
    updateSudokuStatus();
  }

  void didClickTipButton() {}
}

class SudokuSolution {
  SudokuModel model;
  SudokuSolution({required this.model});

  SudokuSolutionModel eliminate() {
    for (int i = 0; i < 9; i++) {
      for (int j = 0; j < 9; j++) {
        final cellmodel = model.datas[i][j];
        if (cellmodel.candidates.length == 1) {
          return SudokuSolutionModel(row: i, col: j, value: cellmodel.candidates.first, expound: "expound");
        }
      }
    }
    return SudokuSolutionModel.fail();
  }

  SudokuSolutionModel singleCandidature() {
    return SudokuSolutionModel.fail();
  }
}
