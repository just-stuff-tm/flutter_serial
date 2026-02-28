import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_serial/flutter_serial.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _status = 'Discovering serial ports...';
  static const _flutterSerial = FlutterSerial();

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  Future<void> initPlatformState() async {
    String status;
    try {
      final devices = await _flutterSerial.listDevices();
      status = 'Found ${devices.length} serial ports';
    } on PlatformException {
      status = 'Failed to list serial ports.';
    }

    if (!mounted) return;

    setState(() {
      _status = status;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Plugin example app')),
        body: Center(child: Text('$_status\n')),
      ),
    );
  }
}
