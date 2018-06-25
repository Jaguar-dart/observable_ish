import 'dart:async';
import 'package:collection/collection.dart';
import 'observable_ish.dart';

class IfSet<E> extends DelegatingSet<E> implements Set<E> {
  IfSet() : super(new Set<E>());

  IfSet.from(Iterable elements) : super(Set<E>.from(elements));

  IfSet.union(Iterable<E> elements, [E element])
      : super(Set<E>.from(elements ?? <E>[])) {
    if (element != null) _add(element);
  }

  IfSet.of(Iterable<E> elements) : super(Set<E>.of(elements));

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
      _changes.add(SetChangeNotification<E>.add(element));
    }
    return ret;
  }

  bool addNonNull(E element) {
    if (element == null) return false;
    return add(element);
  }

  bool remove(Object element) {
    bool hasRemoved = super.remove(element);
    if (hasRemoved) {
      _changes.add(SetChangeNotification<E>.remove(element));
    }
    return hasRemoved;
  }

  void clear() {
    Iterable<E> removed = toList();
    super.clear();
    for (E el in removed) {
      _changes.add(SetChangeNotification<E>.remove(el));
    }
  }

  Stream<SetChangeNotification<E>> __onChange;

  Stream<SetChangeNotification<E>> get _onChange =>
      __onChange ??= _changes.stream.asBroadcastStream();

  Stream<SetChangeNotification<E>> get onChange {
    final ret = StreamController<SetChangeNotification<E>>();
    ret.addStream(_onChange);
    return ret.stream.asBroadcastStream();
  }

  final _changes = StreamController<SetChangeNotification<E>>();

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

  void bindBoolRx(E element, Reactive<bool> other) {
    if (other.value) {
      add(element);
    } else {
      remove(element);
    }
    other.values.listen((bool value) {
      if (value)
        add(element);
      else
        remove(element);
    });
  }

  void bindOneOf(Iterable<E> options, Stream<int> other, [int initial]) {
    {
      int value = initial;
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

  void bindOneOfRx(Iterable<E> options, Reactive<int> other) {
    {
      int value = other.value;
      for (int i = 0; i < options.length; i++) {
        if (value == i)
          add(options.elementAt(i));
        else
          remove(options.elementAt(i));
      }
    }
    other.values.listen((int value) {
      for (int i = 0; i < options.length; i++) {
        if (value == i)
          add(options.elementAt(i));
        else
          remove(options.elementAt(i));
      }
    });
  }
}

class Classes extends IfSet<String> {
  Classes() : super();

  Classes.from(Iterable elements) : super.from(elements);

  Classes.union(Iterable<String> elements, [String element])
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

enum SetChangeOp { add, remove }

typedef dynamic SetChangeCallBack<E>(E element, SetChangeOp isAdd, int pos);

class SetChangeNotification<E> {
  final E element;

  final SetChangeOp op;

  final DateTime time;

  SetChangeNotification(this.element, this.op, {DateTime time})
      : time = time ?? DateTime.now();

  SetChangeNotification.add(this.element, {DateTime time})
      : op = SetChangeOp.add,
        time = time ?? DateTime.now();

  SetChangeNotification.remove(this.element, {DateTime time})
      : op = SetChangeOp.remove,
        time = time ?? DateTime.now();
}
