import 'package:observable_ish/observable_ish.dart';

main() {
  final rxInts = RxList<int>.from([1, 2, 3, 4]);
  rxInts.onChange.listen((c) => print(c.element)); // => 5
  rxInts.add(5);
  rxInts.remove(5);
  rxInts.removeWhere((e) => e.isEven);
}
