import 'dart:async';
import 'dart:collection';

/// Observable list
class RxList<E> extends ListBase<E> implements List<E> {
  final List<E> _inner;

  final _changes = StreamController<ListChange<E>>.broadcast();

  /// Create a list. Behaves similar to `List<int>([int length])`
  RxList() : _inner = <E>[];

  RxList.filled(int length, E fill, {bool growable = false})
      : _inner = List<E>.filled(length, fill, growable: growable);

  RxList.from(Iterable<E> elements, {bool growable = true})
      : _inner = List<E>.from(elements, growable: growable);

  RxList.of(Iterable<E> elements, {bool growable = true})
      : _inner = List<E>.of(elements, growable: growable);

  RxList.generate(int length, E generator(int index), {bool growable = true})
      : _inner = List<E>.generate(length, generator, growable: growable);

  @override
  int get length => _inner.length;

  @override
  set length(int newLength) {
    _inner.length = newLength;
  }

  @override
  E operator [](int index) => _inner[index];

  operator []=(int index, E value) {
    _inner[index] = value;
    _changes.add(ListChange<E>.set(value, index));
  }

  void add(E element) {
    _inner.add(element);
    _changes.add(ListChange<E>.insert(element, length - 1));
  }

  void addAll(Iterable<E> elements) {
    int oldLength = length;
    _inner.addAll(elements);
    for (int i = 0; i < elements.length; i++) {
      _changes.add(ListChange<E>.insert(elements.elementAt(i), oldLength + i));
    }
  }

  void insert(int index, E element) {
    _inner.insert(index, element);
    _changes.add(ListChange<E>.insert(element, index));
  }

  bool remove(final Object? element) {
    int pos = indexOf(element as E);
    bool hasRemoved = _inner.remove(element);
    if (hasRemoved) {
      _changes.add(ListChange<E>.remove(element, pos));
    }
    return hasRemoved;
  }

  void removeWhere(bool test(E element)) {
    for (int i = 0; i < length; i++) {
      if (!test(_inner[i])) continue;

      final removed = _inner[i];
      _inner.removeAt(i);
      _changes.add(ListChange<E>.remove(removed, i));
      i--;
    }
  }

  void retainWhere(bool test(E element)) {
    for (int i = 0; i < length; i++) {
      if (test(_inner[i])) continue;

      final removed = _inner[i];
      _inner.removeAt(i);
      _changes.add(ListChange<E>.remove(removed, i));
      i--;
    }
  }

  void clear() {
    _inner.clear();
    _changes.add(ListChange<E>.clear());
  }

  /// A stream of record of changes to this list
  Stream<ListChange<E>> get onChange => _changes.stream;

  Future<void> dispose() async {
    await _changes.close();
  }
}

typedef ChildrenListComposer<S, E> = E Function(S value);

/// An observable list that is bound to another list [binding]
class BoundList<S, E> extends RxList<E> {
  final RxList<S> binding;

  final ChildrenListComposer<S, E> composer;

  BoundList(this.binding, this.composer) {
    for (S v in binding) {
      super.add(composer(v));
    }
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
