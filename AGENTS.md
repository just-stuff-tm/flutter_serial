# AGENTS.md

# flutter_serial – Federated Serial Plugin

This repository implements a production-grade, federated Flutter serial
communication plugin with symmetric desktop FFI backends and mobile/web
adapters.

The goal of this repository is:

• Cross-platform parity
• Zero analyzer warnings
• Zero native memory leaks
• Deterministic shutdown behavior
• Clean isolate lifecycle
• Production-safe FFI usage
• CI-safe builds
• Upstream-ready architecture

-------------------------------------------------------------------------------

# MONOREPO STRUCTURE

Root:
  melos.yaml

packages/
  flutter_serial/                     (app-facing package)
  flutter_serial_platform_interface/  (API contract)
  flutter_serial_linux/
  flutter_serial_windows/
  flutter_serial_macos/
  flutter_serial_android/
  flutter_serial_ios/
  flutter_serial_web/

example/

All packages must build independently.

-------------------------------------------------------------------------------

# NON-NEGOTIABLE RULES

## 1) ZERO WARNINGS POLICY

The following must always pass:

    melos exec -- flutter analyze

No informational, lint, hint, or warning messages are allowed.
Fix the cause — do not suppress the rule.

-------------------------------------------------------------------------------

## 2) NO NATIVE MEMORY LEAKS

Every native allocation must have a deterministic free:

Linux:
    malloc → free
    calloc → free
    realloc → free
    scan lists must have matching cleanup API

Windows:
    HANDLE → CloseHandle
    DCB / COMMTIMEOUTS calloc → free

Never rely on GC to clean native memory.

-------------------------------------------------------------------------------

## 3) ISOLATE SAFETY

Blocking OS calls must NEVER run on UI isolate.

Serial read loops MUST:
    • Run in background isolate
    • Support deterministic shutdown
    • Use control channel or atomic running flag
    • Close gracefully

Close sequence must:

    1. Signal isolate stop
    2. Close native handle / fd
    3. Kill isolate if necessary
    4. Close StreamController

No infinite loops.
No race conditions.
No orphan isolates.

-------------------------------------------------------------------------------

## 4) PLATFORM PARITY REQUIREMENT

Desktop platforms must provide equivalent behavior.

Linux ↔ Windows ↔ macOS must support:

    • Baud configuration
    • Clean open
    • Clean close
    • Deterministic read exit
    • Stream<Uint8List> input
    • write(Uint8List)

If a feature exists on one desktop platform,
it must exist on the others unless impossible.

-------------------------------------------------------------------------------

## 5) WINDOWS REQUIREMENTS

Windows backend must:

    • Use CreateFileW with "\\\\.\\COMX"
    • Configure DCB via GetCommState / SetCommState
    • Configure COMMTIMEOUTS
    • Use deterministic read behavior
    • Always CloseHandle
    • Never leak HANDLEs

No implicit defaults. Baud must be applied.

-------------------------------------------------------------------------------

## 6) LINUX REQUIREMENTS

Linux backend must:

    • Use termios raw mode
    • Map baud explicitly
    • Properly free scan lists
    • Close fd deterministically

-------------------------------------------------------------------------------

## 7) MACOS REQUIREMENTS

macOS must:

    • Use termios for configuration
    • Use IOKit for enumeration
    • Follow Linux lifecycle symmetry

-------------------------------------------------------------------------------

## 8) WEB REQUIREMENTS

Web must use:

    navigator.serial (Web Serial API)
    Secure context only

Must clearly document browser support limitations.

-------------------------------------------------------------------------------

## 9) ANDROID REQUIREMENTS

Android must:

    • Use UsbManager
    • Use CDC-ACM where possible
    • Background reader thread
    • Request user permission
    • Never block main thread

-------------------------------------------------------------------------------

## 10) IOS REQUIREMENTS

iOS must:

    • Use ExternalAccessory
    • Clearly document MFi requirement
    • Gracefully throw unsupported if unavailable

-------------------------------------------------------------------------------

## 11) SERIAL API CONTRACT IS OWNED BY

    flutter_serial_platform_interface

No platform package may change API contract.
All modifications must begin at platform interface layer.

-------------------------------------------------------------------------------

## 12) NO ENGINE MODIFICATION POLICY

This repository must:

    NOT modify Flutter engine
    NOT modify Dart SDK
    NOT require depot_tools
    NOT require custom Flutter builds

This must remain a pure plugin solution.

-------------------------------------------------------------------------------

# CONTRIBUTION RULES

Every PR must include:

• Platform(s) modified
• Memory safety audit explanation
• Shutdown lifecycle verification
• Analyzer clean confirmation
• melos bootstrap success
• No TODO placeholders
• No debug prints
• No commented dead code

-------------------------------------------------------------------------------

# CI REQUIREMENTS (FUTURE)

Must validate:

Linux build
Windows build
Analyzer clean
Format clean
Unit tests pass

-------------------------------------------------------------------------------

# CODE QUALITY STANDARDS

• Prefer explicit types
• Avoid dynamic
• Avoid implicit nullability
• Always free native memory
• Never swallow errors silently unless documented
• Close every ReceivePort created
• Close every StreamController created
• Use const constructors where possible
• Run dart format .  and flutter analyze after any changes as well

-------------------------------------------------------------------------------

# DESIGN PHILOSOPHY

This plugin prioritizes:

Performance > Cleverness  
Correctness > Brevity  
Determinism > Convenience  
Explicit lifecycle > Implicit behavior  

-------------------------------------------------------------------------------

# FUTURE EXPANSION

After desktop stability:

1) macOS parity
2) Web Serial API
3) Android USB
4) iOS ExternalAccessory
5) CI pipeline
6) Integration tests

-------------------------------------------------------------------------------

END OF AGENTS DOCUMENT
