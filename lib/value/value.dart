import 'dart:async';

import 'package:observable_ish/observable_ish.dart';
import 'stored_value.dart';
import 'proxy_value.dart';

export 'stored_value.dart';
export 'proxy_value.dart';

abstract class Listenable<T> {
  /// Stream of record of [Change]s of value
  Stream<Change<T>> get onChange;

  /// Stream of changes of value
  Stream<T> get values;

  /// Binds if [other] is [Stream] or [RxValue] of type [T]. Sets if [other] is
  /// instance of [T]
  void bindOrSet(/* T | Stream<T> | Reactive<T> */ other);

  /// Binds [other] to this
  void bind(RxValue<T> other);

  /// Binds the [stream] to this
  void bindStream(Stream<T> stream);

  /// Calls [callback] with current value, when the value changes.
  StreamSubscription<T> listen(ValueCallback<T> callback);

  /// Maps the changes into a [Stream] of [R]
  Stream<R> map<R>(R mapper(T data));
}

/// Interface of an observable value of type [T]
abstract class RxValue<T> implements Listenable<T> {
  factory RxValue(T initial) => StoredValue<T>(initial);
  factory RxValue.proxy(ValueGetter<T> getterProxy) =>
      ProxyValue<T>(getterProxy);

  /// Get current value
  T get value;

  /// Set value
  set value(T val);

  /// Cast [val] to [T] before setting
  void setCast(dynamic /* T */ val);
}

/// A record of change in [RxValue]
class Change<T> {
  /// Value before change
  final T old;

  /// Value after change
  final T neu;

  final DateTime time;

  final int batch;

  Change(this.neu, this.old, this.batch, {DateTime? time})
      : time = DateTime.now();

  String toString() => 'Change(new: $neu, old: $old)';
}

class ListenableImpl<T> implements Listenable<T> {
  final RxValue<T> _inner;

  ListenableImpl(this._inner);

  Stream<Change<T>> get onChange => _inner.onChange;

  Stream<T> get values => _inner.values;

  void bindOrSet(/* T | Stream<T> | Reactive<T> */ other) =>
      _inner.bindOrSet(other);

  void bind(RxValue<T> other) => bind(other);

  void bindStream(Stream<T> stream) => bindStream(stream);

  StreamSubscription<T> listen(ValueCallback<T> callback) => listen(callback);

  Stream<R> map<R>(R mapper(T data)) => map(mapper);
}
