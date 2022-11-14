import 'dart:async';
import 'dart:collection';

import 'package:observable_ish/observable_ish.dart';

class RxMap<K, V> extends MapBase<K, V> {
  final Map<K, V> _inner;

  final _changes = StreamController<MapChange<K, V>>.broadcast();

  RxMap() : _inner = {};

  RxMap.from(Map other) : _inner = Map<K, V>.from(other);

  RxMap.of(Map<K, V> other) : _inner = Map<K, V>.of(other);

  RxMap.fromIterable(Iterable iterable, {K key(element)?, V value(element)?})
      : _inner = Map<K, V>.fromIterable(iterable, key: key, value: value);

  RxMap.fromIterables(Iterable<K> keys, Iterable<V> values)
      : _inner = Map<K, V>.fromIterables(keys, values);

  RxMap.fromEntries(Iterable<MapEntry<K, V>> entries)
      : _inner = Map<K, V>.fromEntries(entries);

  Stream<MapChange<K, V>> get onChange => _changes.stream;

  void add(K key, V value) => this[key] = value;

  void addIf(/* bool | Condition */ condition, K key, V value) {
    if (condition is Condition) condition = condition();
    if (condition is bool && condition) this[key] = value;
  }

  void addAllIf(/* bool | Condition */ condition, Map<K, V> values) {
    if (condition is Condition) condition = condition();
    if (condition is bool && condition) addAll(values);
  }

  @override
  operator []=(K key, V value) {
    bool isSet = _inner.containsKey(key);
    _inner[key] = value;
    _changes
        .add(MapChange(MapEntry(key, value), isSet ? MapOp.set : MapOp.add));
  }

  @override
  V? operator [](Object? key) => _inner[key];

  @override
  Iterable<K> get keys => _inner.keys;

  @override
  void clear() {
    _inner.clear();
    _changes.add(MapChange(null, MapOp.clear));
  }

  @override
  V? remove(Object? key) {
    bool isRemoved = _inner.containsKey(key);
    final ret = _inner.remove(key);
    if (isRemoved) {
      _changes.add(MapChange(MapEntry(key as K, ret as V), MapOp.remove));
    }
    return ret;
  }

  Future<void> dispose() async {
    await _changes.close();
  }
}

/// Change operation
enum MapOp { add, remove, clear, set }

class MapChange<K, V> {
  final MapEntry<K, V>? entry;

  final MapOp op;

  MapChange(this.entry, this.op);

  String toString() => 'MapChange($entry, $op)';
}
