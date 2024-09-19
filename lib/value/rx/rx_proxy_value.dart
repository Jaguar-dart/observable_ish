import 'dart:async';

import 'package:observable_ish/observable_ish.dart';

class RxProxyValue<T> with RxListenable<T> implements RxValue<T> {
  ValueGetter<T> getter;
  ValueSetter<T>? setter;

  final _controller = StreamController<Change<T>>.broadcast();

  RxProxyValue(this.getter, {this.setter});

  factory RxProxyValue.mapKey(Map map, String key) =>
      RxProxyValue(() => map[key], setter: (val) => map[key] = val);

  T get value => getter();

  set value(T val) {
    T old = value;
    if (old == val) {
      return;
    }
    setter?.call(val);
    _controller.add(Change<T>(val, old));
  }

  Stream<Change<T>> get onChange => _controller.stream;

  void setCast(dynamic /* T */ val) => value = val;

  void bind(RxValue<T> reactive) {
    value = reactive.value;
    reactive.values.listen((v) => value = v);
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

  late final RxListenable<T> listenable = RxListenableImpl(getter, onChange);

  Future<void> dispose() async {
    await _controller.close();
  }
}
