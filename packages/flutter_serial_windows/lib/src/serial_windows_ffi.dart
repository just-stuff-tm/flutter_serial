import 'dart:async';
import 'dart:ffi';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:ffi/ffi.dart';
import 'package:flutter_serial_platform_interface/flutter_serial_platform_interface.dart';

final DynamicLibrary _kernel32 = DynamicLibrary.open('kernel32.dll');

typedef _CreateFileC = IntPtr Function(
  Pointer<Utf16>,
  Uint32,
  Uint32,
  Pointer<Void>,
  Uint32,
  Uint32,
  IntPtr,
);
typedef _CreateFileD = int Function(
  Pointer<Utf16>,
  int,
  int,
  Pointer<Void>,
  int,
  int,
  int,
);

typedef _ReadFileC = Int32 Function(
  IntPtr,
  Pointer<Uint8>,
  Uint32,
  Pointer<Uint32>,
  Pointer<Void>,
);
typedef _ReadFileD = int Function(
  int,
  Pointer<Uint8>,
  int,
  Pointer<Uint32>,
  Pointer<Void>,
);

typedef _WriteFileC = Int32 Function(
  IntPtr,
  Pointer<Uint8>,
  Uint32,
  Pointer<Uint32>,
  Pointer<Void>,
);
typedef _WriteFileD = int Function(
  int,
  Pointer<Uint8>,
  int,
  Pointer<Uint32>,
  Pointer<Void>,
);

typedef _CloseHandleC = Int32 Function(IntPtr);
typedef _CloseHandleD = int Function(int);

final _CreateFileD _createFile =
    _kernel32.lookupFunction<_CreateFileC, _CreateFileD>('CreateFileW');
final _ReadFileD _readFile =
    _kernel32.lookupFunction<_ReadFileC, _ReadFileD>('ReadFile');
final _WriteFileD _writeFile =
    _kernel32.lookupFunction<_WriteFileC, _WriteFileD>('WriteFile');
final _CloseHandleD _closeHandle =
    _kernel32.lookupFunction<_CloseHandleC, _CloseHandleD>('CloseHandle');

const int _genericRead = 0x80000000;
const int _genericWrite = 0x40000000;
const int _openExisting = 3;
const int _fileAttributeNormal = 0x00000080;
const int _invalidHandleValue = -1;

List<String> scanDevices() {
  final List<String> devices = <String>[];

  for (int i = 1; i <= 32; i++) {
    final String path = 'COM$i';
    final String fullPath = '\\\\.\\$path';
    final Pointer<Utf16> ptr = fullPath.toNativeUtf16();
    final int handle = _createFile(
      ptr,
      _genericRead | _genericWrite,
      0,
      nullptr,
      _openExisting,
      _fileAttributeNormal,
      0,
    );
    calloc.free(ptr);

    if (handle != _invalidHandleValue) {
      devices.add(path);
      _closeHandle(handle);
    }
  }

  return devices;
}

class _ReaderArgs {
  const _ReaderArgs(this.handle, this.sendPort);

  final int handle;
  final SendPort sendPort;
}

class FfiSerialConnection implements SerialConnection {
  FfiSerialConnection(this._handle) {
    _startReader();
  }

  final int _handle;
  final StreamController<Uint8List> _controller = StreamController<Uint8List>();

  Isolate? _readerIsolate;
  ReceivePort? _receivePort;
  SendPort? _controlPort;
  final Completer<void> _doneCompleter = Completer<void>();
  bool _closed = false;

  @override
  Stream<Uint8List> get input => _controller.stream;

  void _startReader() {
    _receivePort = ReceivePort();
    _receivePort!.listen((Object? message) {
      if (message is Uint8List) {
        _controller.add(message);
        return;
      }

      if (message is List<Object?> && message.isNotEmpty) {
        if (message.first == 'control' &&
            message.length == 2 &&
            message[1] is SendPort) {
          _controlPort = message[1] as SendPort;
          return;
        }

        if (message.first == 'done') {
          if (!_doneCompleter.isCompleted) {
            _doneCompleter.complete();
          }
          if (!_controller.isClosed) {
            _controller.close();
          }
        }
      }
    });

    Isolate.spawn<_ReaderArgs>(
      _readerEntry,
      _ReaderArgs(_handle, _receivePort!.sendPort),
      errorsAreFatal: false,
    ).then((Isolate isolate) {
      _readerIsolate = isolate;
    });
  }

  static void _readerEntry(_ReaderArgs args) {
    bool running = true;
    final ReceivePort control = ReceivePort();
    control.listen((Object? msg) {
      if (msg == 'stop') {
        running = false;
      }
    });

    args.sendPort.send(<Object?>['control', control.sendPort]);

    final Pointer<Uint8> buffer = calloc<Uint8>(4096);
    final Pointer<Uint32> bytesRead = calloc<Uint32>();

    try {
      while (running) {
        final int ok = _readFile(args.handle, buffer, 4096, bytesRead, nullptr);
        if (ok == 0) {
          break;
        }

        final int count = bytesRead.value;
        if (count > 0) {
          args.sendPort.send(Uint8List.fromList(buffer.asTypedList(count)));
        }
      }
    } finally {
      calloc.free(buffer);
      calloc.free(bytesRead);
      control.close();
      args.sendPort.send(<Object?>['done']);
    }
  }

  @override
  Future<int> write(Uint8List data) async {
    final Pointer<Uint8> ptr = calloc<Uint8>(data.length);
    final Pointer<Uint32> written = calloc<Uint32>();

    try {
      ptr.asTypedList(data.length).setAll(0, data);
      final int ok = _writeFile(_handle, ptr, data.length, written, nullptr);
      if (ok == 0) {
        return -1;
      }
      return written.value;
    } finally {
      calloc.free(ptr);
      calloc.free(written);
    }
  }

  @override
  Future<void> close() async {
    if (_closed) return;
    _closed = true;

    _controlPort?.send('stop');
    _closeHandle(_handle);

    try {
      await _doneCompleter.future.timeout(const Duration(milliseconds: 500));
    } on TimeoutException {
      _readerIsolate?.kill(priority: Isolate.immediate);
    }

    _receivePort?.close();
    if (!_controller.isClosed) {
      await _controller.close();
    }
  }
}

FfiSerialConnection openSerial(String port) {
  final String fullPath = '\\\\.\\$port';
  final Pointer<Utf16> ptr = fullPath.toNativeUtf16();

  try {
    final int handle = _createFile(
      ptr,
      _genericRead | _genericWrite,
      0,
      nullptr,
      _openExisting,
      _fileAttributeNormal,
      0,
    );

    if (handle == _invalidHandleValue) {
      throw Exception('Failed to open serial port $port');
    }

    return FfiSerialConnection(handle);
  } finally {
    calloc.free(ptr);
  }
}
