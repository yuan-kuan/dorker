import 'package:dorker/dorker.dart';

class Concater {
  var _memory = '';
  Concater(Dorker _boss) {
    _boss.onMessage.listen((data) {
      _memory += '$data ';
      _boss.postMessage.add(_memory);
    });
  }
}
