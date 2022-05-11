library observable_ish;

export 'emitter/emitter.dart';
export 'list/list.dart';
export 'map/map.dart';
export 'set/set.dart';
export 'value/value.dart';

/// A callback with argument [v] of type [T].
///
/// Intended to listen to events emitted by [Emitter].
typedef void ValueCallback<T>(T v);

/// A callback with no arguments.
///
/// Intended to listen to events emitted by [Emitter].
typedef dynamic Callback();

typedef bool Condition();

typedef T ValueGetter<T>();

typedef void ValueSetter<T>(T val);
