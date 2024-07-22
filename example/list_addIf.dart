import 'package:observable_ish/observable_ish.dart';

main() {
  final rxInts = RxList<int>();
  rxInts.onChange.listen((c) => print(c.element)); // => 5
  rxInts.add(5);
  rxInts.remove(5);
}
