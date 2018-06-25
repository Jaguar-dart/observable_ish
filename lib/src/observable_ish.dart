import 'dart:async';

export 'event.dart';
export 'list.dart';
export 'set.dart';
export 'map.dart';

typedef bool Condition();

typedef T ValueGetter<T>();

typedef void ValueSetter<T>(T val);

class Change<T> {
  final T old;
  final T neu;
  final DateTime time;
  Change(this.neu, this.old, {DateTime time}) : time = DateTime.now();
  String toString() => 'Change(new: $neu, old: $old)';
}

abstract class Reactive<T> {
  T get value;

  set value(T val);

  void setCast(dynamic /* T */ val);

  Stream<Change<T>> get onChange;

  Stream<T> get values;

  factory Reactive({T initial}) => StoredReactive<T>(initial: initial);

  void setHowever(/* T | Stream<T> | Reactive<T> */ other);

  void bind(Reactive<T> reactive);

  void bindStream(Stream<T> stream);

  StreamSubscription<T> listen(void callback(T data));

  Stream<R> map<R>(R mapper(T data));

  // TODO where
}

class StoredReactive<T> implements Reactive<T> {
  T _value;
  T get value => _value;
  final _change = new StreamController<Change<T>>();
  set value(T val) {
    if (_value == val) return;
    T old = _value;
    _value = val;
    _change.add(Change<T>(val, old));
  }

  StoredReactive({T initial}) : _value = initial {
    _onChange = _change.stream.asBroadcastStream();
  }

  void setCast(dynamic /* T */ val) => value = val;

  Stream<Change<T>> _onChange;

  Stream<Change<T>> get onChange {
    var now = DateTime.now();
    final ret = StreamController<Change<T>>();
    ret.add(Change<T>(value, null));
    ret.addStream(_onChange.skipWhile((v) {
      return v.time.isBefore(now);
    }));
    return ret.stream.asBroadcastStream();
  }

  Stream<T> get values => onChange.map((c) => c.neu);

  void bind(Reactive<T> reactive) {
    value = reactive.value;
    reactive.values.listen((v) => value = v);
  }

  void bindStream(Stream<T> stream) => stream.listen((v) => value = v);

  void setHowever(/* T | Stream<T> | Reactive<T> */ other) {
    if (other is Reactive<T>) {
      bind(other);
    } else if (other is Stream<T>) {
      bindStream(other.cast<T>());
    } else {
      value = other;
    }
  }

  StreamSubscription<T> listen(void callback(T data)) =>
      values.listen(callback);

  Stream<R> map<R>(R mapper(T data)) => values.map(mapper);
}

class BackedReactive<T> implements Reactive<T> {
  ValueGetter<T> getter = _defGetter;
  final _change = new StreamController<Change<T>>();
  BackedReactive({this.getter: _defGetter}) {
    _onChange = _change.stream.asBroadcastStream();
  }

  static T _defGetter<T>() => null;

  T get value => getter();
  set value(T val) {
    T old = value;
    if (old == val) return;
    _change.add(Change<T>(val, old));
  }

  void setCast(dynamic /* T */ val) => value = val;

  Stream<Change<T>> _onChange;

  Stream<Change<T>> get onChange {
    // var now = DateTime.now();
    final ret = StreamController<Change<T>>();
    ret.add(Change<T>(value, null));
    ret.addStream(_onChange);
    // ret.addStream(_onChange.skipWhile((v) => v.time.isBefore(now)));
    return ret.stream.asBroadcastStream();
  }

  Stream<T> get values => onChange.map((c) => c.neu);

  void bind(Reactive<T> reactive) {
    value = reactive.value;
    reactive.values.listen((v) => value = v);
  }

  void bindStream(Stream<T> stream) => stream.listen((v) => value = v);

  void setHowever(/* T | Stream<T> | Reactive<T> */ other) {
    if (other is Reactive<T>) {
      bind(other);
    } else if (other is Stream<T>) {
      bindStream(other.cast<T>());
    } else {
      value = other;
    }
  }

  StreamSubscription<T> listen(void callback(T data)) =>
      values.listen(callback);

  Stream<R> map<R>(R mapper(T data)) => values.map(mapper);
}
