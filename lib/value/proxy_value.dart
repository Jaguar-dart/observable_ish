import 'dart:async';
import 'package:observable_ish/observable_ish.dart';

class ProxyValue<T> with RxListenable<T> implements RxValue<T> {
  ValueGetter<T> getter;
  ValueSetter<T>? setter;

  final _controller = StreamController<Change<T>>.broadcast();

  ProxyValue(this.getter, {this.setter});

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

  RxListenable<T> get listenable => RxListenableImpl(getter, onChange);
}
