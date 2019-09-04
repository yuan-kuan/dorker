@JS()
library dorker_webworker;

import 'dart:html' show Worker, SharedWorker;

import 'package:js/js.dart';

import 'dorker_base.dart';

@anonymous
@JS()
abstract class MessageEvent {
  external dynamic get data;
  external dynamic get ports;
}

@anonymous
@JS()
abstract class MessagePort {
  external void postMessage(obj);
  external set onmessage(f);
}

@JS('postMessage')
external void PostMessage(obj);

@JS('onmessage')
external set onMessage(f);

@JS('onconnect')
external set onConnect(f);

@JS('close')
external void close();

/// This is like a boss, which codes inside a Web Worker talks to.
///
/// It wraps the JS interop functions of how a Web Worker receive and send messages, and
/// provides [Dorker] interface for them.
///
/// This class is usually used inside a Web Worker script
/// '''
/// main() {
///   Service(DorkerBoss());
/// }
/// '''
class DorkerBoss<T> extends Dorker<T> {
  DorkerBoss() {
    onMessage = allowInterop((event) => incoming.add(event.data));
    outgoing.stream.listen(PostMessage);
  }
}

class DorkerSharedBoss<T> extends Dorker<T> {
  DorkerSharedBoss() {
    onConnect = allowInterop((event) {
      final MessagePort port = event.ports[0];

      port.onmessage = allowInterop((event) {
        incoming.add(event.data);
      });

      outgoing.stream.listen((event) {
        port.postMessage(event);
      });
    });
  }

  @override
  void dispose() {
    close();
    super.dispose();
  }
}

/// This take a Web [Worker], and wrap the communication with the Worker, then provides
/// [Dorker] interface to whoever want to use this Worker.
///
/// ```
/// _dorker = DorkerWorker(Worker('worker.js'));
/// _dorker.onMessage.listen(_handle);
/// _dorker.postMessage.add('start working');
/// ```
class DorkerWorker<T> extends Dorker<T> {
  Worker _worker;

  DorkerWorker(this._worker) {
    _worker.onMessage.map((event) => event.data).listen(incoming.add);
    outgoing.stream.listen(_worker.postMessage);
  }

  @override
  void dispose() {
    _worker.terminate();
    super.dispose();
  }
}

class DorkerSharedWorker<T> extends Dorker<T> {
  SharedWorker _worker;

  DorkerSharedWorker(this._worker) {
    _worker.port.onMessage.map((event) => event.data).listen(incoming.add);
    outgoing.stream.listen(_worker.port.postMessage);
  }

  @override
  void dispose() {
    _worker.port.close();
    super.dispose();
  }
}
