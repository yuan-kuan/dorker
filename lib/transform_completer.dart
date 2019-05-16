import 'dart:async' show Completer;

typedef T Transform<T>(dynamic data);

class TransformCompleter<T> {
  final _completer = Completer<T>();
  final Transform<T> _transform;

  TransformCompleter([this._transform]);

  void complete([dynamic data]) {
    try {
      _completer.complete(_transform?.call(data));
    } on Exception catch (e){
      _completer.completeError(e);
    }
  }

  void completeError(dynamic error) {
    _completer.completeError(error);
  }

  bool get isCompleted => _completer.isCompleted;
  Future<T> get future => _completer.future;
}