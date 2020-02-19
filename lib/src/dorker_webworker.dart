@JS()
library dorker_webworker;

import 'dart:html' show MessagePort, SharedWorker, Worker;

import 'package:js/js.dart';

import 'dorker_base.dart';

@anonymous
@JS('MessageEvent')
abstract class DorkerMessageEvent {
  external dynamic get data;
  external dynamic get ports;
}

@anonymous
@JS('MessagePort')
abstract class DorkerMessagePort {
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

/// Similar to [DorkerBoss] but this used inside a Shared Worker.
class DorkerSharedBoss<T> extends Dorker<T> {
  DorkerSharedBoss() {
    onConnect = allowInterop((event) {
      /// There was a bug resulted in dart2js generated js which change the type of this `event`
      ///
      /// If we used code that required a `Event` in our dart code,
      /// dart2js will go on generate a bunch of `MessageEvent` related native:dart conversion.
      /// When this happen, we need to use the `dart:html` version of `MessageEvent`
      ///
      /// Otherwise, if our dart code didn't use any `Event` related code,
      /// there will no replacement for `MessageEvent`, then we will need the interop version.
      if (event is DorkerMessageEvent) {
        final DorkerMessagePort port = event.ports[0];
        port.onmessage = allowInterop((event) {
          incoming.add(event.data);
        });

        outgoing.stream.listen((event) {
          port.postMessage(event);
        });
      } else {
        final MessagePort port = event.ports[0];
        port.onMessage.listen((event) {
          incoming.add(event.data);
        });

        outgoing.stream.listen((event) {
          port.postMessage(event);
        });
      }
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
/// This pair with [DorkerBoss]
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

/// Identical to [DorkerWorker] but use a [SharedWorker] instead.
/// This has to pair with [DorkerSharedBoss].
///
/// WARNING: SharedWorker does not work as intended in `dcc` built.
/// Nothing can live "out of the tab".
//TODO: We cannot spawn SharedWorker inside a Worker/SharedWorker context. We need a way to pass in the port.
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
