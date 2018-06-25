import 'dart:async';
import 'observable_ish.dart';

typedef void ValueCallback<T>(T v);

typedef dynamic Callback();

abstract class Emitter<T> {
  void on(/* Callback | ValueCallback */ callback);
  StreamSubscription<T> listen(/* Callback | ValueCallback */ callback);
  Stream<T> get asStream;
  void pipeToOther(EmitableEmitter<T> other);
  void pipeToRx(Reactive<T> other);
}

abstract class EmitableEmitter<T> implements Emitter<T> {
  void emit(T value);
  void emitAll(Iterable<T> values);
  void emitStream(Stream<T> value);
  void emitOther(EmitableEmitter<T> other);
}

class StreamBackedEmitter<T> implements EmitableEmitter<T> {
  final _streamer = StreamController<T>();

  Stream<T> _stream;

  StreamBackedEmitter() {
    _stream = _streamer.stream.asBroadcastStream();
  }

  void emit(T value) => _streamer.add(value);

  void emitAll(Iterable<T> values) {
    for (T v in values) _streamer.add(v);
  }

  void emitStream(Stream<T> value) => _streamer.addStream(value);

  void on(/* Callback | ValueCallback */ callback) {
    if (callback is Callback)
      _stream.listen((_) => callback());
    else if (callback is ValueCallback<T>)
      _stream.listen(callback);
    else
      throw new Exception('Invalid callback ${callback}!');
  }

  StreamSubscription<T> listen(/* Callback | ValueCallback */ callback) {
    if (callback is Callback)
      return _stream.listen((_) => callback());
    else if (callback is ValueCallback<T>) return _stream.listen(callback);
    throw new Exception('Invalid callback!');
  }

  void emitOther(EmitableEmitter<T> other) => other.listen(emit);

  Stream<T> get asStream => _stream;

  void pipeToOther(EmitableEmitter<T> other) => other.emitOther(this);

  void pipeToRx(Reactive<T> other) => other.bindStream(_stream);
}
