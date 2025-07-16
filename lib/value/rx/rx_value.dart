import 'dart:async';

import 'package:observable_ish/observable_ish.dart';

export 'rx_stored_value.dart';
export 'rx_proxy_value.dart';

abstract mixin class RxListenable<T> {
  T get value;

  Stream<Change<T>> get onChange;

  Stream<T> get values {
    return Stream.multi((controller) {
      controller.add(value);
      final subscription = onChange.listen((v) => controller.add(v.neu),
          onError: controller.addError, onDone: controller.close);
      controller.onCancel = subscription.cancel;
    });
  }

  /// Calls [callback] with current value, when the value changes.
  StreamSubscription<T> listen(ValueCallback<T> callback) =>
      values.asBroadcastStream().listen(callback);

  /// Maps the changes into a [Stream] of [R]
  Stream<R> map<R>(R mapper(T data)) => values.map(mapper);
}

class RxListenableImpl<T> extends RxListenable<T> {
  final ValueGetter<T> _getter;
  final Stream<Change<T>> onChange;

  RxListenableImpl(this._getter, this.onChange);

  T get value => _getter();

  StreamSubscription<T> listen(ValueCallback<T> callback) =>
      values.listen(callback);

  Stream<R> map<R>(R mapper(T data)) => values.map(mapper);
}

/// Interface of an observable value of type [T]
abstract class RxValue<T> implements RxListenable<T>, Value<T> {
  factory RxValue(T initial) => RxStoredValue<T>(initial);

  factory RxValue.proxy(ValueGetter<T> getter, {ValueSetter<T>? setter}) =>
      RxProxyValue<T>(getter, setter: setter);

  factory RxValue.proxyMapKey(Map map, String key) =>
      RxProxyValue.mapKey(map, key);

  /// Get current value
  T get value;

  /// Set value
  set value(T val);

  /// Cast [val] to [T] before setting
  void setCast(dynamic /* T */ val);

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

  RxListenable<T> get listenable;

  Future<void> dispose();
}

/// A record of change in [RxValue]
class Change<T> {
  /// Value before change
  final T old;

  /// Value after change
  final T neu;

  Change(this.neu, this.old);

  String toString() => 'Change(new: $neu, old: $old)';
}
