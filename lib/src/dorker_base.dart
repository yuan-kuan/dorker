import 'dart:async';

import 'package:meta/meta.dart';

/// It is a simple class which provides
/// a [Stream] to listen to, and a [Sink] to pass message.
class Dorker<T> {
  @protected
  final incoming = StreamController<T>.broadcast();
  @protected
  final outgoing = StreamController<T>();

  Stream<T> get onMessage => incoming.stream;
  Sink<T> get postMessage => outgoing.sink;

  Dorker();
  
  /// Links up 2 [Dorker] so both side can start communicating.
  /// 
  /// A good metaphor is like 2 people talking on the phone. 
  /// The phone is the [Dorker]. CrossLink is like dialing up and connecting the phone.
  /// 
  /// This is useful to connect 2 classes that only communicate via [Dorker].
  /// 
  /// It is especially useful to run a Dart Web App in `webdev serve` but retain most
  /// or the logic working with Web Worker.
  Dorker.CrossLink(Dorker rekrod) {
    rekrod.outgoing.stream.listen(incoming.add);
    outgoing.stream.listen(rekrod.incoming.add);
  }

  @mustCallSuper
  void dispose() {
    incoming.close();
    outgoing.close();
  }

  bool isActive() {
    return !outgoing.isClosed && !outgoing.isPaused;
  }
}