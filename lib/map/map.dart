import 'package:collection/collection.dart';
import 'package:observable_ish/observable_ish.dart';

class RxMap<K, V> extends DelegatingMap<K, V> implements Map<K, V> {
  RxMap() : super(<K, V>{});

  RxMap.from(Map other) : super(Map<K, V>.from(other));

  RxMap.of(Map<K, V> other) : super(Map<K, V>.of(other));

  RxMap.fromIterable(Iterable iterable, {K key(element)?, V value(element)?})
      : super(Map<K, V>.fromIterable(iterable, key: key, value: value));

  RxMap.fromIterables(Iterable<K> keys, Iterable<V> values)
      : super(Map<K, V>.fromIterables(keys, values));

  RxMap.fromEntries(Iterable<MapEntry<K, V>> entries)
      : super(Map<K, V>.fromEntries(entries));

  void add(K key, V value) => this[key] = value;

  void addIf(/* bool | Condition */ condition, K key, V value) {
    if (condition is Condition) condition = condition();
    if (condition is bool && condition) this[key] = value;
  }

  void addAllIf(/* bool | Condition */ condition, Map<K, V> values) {
    if (condition is Condition) condition = condition();
    if (condition is bool && condition) addAll(values);
  }
}
