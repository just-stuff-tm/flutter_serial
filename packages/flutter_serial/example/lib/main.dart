import 'package:flutter/material.dart';
import 'package:flutter_serial/flutter_serial.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    const SerialConfig config = SerialConfig();

    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('flutter_serial example')),
        body: Center(
          child: Text('Default baud rate: ${config.baudRate}'),
        ),
      ),
    );
  }
}
