library docker;

import 'dart:async';

import 'package:meta/meta.dart';

class Dorker<T> {
  @protected
  final incoming = StreamController<T>();
  @protected
  final outgoing = StreamController<T>();

  Stream<T> get onMessage => incoming.stream;
  Sink<T> get postMessage => outgoing.sink;

  Dorker();
  Dorker.CrossLink(Dorker rekrod) {
    rekrod.outgoing.stream.listen(incoming.add);
    outgoing.stream.listen(rekrod.incoming.add);
  }
}