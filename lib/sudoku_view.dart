import 'package:flutter/material.dart';
import 'package:sudoku/colors.dart';
import 'dart:ui';

import 'package:sudoku/sudoku_model.dart';

class SudokuView extends StatelessWidget {
  final SudokuModel model;
  final void Function(int i, int j) onClickCell;

  const SudokuView({Key? key, required this.model, required this.onClickCell}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final dpr = window.devicePixelRatio;
    final width = window.physicalSize.width / dpr;
    final size = Size(width - 40, width - 40);
    final cellWidth = ((size.width - 10.5) ~/ 9).toDouble();
    final trueSize = Size(cellWidth * 9 + 10.5, cellWidth * 9 + 10.5);
    List<Widget> stackChildren = [SudokuWrapper(size: trueSize)];
    stackChildren.addAll(createCell(cellWidth));
    return Center(
      child: SizedBox(
        width: trueSize.width,
        height: trueSize.height,
        child: Stack(
          alignment: Alignment.center,
          children: stackChildren,
        ),
      ),
    );
  }

  List<Widget> createCell(double cellWidth) {
    List<Widget> result = [];
    for (int i = 0; i < model.datas.length; i++) {
      final row = model.datas[i];
      for (int j = 0; j < row.length; j++) {
        final cellModel = row[j];
        final cell = Positioned(
          child: GestureDetector(
            onTap: () {
              onClickCell(i, j);
            },
            child: SudokuCell(
              model: cellModel,
              size: Size(cellWidth, cellWidth),
            ),
          ),
          left: j + 1 + j * cellWidth + (j ~/ 3 + 1) * 0.5 - 0.75,
          top: i + 1 + i * cellWidth + (i ~/ 3 + 1) * 0.5 - 0.75,
        );
        result.add(cell);
      }
    }
    return result;
  }
}

class SudokuCell extends StatelessWidget {
  final Size size;
  final SudokuCellModel model;
  const SudokuCell({Key? key, required this.size, required this.model}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      color: bgColor(),
      width: size.width,
      height: size.height,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Visibility(
            child: Text(
              model.value.toString(),
              style: TextStyle(color: textColor(), fontWeight: FontWeight.w400, fontSize: 25),
            ),
            visible: model.value != 0,
          ),
          Visibility(
            child: SudokuCandidateView(
              candidateList: model.userCandidates.toList(),
              candidateSize: Size(size.width / 3, size.height / 3),
            ),
            visible: model.value == 0,
          )
        ],
      ),
    );
  }

  Color bgColor() {
    switch (model.bgStatus) {
      case SudokuCellBackgroundStatus.select:
        return lightBlueColor;
      case SudokuCellBackgroundStatus.equal:
        return lightGreyColor2;
      case SudokuCellBackgroundStatus.tip:
        return lightGreyColor;
      case SudokuCellBackgroundStatus.none:
        return Colors.white;
      case SudokuCellBackgroundStatus.error:
        return lightRedColor;
    }
  }

  Color textColor() {
    switch (model.numStatus) {
      case SudokuCellNumStatus.error:
        return redColor;
      case SudokuCellNumStatus.userFill:
        return blueColor;
      case SudokuCellNumStatus.normal:
        return blackColor;
    }
  }
}

class SudokuCandidateView extends StatelessWidget {
  final List<int> candidateList;
  final Size candidateSize;
  const SudokuCandidateView({Key? key, required this.candidateList, required this.candidateSize}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: createCandidate(),
    );
  }

  List<Widget> createCandidate() {
    List<Widget> list = [];
    for (int i = 0; i < 9; i++) {
      final container = Positioned(
        child: SizedBox(
          width: candidateSize.width,
          height: candidateSize.height,
          child: Center(
            child: Text(
              candidateList.contains((i + 1)) ? (i + 1).toString() : "",
              style: const TextStyle(color: lightBlackColor, fontSize: 10, fontWeight: FontWeight.normal),
            ),
          ),
        ),
        top: i ~/ 3 * candidateSize.height,
        left: i % 3 * candidateSize.width,
      );
      list.add(container);
    }
    return list;
  }
}

// 数独view上的线
class SudokuWrapper extends StatelessWidget {
  final Size size;
  const SudokuWrapper({Key? key, required this.size}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size.width, size.height),
      painter: _SudokuWrapperLinePainter(),
    );
  }
}

class _SudokuWrapperLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    double cellWidth = (size.width - 10.5) / 9.0;
    double cellHeight = cellWidth;
    var paint = Paint()
      ..isAntiAlias = true
      ..style = PaintingStyle.stroke
      ..color = greyColor
      ..strokeWidth = 1;
    for (int i = 0; i <= 9; i++) {
      if (i % 3 == 0) {
        continue;
      }
      canvas.drawLine(Offset(cellWidth * i + i + 1 + ((i ~/ 3 + 1) * 0.5) - 0.75 - 0.5, 0), Offset(cellWidth * i + i + 1 + ((i ~/ 3 + 1) * 0.5) - 0.75 - 0.5, size.height), paint);
      canvas.drawLine(Offset(0, cellHeight * i + i + 1 + ((i ~/ 3 + 1) * 0.5) - 0.75 - 0.5), Offset(size.width, cellHeight * i + i + 1 + (i ~/ 3 * 0.5) - 0.75 - 0.5), paint);
    }
    paint.color = blackColor;
    paint.strokeWidth = 1.5;
    for (int i = 0; i <= 3; i++) {
      canvas.drawLine(Offset(cellWidth * i * 3 + i * 0.5 + i * 3, 0), Offset(cellWidth * i * 3 + i * 0.5 + i * 3, size.height), paint);
      canvas.drawLine(Offset(0, cellHeight * i * 3 + i * 0.5 + i * 3), Offset(size.width, cellHeight * i * 3 + i * 0.5 + i * 3), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
