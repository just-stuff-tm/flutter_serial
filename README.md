# flutter_serial

A federated Flutter serial communication workspace powered by [Melos](https://melos.invertase.dev/). This repository hosts the public-facing `flutter_serial` package, each desktop/mobile/web implementation, and per-platform example applications.

## Overview

- `flutter_serial` exposes the public facade (`FlutterSerial`) that proxies to the platform implementations.
- Each platform package (`flutter_serial_windows`, `flutter_serial_linux`, etc.) registers itself with the shared platform interface.
- Examples live next to their platform package to validate native behaviour while staying workspace-aware.

## Getting started

1. Fetch dependencies from the workspace root:
   ```powershell
   dart pub get
   ```
2. Bootstrap the packages (no global Melos install required):
   ```powershell
   dart run melos bootstrap
   ```
3. View workspace packages:
   ```powershell
   dart run melos list
   ```
4. Run the analyzer across the workspace:
   ```powershell
   dart run melos exec -- flutter analyze
   ```

## Usage

Developers should depend on the public facade only:

```yaml
dependencies:
  flutter_serial: ^0.0.1
```

Then import and use `FlutterSerial`:

```dart
import 'package:flutter_serial/flutter_serial.dart';

const serial = FlutterSerial();

final devices = await serial.listDevices();
final connection = await serial.open(devices.first, const SerialConfig(baudRate: 9600));
```

`FlutterSerial` re-exports all shared types from `flutter_serial_platform_interface`, so no platform package should be imported directly by consumer code.

## Workspace layout

```
Root
├── melos.yaml
├── packages/
│   ├── flutter_serial          ← facade entrypoint
│   ├── flutter_serial_platform_interface
│   ├── flutter_serial_linux
│   ├── flutter_serial_windows
│   ├── flutter_serial_macos
│   ├── flutter_serial_android
│   ├── flutter_serial_ios
│   └── flutter_serial_web
└── example/
```

## Contribution

Follow the rules in `AGENTS.md`, keep analyzer clean, dispose native resources deterministically, and ensure all platform contributions maintain parity with the shared API contract.

## License

This repository uses the **No-Use-Without-Attribution** license. See [LICENSE](./LICENSE) for details.
