import 'dart:async';
import 'package:observable_ish/observable_ish.dart';

class StoredValue<T> implements RxValue<T> {
  T _value;
  T get value => _value;
  set value(T val) {
    if (_value == val) {
      return;
    }
    T old = _value;
    _value = val;
    _change.add(Change<T>(val, old));
  }

  final _change = StreamController<Change<T>>.broadcast();

  StoredValue(T initial) : _value = initial;

  void setCast(dynamic /* T */ val) => value = val;

  Stream<Change<T>> get onChange => _change.stream;

  Stream<T> get values async* {
    yield _value;
    await for (final v in onChange) {
      yield v.neu;
    }
  }

  /// When [other] changes, the c
  void bind(RxValue<T> other) {
    value = other.value;
    other.values.listen((v) => value = v);
  }

  void bindStream(Stream<T> stream) => stream.listen((v) => value = v);

  void bindOrSet(/* T | Stream<T> | Reactive<T> */ other) {
    if (other is RxValue<T>) {
      bind(other);
    } else if (other is Stream<T>) {
      bindStream(other.cast<T>());
    } else {
      value = other;
    }
  }

  StreamSubscription<T> listen(ValueCallback<T> callback) =>
      values.listen(callback);

  Stream<R> map<R>(R mapper(T data)) => values.map(mapper);
}
