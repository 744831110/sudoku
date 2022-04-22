import 'dart:ui';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:sudoku/colors.dart';

enum SudokuNumStatus { normal, select, candidate }

class SudokuNumView extends StatelessWidget {
  final List<SudokuNumStatus> list;
  final void Function(int) clickIndexNum;
  final void Function(int) longpressIndexNum;
  const SudokuNumView({Key? key, required this.list, required this.clickIndexNum, required this.longpressIndexNum}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: numsWidget(),
    );
  }

  List<Widget> numsWidget() {
    final dpr = window.devicePixelRatio;
    final width = window.physicalSize.width / dpr;
    List<Widget> widgets = [];
    for (int i = 0; i < list.length; i++) {
      final status = list[i];
      final text = SizedBox(
        width: (width - 10 * 10) / 9,
        height: 42,
        child: Center(
          child: Text(
            "${i + 1}",
            style: const TextStyle(color: blueColor),
          ),
        ),
      );
      Widget numWidget;
      switch (status) {
        case SudokuNumStatus.normal:
          numWidget = text;
          break;
        case SudokuNumStatus.candidate:
          numWidget = DottedBorder(padding: EdgeInsets.zero, child: text);
          break;
        case SudokuNumStatus.select:
          numWidget = DecoratedBox(
            decoration: BoxDecoration(border: Border.all(color: Colors.black)),
            child: Center(child: text),
          );
          break;
      }
      widgets.add(Padding(
        padding: const EdgeInsets.only(left: 5, right: 5),
        child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              clickIndexNum(i);
            },
            onLongPress: () {
              longpressIndexNum(i);
            },
            child: numWidget),
      ));
    }
    return widgets;
  }
}
