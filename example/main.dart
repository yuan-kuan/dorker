import 'dart:html';

import 'package:dorker/dorker.dart';

import 'lib/concater.dart';

void main() {
  Dorker _concatDorker;
  if (const String.fromEnvironment('USE_WORKER') == 'true') {
    print('Asked to use worker');
    _concatDorker = DorkerWorker(Worker('worker/concater_worker.dart.js'));
  } else 
  {
    print('Not using worker');
    _concatDorker = Dorker();
    Concater(Dorker.CrossLink(_concatDorker));
  }

  var input = querySelector('#input') as TextInputElement;
  var concatButton = querySelector('#btConcat') as ButtonElement;
  
  concatButton.onClick.listen((_) {
    _concatDorker.postMessage.add(input.value);
  });

  _concatDorker.onMessage.listen((data){
    querySelector('#output').text = 'Concated: $data';
  });

  querySelector('#output').text = 'Use the input and button.';
}
