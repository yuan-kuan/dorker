@JS()
library docker_web;

import 'dart:html' show Worker;

import 'package:js/js.dart';

import 'dorker_base.dart';

@anonymous
@JS()
abstract class MessageEvent {
  external dynamic get data;
}

@JS('postMessage')
external void PostMessage(obj);

@JS('onmessage')
external void set onMessage(f);

@JS('onconnect')
external void set onConnect(f);

/**
 * DorkerBoss is Dart being the Web Worker
 */
class DorkerBoss<T> extends Dorker<T> {
  DorkerBoss() {
    onMessage = allowInterop((event) => incoming.add(event.data));
    outgoing.stream.listen(PostMessage);
  }
}

/**
 * Dart Web Worker
 */
class DorkerWorker<T> extends Dorker<T> {
  Worker _worker;
  
  DorkerWorker(this._worker) {
    _worker.onMessage.map((event) => event.data).listen(incoming.add);
    outgoing.stream.listen(_worker.postMessage);
  }
}
