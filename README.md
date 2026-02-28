# flutter_serial

A Flutter serial communication monorepo managed with [Melos](https://melos.invertase.dev/).

This repository contains the core `flutter_serial` plugin and platform-specific implementations.

## Packages

- `packages/flutter_serial` – federated plugin entrypoint.
- `packages/flutter_serial_android` – Android implementation.
- `packages/flutter_serial_ios` – iOS implementation.
- `packages/flutter_serial_linux` – Linux implementation.
- `packages/flutter_serial_macos` – macOS implementation.
- `packages/flutter_serial_web` – Web implementation.
- `packages/flutter_serial_windows` – Windows implementation.
- `packages/flutter_serial_platform_interface` – shared platform interface.

## Getting started

1. Install Flutter and Dart.
2. From the workspace root install dependencies:
   ```powershell
   dart pub get
   ```
3. Bootstrap via Melos (no global activate or PATH dependency):
   ```powershell
   dart run melos bootstrap
   ```
4. Run the analyzer test:
   ```powershell
   dart run melos exec -- flutter analyze
   ```

## Usage

Use the federated package from pubspec:

```yaml
dependencies:
  flutter_serial: any
```

Then follow the package-level docs in `packages/flutter_serial/README.md`.

## License

This repository uses a **No-Use-Without-Attribution** license. See [LICENSE](./LICENSE).
