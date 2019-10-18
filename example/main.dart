import 'dart:html';

import 'package:dorker/dorker.dart';

import 'lib/concater.dart';

void main() {
  Dorker _concatDorker;
  Dorker _concatSharedDorker;
  if (const String.fromEnvironment('USE_WORKER') == 'true') {
    print('Asked to use worker');
    _concatDorker = DorkerWorker(Worker('worker/concater_worker.dart.js'));
    _concatSharedDorker = DorkerSharedWorker(
        SharedWorker('worker/concater_sharedworker.dart.js'));
  } else {
    print(
        'Not using worker. Share worker across multiple Tab will not work as intended');
    _concatDorker = Dorker();
    _concatSharedDorker = Dorker();
    Concater(Dorker.CrossLink(_concatDorker));
    Concater(Dorker.CrossLink(_concatSharedDorker));
  }

  var input = querySelector('#input') as TextInputElement;
  var concatButton = querySelector('#btConcat') as ButtonElement;
  var sharedConcatButton = querySelector('#btSharedConcat') as ButtonElement;

  concatButton.onClick.listen((_) {
    _concatDorker.postMessage.add(input.value);
    input.text = "";
  });

  sharedConcatButton.onClick.listen((_) {
    _concatSharedDorker.postMessage.add(input.value);
    input.text = "";
  });

  _concatDorker.onMessage.listen((data) {
    querySelector('#output').text = 'Concated: $data';
  });

  _concatSharedDorker.onMessage.listen((data) {
    querySelector('#sharedOutput').text = 'Shared Concated: $data';
  });

  querySelector('#output').text = 'Use the input and button.';
}
