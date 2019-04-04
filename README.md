# Web Worker and Dart

This package provides 2 things.
1. Dart wrappers for Web Worker. One that talks to the Web Worker, and one that inside a Web Worker. All in the same project, written in Dart.
2. A solution to develop with `dartdevc` and `webdev serve` even when Web Worker will not start up correctly.

Some background about point number 2:

Web Worker is all along working well with `webdev serve --release`, or compiling it with `dart2js`. But having Web Worker code actively developing alongside the main application in the same project with `dartdevc` is not possible because Worker will not launch correctly with `webdev serve`.

This is likely a bug, or a feature yet to be supported. Before it is figured out by Dart, this package can bridge that gap, with a little bit of work.

## Normal Web Worker Usage

These examples will only work if you use `webdev serve --release`.

Inside the Web Worker

```dart
import 'package:dorker/dorker.dart';

main() {
  var _boss = DorkerBoss();
  _boss.onMessage.listen((data_from_main) => print(data_from_main));
  _boss.postMessage.add('Yes Boss');
}
```

In the main application

```dart
import 'dart:html';

import 'package:dorker/dorker.dart';

void main() {
    _dorker = DorkerWorker(Worker('worker.dart.js'));
    _dorker.onMessage.listen((data_from_worker) => print(data_from_worker));
    _dorker.postMessage.add('Start working!');
}
```

## Develop Web Worker powered project with `dartdevc`

The main idea is encapsulate the communication to/from Web Worker with Dorker. And then passing a special environment variable when we build with `webdev serve --release`. This can be done with a `build.yaml`, which is in this repro.

```dart
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
}
```

Example folder provided a good guideline of how to pull this off. You can the example by running either `webdev serve` or `webdev serve -r`.

To follow my personal story of how I come to this, you can check out my post [here](https://medium.com/@yuankuan/web-worker-and-dart-2-5f38ba74575c).
