import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttershare/pages/home.dart';

void main() {
  Firestore.instance.settings(timestampsInSnapshotsEnabled: true).then((_){
    print('Timestamp enabled in snapshots\n');
  },onError: (_) => print('Error enabled timestamp in snapshots\n'));
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Crossy App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.purple,
        accentColor: Colors.teal
      ),
      home: Home(),
    );
  }
}
