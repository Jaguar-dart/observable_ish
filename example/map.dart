import 'package:observable_ish/map/map.dart';

void main() {
  final map = RxMap();
  map['key1'] = 'value1';
  map['key2'] = 'value2';
  map.onChange.listen(print);
  map['key3'] = 'value3';
  map['key4'] = 'value4';
}
