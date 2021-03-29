import 'package:observable_ish/observable_ish.dart';

class RxUser {
  final name = RxValue<String>('');
  final age = RxValue<int>(0);
}

class User {
  final rx = RxUser();

  User({required String name, required int age}) {
    this.name = name;
    this.age = age;
  }

  String get name => rx.name.value;
  set name(String value) => rx.name.value = value;

  int get age => rx.age.value;
  set age(int value) => rx.age.value = value;
}

main() {
  final user = User(name: 'Messi', age: 30);
  user.age = 31;
  print(user.age); // => 31
  print('---------');
  user.age = 32;
  user.rx.age.listen((int v) => print(v)); // => 32, 33, 34, 35
  user.age = 33;
  user.age = 34;
  user.age = 35;
}
