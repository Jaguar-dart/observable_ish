import 'package:observable_ish/observable_ish.dart';

class RxUser {
  final name = RxValue<String?>();
  final age = RxValue<int?>();
}

class User {
  final rx = RxUser();

  User({String? name, int? age}) {
    this.name = name;
    this.age = age;
  }

  String? get name => rx.name.value;
  set name(String? value) => rx.name.value = value;

  int? get age => rx.age.value;
  set age(int? value) => rx.age.value = value;
}

main() {
  final user = User(name: 'Messi', age: 30);
  user.age = 31;
  print(user.age);  // => 31
  print('---------');
  user.age = 32;
  user.rx.age.listen((int? v) => print(v));  // => 20, 25
  user.age = 33;
  user.age = 34;
  user.age = 35;
}