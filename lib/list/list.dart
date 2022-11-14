import 'dart:async';
import 'package:collection/collection.dart';
import 'package:observable_ish/observable_ish.dart';

/// Observable list
class RxList<E> extends DelegatingList<E> implements List<E> {
  final _changes = StreamController<ListChange<E>>.broadcast();

  /// Create a list. Behaves similar to `List<int>([int length])`
  RxList() : super(<E>[]);

  RxList.filled(int length, E fill, {bool growable: false})
      : super(List<E>.filled(length, fill, growable: growable));

  RxList.from(Iterable<E> elements, {bool growable: true})
      : super(List<E>.from(elements, growable: growable));

  RxList.of(Iterable<E> elements, {bool growable: true})
      : super(List<E>.of(elements, growable: growable));

  RxList.generate(int length, E generator(int index), {bool growable: true})
      : super(List<E>.generate(length, generator, growable: growable));

  /// Adds [element] only if [condition] resolves to true.
  void addIf(/* bool | Condition */ condition, E element) {
    if (condition is Condition) condition = condition();
    if (condition is bool && condition) add(element);
  }

  /// Adds all [elements] only if [condition] resolves to true.
  void addAllIf(/* bool | Condition */ condition, Iterable<E> elements) {
    if (condition is Condition) condition = condition();
    if (condition is bool && condition) addAll(elements);
  }

  operator []=(int index, E value) {
    super[index] = value;
    _changes.add(ListChange<E>.set(value, index));
  }

  void add(E element) {
    super.add(element);
    _changes.add(ListChange<E>.insert(element, length - 1));
  }

  void addAll(Iterable<E> elements) {
    super.addAll(elements);
    elements.forEach(
        (element) => _changes.add(ListChange<E>.insert(element, length - 1)));
  }

  /// Adds only if [element] is not null.
  void addNonNull(E element) {
    if (element != null) add(element);
  }

  void insert(int index, E element) {
    super.insert(index, element);
    _changes.add(ListChange<E>.insert(element, index));
  }

  bool remove(final Object? element) {
    int pos = indexOf(element as E);
    bool hasRemoved = super.remove(element);
    if (hasRemoved) {
      _changes.add(ListChange<E>.remove(element, pos));
    }
    return hasRemoved;
  }

  void clear() {
    super.clear();
    _changes.add(ListChange<E>.clear());
  }

  /// Replaces all existing elements of this list with [element]
  void assign(E element) {
    clear();
    add(element);
  }

  /// Replaces all existing elements of this list with [elements]
  void assignAll(Iterable<E> elements) {
    clear();
    addAll(elements);
  }

  /// A stream of record of changes to this list
  Stream<ListChange<E>> get onChange => _changes.stream;

  Future<void> dispose() async {
    await _changes.close();
  }
}

typedef E ChildrenListComposer<S, E>(S value);

/// An observable list that is bound to another list [binding]
class BoundList<S, E> extends RxList<E> {
  final RxList<S> binding;

  final ChildrenListComposer<S, E> composer;

  BoundList(this.binding, this.composer) {
    for (S v in binding) super.add(composer(v));
    binding.onChange.listen((ListChange<S> n) {
      if (n.op == ListOp.add) {
        insert(n.pos!, composer(n.element!));
      } else if (n.op == ListOp.remove) {
        removeAt(n.pos!);
      } else if (n.op == ListOp.clear) {
        clear();
      }
    });
  }
}

/// Change operation
enum ListOp { add, remove, clear, set }

/// A record of change in a [RxList]
class ListChange<E> {
  final E? element;

  final ListOp op;

  final int? pos;

  ListChange(this.element, this.op, this.pos);

  ListChange.insert(this.element, this.pos) : op = ListOp.add;

  ListChange.set(this.element, this.pos) : op = ListOp.set;

  ListChange.remove(this.element, this.pos) : op = ListOp.remove;

  ListChange.clear()
      : op = ListOp.clear,
        pos = null,
        element = null;
}
