import 'dart:convert';
import 'dart:isolate';

import 'package:firebase_performance/firebase_performance.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:util/user.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Flutter Demo',
      home: HomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: FutureBuilder<List<User>>(
        future: _fetchUsers(),
        builder: (context, snap) {
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final users = snap.data;
          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              return ListTile(
                key: ValueKey(user.id),
                title: Text(user.name),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {});
        },
        tooltip: 'Refresh',
        child: const Icon(Icons.refresh),
      ),
    );
  }
}

Future<List<User>> _fetchUsers() async {
  final response =
      await http.get('http://www.mocky.io/v2/5c55243c2f00005000bf758a');
  final stopwatch = Stopwatch()..start();
  final users = _parse(response.body);
  stopwatch.stop();
  print('elapsed: ${stopwatch.elapsedMilliseconds}');
  return users;
}

List<User> _parse(String body) {
  final trace = FirebasePerformance.instance.newTrace('parse_users')..start();
  final stopwatch = Stopwatch()..start();
  final json = (jsonDecode(body) as List).cast<Map<String, dynamic>>();
  final users = json.map((j) => User.fromJson(j)).toList();
  stopwatch.stop();
  trace.stop();
  print('parse elapsed: ${stopwatch.elapsedMilliseconds}');
  return users;
}

Future<List<User>> _fetchUsersCompute() async {
  final response =
      await http.get('http://www.mocky.io/v2/5c55243c2f00005000bf758a');
  final stopwatch = Stopwatch()..start();
  final users = await compute(_parse, response.body);
  stopwatch.stop();
  print('elapsed: ${stopwatch.elapsedMilliseconds}');
  return users;
}

Future<List<User>> _fetchUsersIsolate() async {
  final response =
      await http.get('http://www.mocky.io/v2/5c55243c2f00005000bf758a');
  final stopwatch = Stopwatch()..start();

  final receivePort = ReceivePort();
  await Isolate.spawn(_isolate, receivePort.sendPort);
  final sendPort = await receivePort.first as SendPort;
  final answer = ReceivePort();
  sendPort.send([response.body, answer.sendPort]);
  final users = await answer.first as List<User>;

  stopwatch.stop();
  print('elapsed: ${stopwatch.elapsedMilliseconds}');

  return users;
}

void _isolate(SendPort initialReplyTo) {
  final receivePort = ReceivePort();
  initialReplyTo.send(receivePort.sendPort);
  receivePort.listen((message) {
    final data = message[0] as String;
    final send = message[1] as SendPort;
    send.send(_parse(data));
  });
}
