import 'package:flutter/material.dart';
import 'package:flutter_serial/flutter_serial.dart';

void main() {
  runApp(const MyApp());
}

const FlutterSerial _flutterSerial = FlutterSerial();

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final Future<List<SerialDevice>> _deviceList;

  @override
  void initState() {
    super.initState();
    _deviceList = _flutterSerial.listDevices();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('flutter_serial_linux example')),
        body: FutureBuilder<List<SerialDevice>>(
          future: _deviceList,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(
                child: Text('Failed to enumerate devices: ${snapshot.error}'),
              );
            }

            final devices = snapshot.data ?? <SerialDevice>[];
            if (devices.isEmpty) {
              return const Center(child: Text('No serial devices detected.'));
            }

            return ListView.builder(
              itemCount: devices.length,
              itemBuilder: (context, index) {
                final device = devices[index];
                return ListTile(
                  title: Text(device.name),
                  subtitle: Text(device.id),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
