import 'package:flutter/material.dart';
import 'package:sudoku/sudoku_num_view.dart';
import 'package:sudoku/sudoku_viewmodel.dart';
import 'sudoku_view.dart';

class SudokuPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return SudokuPageState();
  }
}

class SudokuPageState extends State<SudokuPage> {
  final SudokuViewModel viewModel = SudokuViewModel();
  final SudokuDataViewModel dataViewModel = SudokuDataViewModel();

  @override
  void initState() {
    super.initState();
    dataViewModel.swtichSudokuWithIndex(0).then((value) {
      setState(() {
        viewModel.currentModel = dataViewModel.currentModel;
        if (dataViewModel.currentModel != null) {
          viewModel.solution = SudokuSolution(model: dataViewModel.currentModel!);
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        shadowColor: Colors.transparent,
        backgroundColor: Colors.white,
        title: const Text(
          "sudoku",
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: Container(
        color: Colors.white,
        child: Column(
          children: [
            viewModel.currentModel == null
                ? const Text("loading")
                : Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: SudokuView(
                      model: viewModel.currentModel!,
                      onClickCell: didClickSudokuCell,
                    ),
                  ),
            Padding(
              padding: const EdgeInsets.only(top: 20),
              child: SudokuNumView(
                list: viewModel.selectNumStatus,
                clickIndexNum: (index) {
                  setState(() {
                    viewModel.didClickIndexNum(index);
                  });
                },
                longpressIndexNum: (index) {
                  setState(() {
                    viewModel.didLongpressIndexNum(index);
                  });
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 20),
              child: TextButton(
                onPressed: () {
                  viewModel.didClickTipButton();
                },
                child: const Text(
                  "提示",
                  style: TextStyle(fontSize: 28),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  void didClickSudokuCell(int i, int j) {
    setState(() {
      viewModel.selectCellModel(i, j);
    });
  }
}
