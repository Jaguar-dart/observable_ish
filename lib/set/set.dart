import 'dart:async';
import 'package:collection/collection.dart';
import 'package:observable_ish/observable_ish.dart';

class RxSet<E> extends DelegatingSet<E> implements Set<E> {
  final _changes = StreamController<SetChange<E>>.broadcast();

  RxSet() : super(Set<E>());

  RxSet.from(Iterable elements) : super(Set<E>.from(elements));

  RxSet.of(Iterable<E> elements) : super(Set<E>.of(elements));

  RxSet.union(Iterable<E> elements, [E? element])
      : super(Set<E>.from(elements)) {
    if (element != null) _add(element);
  }

  void addIf(/* bool | Condition */ condition, E element) {
    if (condition is Condition) condition = condition();
    if (condition is bool && condition) add(element);
  }

  void addAllIf(/* bool | Condition */ condition, Iterable<E> elements) {
    if (condition is Condition) condition = condition();
    if (condition is bool && condition) addAll(elements);
  }

  bool _add(E element) => super.add(element);

  bool add(E element) {
    bool ret = super.add(element);
    if (ret) {
      _changes.add(SetChange<E>.add(element));
    }
    return ret;
  }

  bool addNonNull(E element) {
    if (element == null) return false;
    return add(element);
  }

  bool remove(Object? element) {
    bool hasRemoved = super.remove(element);
    if (hasRemoved) {
      _changes.add(SetChange<E>.remove(element as E));
    }
    return hasRemoved;
  }

  void clear() {
    Iterable<E> removed = toList();
    super.clear();
    for (E el in removed) {
      _changes.add(SetChange<E>.remove(el));
    }
  }

  Stream<SetChange<E>> get onChange => _changes.stream;

  void bindBool(E element, Stream<bool> stream, [bool initial = false]) {
    if (initial) {
      add(element);
    } else {
      remove(element);
    }
    stream.listen((bool value) {
      if (value) {
        add(element);
      } else {
        remove(element);
      }
    });
  }

  void bindBoolValue(E element, RxValue<bool> other) {
    if (other.value == true) {
      add(element);
    } else {
      remove(element);
    }
    other.values.listen((bool? value) {
      if (value == true)
        add(element);
      else
        remove(element);
    });
  }

  void bindOneByIndexStream(Iterable<E> options, Stream<int> other,
      [int? initial]) {
    {
      int? value = initial;
      for (int i = 0; i < options.length; i++) {
        if (value == i)
          add(options.elementAt(i));
        else
          remove(options.elementAt(i));
      }
    }
    other.listen((int value) {
      for (int i = 0; i < options.length; i++) {
        if (value == i)
          add(options.elementAt(i));
        else
          remove(options.elementAt(i));
      }
    });
  }

  void bindOneByIndex(Iterable<E> options, RxValue<int> other) {
    {
      int? value = other.value;
      for (int i = 0; i < options.length; i++) {
        if (value == i) {
          add(options.elementAt(i));
        } else {
          remove(options.elementAt(i));
        }
      }
    }
    other.values.listen((int? value) {
      for (int i = 0; i < options.length; i++) {
        if (value == i) {
          add(options.elementAt(i));
        } else {
          remove(options.elementAt(i));
        }
      }
    });
  }

  Future<void> dispose() async {
    await _changes.close();
  }
}

class Classes extends RxSet<String> {
  Classes() : super();

  Classes.from(Iterable elements) : super.from(elements);

  Classes.union(Iterable<String> elements, [String? element])
      : super.union(elements, element);

  Classes.of(Iterable<String> elements) : super.of(elements);

  void bind(String class_, Stream<bool> changes) {
    changes.listen((bool has) {
      if (has)
        add(class_);
      else
        remove(class_);
    });
  }
}

enum SetOp { add, remove }

typedef dynamic SetChangeCallBack<E>(E element, SetOp isAdd, int pos);

class SetChange<E> {
  final E element;

  final SetOp op;

  SetChange(this.element, this.op);

  SetChange.add(this.element) : op = SetOp.add;

  SetChange.remove(this.element) : op = SetOp.remove;
}
