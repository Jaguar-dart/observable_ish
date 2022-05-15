import 'dart:async';
import 'package:observable_ish/observable_ish.dart';

/// Emits events of type [T]
abstract class Emitter<T> {
  factory Emitter(
          {List<RxValue<T>> emitRxValues = const [],
          List<Stream<T>> emitStreams = const [],
          Stream<T>? emitStream,
          RxValue<T>? emitRxValue}) =>
      StreamBackedEmitter<T>(
          emitRxValue: emitRxValue,
          emitStreams: emitStreams,
          emitStream: emitStream,
          emitRxValues: emitRxValues);

  /// Calls [callback] whenever there is an event
  void on(/* Callback | ValueCallback */ callback);

  /// Calls [callback] whenever there is an event. Returns a [StreamSubscription]
  /// to control the listening.
  StreamSubscription<T> listen(/* Callback | ValueCallback */ callback);

  /// Returns events as [Stream].
  Stream<T> get asStream;

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

  /// Emits values of [value]
  void emitRxValues(List<RxValue<T>> value);

  Future<void> dispose();
}

class StreamBackedEmitter<T> implements Emitter<T> {
  final _streamer = StreamController<T>.broadcast();

  StreamBackedEmitter(
      {List<RxValue<T>> emitRxValues = const [],
      List<Stream<T>> emitStreams = const [],
      Stream<T>? emitStream,
      RxValue<T>? emitRxValue}) {
    this.emitRxValues(emitRxValues);
    this.emitStreams(emitStreams);
    if (emitRxValue != null) this.emitRxValue(emitRxValue);
    if (emitStream != null) this.emitStream(emitStream);
  }

  void emitOne(T value) => _streamer.add(value);

  void emitAll(Iterable<T> values) {
    for (final v in values) {
      _streamer.add(v);
    }
  }

  void emitStream(Stream<T> stream) {
    stream.listen((event) {
      _streamer.add(event);
    });
  }

  void emitStreams(List<Stream<T>> stream) => stream.forEach(emitStream);

  StreamSubscription<T> on(dynamic /* Callback | ValueCallback */ callback) {
    if (callback is Callback) {
      return _streamer.stream.listen((_) => callback());
    } else if (callback is ValueCallback<T>) {
      return _streamer.stream.listen(callback);
    }
    throw Exception('Invalid callback ${callback}!');
  }

  StreamSubscription<T> listen(
      dynamic /* Callback | ValueCallback */ callback) {
    if (callback is Callback) {
      return _streamer.stream.listen((_) => callback());
    } else if (callback is ValueCallback<T>) {
      return _streamer.stream.listen(callback);
    }
    throw Exception('Invalid callback!');
  }

  void emit(Emitter<T> emitter) => emitter.listen(emitOne);

  Stream<T> get asStream => _streamer.stream;

  void pipeTo(Emitter<T> emitter) => emitter.emit(this);

  void pipeToValue(RxValue<T> other) => other.bindStream(asStream);

  void emitRxValue(RxValue<T> value) {
    emitStream(value.values);
  }

  void emitRxValues(List<RxValue<T>> values) => values.forEach(emitRxValue);

  Future<void> dispose() => _streamer.close();
}
