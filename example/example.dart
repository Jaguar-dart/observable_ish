import 'package:observable_ish/observable_ish.dart';

main() {
  final rxInts = RxValue<int>(5);
  print(rxInts.value);  // => 5
  rxInts.value = 10;
  rxInts.value = 15;
  rxInts.values.listen((int v) => print(v));  // => 15, 20, 25
  rxInts.value = 20;
  rxInts.value = 25;
}
