import 'package:dio/dio.dart';

class SudokuDataSource {
  static Future<List<String>> requestMagictourData() async {
    var response = await Dio().get("http://magictour.free.fr/topn234");
    String data = response.data;
    List<String> list = [];
    int index = 81;
    while (data.length >= index) {
      list.add(data.substring(index - 81, index));
      index += 81;
    }
    return list;
  }
}
