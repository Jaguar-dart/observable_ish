import 'package:observable_ish/observable_ish.dart';

main() {
  final rxInts = RxList<int>();
  rxInts.onChange.listen((c) => print(c.element)); // => 5
  rxInts.addIf(5 < 10, 5);
  rxInts.addIf(5 > 9, 9);
}
