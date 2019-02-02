import 'dart:convert';
import 'dart:io';

import 'package:faker/faker.dart';
import 'package:quiver/iterables.dart';
import 'package:util/user.dart';

void main() {
  final n = 100;
  final faker = Faker();
  final users = range(0, n).map((_) => User.random(faker));
  print(users);

  final json = jsonEncode(users.map((u) => u.toJson()).toList());
  print(json);
  File('util/output/users_$n.json').writeAsStringSync(json);
}
