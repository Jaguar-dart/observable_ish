import 'dart:async';
import 'package:observable_ish/observable_ish.dart';

/// Emits events of type [T]
abstract class Emitter<T> {
  factory Emitter() => StreamBackedEmitter<T>();
  /// Calls [callback] whenever there is an event
  void on(/* Callback | ValueCallback */ callback);
  /// Calls [callback] whenever there is an event. Returns a [StreamSubscription]
  /// to control the listening.
  StreamSubscription<T> listen(/* Callback | ValueCallback */ callback);
  /// Returns events as [Stream].
  Stream<T>? get asStream;
  /// Pipes events to [other]
  void pipeTo(Emitter<T> other);
  /// Pipes events to [other]
  void pipeToValue(RxValue<T> other);
  /// Emits a [value]
  void emitOne(T value);
  /// Emits all of the [values]
  void emitAll(Iterable<T> values);
  /// Emits values of the [stream]
  void emitStream(Stream<T> stream);
  /// Emits values of [emitter]
  void emit(Emitter<T> emitter);
  /// Emits values of [value]
  void emitRxValue(RxValue<T> value);

  Future<void> dispose();
}

class StreamBackedEmitter<T> implements Emitter<T> {
  final _streamer = StreamController<T>();

  Stream<T>? _stream;

  StreamBackedEmitter() {
    _stream = _streamer.stream.asBroadcastStream();
  }

  void emitOne(T value) => _streamer.add(value);

  void emitAll(Iterable<T> values) {
    for (T v in values) _streamer.add(v);
  }

  void emitStream(Stream<T> stream) => _streamer.addStream(stream);

  StreamSubscription<T> on(/* Callback | ValueCallback */ callback) {
    if (callback is Callback)
      return _stream!.listen((_) => callback());
    else if (callback is ValueCallback<T>)
      return _stream!.listen(callback);
    else
      throw Exception('Invalid callback ${callback}!');
  }

  StreamSubscription<T> listen(/* Callback | ValueCallback */ callback) {
    if (callback is Callback)
      return _stream!.listen((_) => callback());
    else if (callback is ValueCallback<T>) return _stream!.listen(callback);
    throw Exception('Invalid callback!');
  }

  void emit(Emitter<T> emitter) => emitter.listen(emitOne);

  Stream<T>? get asStream => _stream;

  void pipeTo(Emitter<T> emitter) => emitter.emit(this);

  void pipeToValue(RxValue<T> other) => other.bindStream(_stream);

  void emitRxValue(RxValue<T> value) {
    _streamer.addStream(value.values);
  }

  Future<void> dispose() => _streamer.close();
}
