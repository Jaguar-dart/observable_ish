import 'package:observable_ish/observable_ish.dart';

Future<void> main() async {
  final map = {'name': 'Bruce Wayne'};
  final rx = RxValue.proxyMapKey(map, 'name');
  print(rx.value);
  rx.onChange.listen((change) {
    print('Change: ${change.old} -> ${change.neu}');
  });
  rx.value = 'Batman';
  rx.value = 'I am Batman';
  print(rx.value);
}