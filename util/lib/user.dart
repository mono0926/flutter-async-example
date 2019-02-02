import 'package:faker/faker.dart';
import 'package:meta/meta.dart';

class User {
  User({
    @required this.id,
    @required this.name,
    @required this.email,
    @required this.createdAt,
  });
  final String id;
  final String name;
  final String email;
  final DateTime createdAt;

  User.fromJson(Map<String, dynamic> json)
      : id = json['id'] as String,
        name = json['name'] as String,
        email = json['email'] as String,
        createdAt = DateTime.parse(json["createdAt"] as String);

  factory User.random(Faker faker) {
    return User(
      id: faker.guid.guid(),
      name: faker.person.name(),
      email: faker.internet.email(),
      createdAt: DateTime.now(),
    );
  }

  @override
  String toString() {
    return 'User{id: $id, name: $name, email: $email, createdAt: $createdAt}';
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "name": name,
      "email": email,
      "createdAt": createdAt.toIso8601String(),
    };
  }
}
