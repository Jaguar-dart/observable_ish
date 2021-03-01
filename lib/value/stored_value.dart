import 'dart:async';
import 'value.dart';
import 'package:observable_ish/observable_ish.dart';

class StoredValue<T> implements RxValue<T> {
  T? _value;
  T? get value => _value;
  final StreamController<Change<T?>> _change = StreamController<Change<T?>>();
  set value(T? val) {
    if (_value == val) return;
    T? old = _value;
    _value = val;
    _change.add(Change<T?>(val, old, _curBatch));
  }

  int _curBatch = 0;

  StoredValue({required T? initial}) : _value = initial {
    _onChange = _change.stream.asBroadcastStream();
  }

  void setCast(dynamic /* T */ val) => value = val;

  late Stream<Change<T?>> _onChange;

  Stream<Change<T?>> get onChange {
    _curBatch++;
    final StreamController<Change<T?>> ret = StreamController<Change<T?>>();
    ret.add(Change<T?>(value, null, _curBatch));
    ret.addStream(_onChange.skipWhile((v) => v.batch < _curBatch));
    return ret.stream.asBroadcastStream();
  }

  Stream<T> get values => onChange.map((c) => c.neu!);

  void bind(RxValue<T> reactive) {
    value = reactive.value;
    reactive.values.listen((v) => value = v!);
  }

  void bindStream(Stream<T>? stream) => stream!.listen((v) => value = v);

  void bindOrSet(/* T | Stream<T> | Reactive<T> */ other) {
    if (other is RxValue<T>) {
      bind(other);
    } else if (other is Stream<T>) {
      bindStream(other.cast<T>());
    } else {
      value = other;
    }
  }

  StreamSubscription<T?> listen(ValueCallback<T?> callback) =>
      values.listen(callback);

  Stream<R> map<R>(R mapper(T? data)) => values.map(mapper);
}
