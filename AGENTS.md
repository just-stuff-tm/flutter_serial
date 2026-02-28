# AGENTS.md

# flutter_serial – Federated Serial Plugin

This repository implements a production-grade federated Flutter serial plugin
with fully symmetric desktop FFI backends.

-------------------------------------------------------------------------------

# MELos WORKSPACE USAGE (IMPORTANT)

This is a Melos-managed workspace.

All Melos commands MUST be run from the repository root:

    C:\projects\flutter_serial

DO NOT run from inside packages/ subdirectories.

-------------------------------------------------------------------------------

# CORRECT MELOS INVOCATION (MODERN)

Use modern invocation:

    dart run melos <command>

DO NOT use:

    dart pub global run melos:melos
    melos (unless explicitly available on PATH)

Preferred commands:

    dart run melos bootstrap
    dart run melos clean
    dart run melos list
    dart run melos exec -- flutter analyze

-------------------------------------------------------------------------------

# ANALYZER POLICY

The following must pass before any commit:

    dart run melos exec -- flutter analyze

No warnings. No hints. No suppression.

-------------------------------------------------------------------------------

# WORKSPACE STRUCTURE

Root:
  melos.yaml

packages/
  flutter_serial/
  flutter_serial_platform_interface/
  flutter_serial_linux/
  flutter_serial_windows/
  flutter_serial_macos/
  flutter_serial_android/
  flutter_serial_ios/
  flutter_serial_web/

example/

All packages must build independently.

-------------------------------------------------------------------------------

# ZERO WARNING POLICY

The entire workspace must be analyzer-clean.

No:
  • Lints
  • Hints
  • Info messages
  • TODO leftovers
  • Dead code

Fix issues — do not suppress them.

-------------------------------------------------------------------------------

# NATIVE MEMORY RULES

Every native allocation must have deterministic cleanup:

Linux:
    malloc/realloc/calloc -> free
    fd -> close()

Windows:
    HANDLE -> CloseHandle
    DCB/COMMTIMEOUTS calloc -> free

No exceptions.

-------------------------------------------------------------------------------

# ISOLATE RULES

Blocking I/O must not execute on UI isolate.

Serial read loops must:
  • Run inside background isolate
  • Support deterministic stop signal
  • Close resources in correct order

Shutdown order:

  1) Signal isolate stop
  2) Close native handle
  3) Kill isolate if necessary
  4) Close StreamController

-------------------------------------------------------------------------------

# PLATFORM PARITY REQUIREMENT

Desktop platforms (Linux, Windows, macOS) must provide:

  • Explicit baud configuration
  • Deterministic read termination
  • Symmetric lifecycle
  • Stream<Uint8List> interface
  • Clean shutdown

If added on one desktop platform, must be added to others.

-------------------------------------------------------------------------------

# WINDOWS REQUIREMENTS

Windows backend MUST:

  • Use CreateFileW with "\\\\.\\COMX"
  • Configure DCB via GetCommState / SetCommState
  • Configure COMMTIMEOUTS
  • Always CloseHandle
  • Never leak HANDLEs

-------------------------------------------------------------------------------

# LINUX REQUIREMENTS

Linux backend MUST:

  • Use termios raw mode
  • Map baud explicitly
  • Clean scan memory
  • Close fd deterministically

-------------------------------------------------------------------------------

# NO ENGINE MODIFICATION POLICY

This plugin must:

  • NOT modify Flutter engine
  • NOT modify Dart SDK
  • NOT require depot_tools
  • NOT require custom Flutter builds

-------------------------------------------------------------------------------

END OF DOCUMENT
