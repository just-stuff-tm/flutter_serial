# flutter_serial

`flutter_serial` is the public facade that consumers depend on. It proxies
all work through `FlutterSerialPlatform`, which is implemented by every
platform package in this workspace (`flutter_serial_linux`, 
`flutter_serial_windows`, `flutter_serial_macos`, etc.).

## Usage

Add the package to your pubspec (replace `^0.0.1` with the current version
before publishing):

```yaml
dependencies:
  flutter_serial: ^0.0.1
```

Import the facade and use `FlutterSerial` to enumerate ports or open a
connection:

```dart
import 'dart:typed_data';

import 'package:flutter_serial/flutter_serial.dart';

const serial = FlutterSerial();

void scanPorts() async {
  final devices = await serial.listDevices();
  for (final device in devices) {
    print('Found ${device.name} (${device.id})');
  }
}

Future<void> openPort(SerialDevice device) async {
  final connection = await serial.open(
    device,
    const SerialConfig(baudRate: 9600),
  );

  connection.input.listen((data) => print('Received ${data.length} bytes'));
  await connection.write(Uint8List.fromList([0x01, 0x02]));
  await connection.close();
}
```

`FlutterSerial` re-exports `SerialDevice`, `SerialConfig`, and `SerialConnection`
from `flutter_serial_platform_interface`, so they are available directly
after importing `package:flutter_serial/flutter_serial.dart`.

## Workspace notes

- Run `dart run melos bootstrap` from the repo root before working locally.
- Run `dart run melos exec -- flutter analyze` to enforce the zero-warnings policy.

