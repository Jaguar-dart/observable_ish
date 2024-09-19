import 'package:observable_ish/observable_ish.dart';

export 'rx/rx_value.dart';

abstract class Value<T> {
  T get value;

  set value(T value);

  factory Value(T value) => _Value<T>(value);

  factory Value.proxy(ValueGetter<T> getter, {ValueSetter<T>? setter}) =>
      ProxyValue<T>(getter, setter: setter);

  factory Value.proxyMapKey(Map map, String key) => ProxyValue.mapKey(map, key);
}

class _Value<T> implements Value<T> {
  T _value;

  _Value(this._value);

  T get value => _value;

  set value(T value) {
    _value = value;
  }
}

class ProxyValue<T> implements Value<T> {
  ValueGetter<T> getter;
  ValueSetter<T>? setter;

  ProxyValue(this.getter, {this.setter});

  factory ProxyValue.mapKey(Map map, String key) =>
      ProxyValue(() => map[key], setter: (val) {
        if (val == null) {
          map.remove(key);
        } else {
          map[key] = val;
        }
      });

  T get value => getter();

  set value(T value) {
    if (setter != null) {
      setter!(value);
    }
  }
}
