import 'dart:async';
import 'dart:ffi';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:ffi/ffi.dart';
import 'package:flutter_serial_platform_interface/flutter_serial_platform_interface.dart';

final DynamicLibrary _lib = DynamicLibrary.process();

typedef _OpenC = Int32 Function(Pointer<Utf8>, Int32);
typedef _OpenD = int Function(Pointer<Utf8>, int);

typedef _ReadC = Int32 Function(Int32, Pointer<Uint8>, Int32);
typedef _ReadD = int Function(int, Pointer<Uint8>, int);

typedef _WriteC = Int32 Function(Int32, Pointer<Uint8>, Int32);
typedef _WriteD = int Function(int, Pointer<Uint8>, int);

typedef _CloseC = Int32 Function(Int32);
typedef _CloseD = int Function(int);

typedef _ScanC = Int32 Function(Pointer<Pointer<Pointer<Utf8>>>, Pointer<Int32>);
typedef _ScanD = int Function(Pointer<Pointer<Pointer<Utf8>>>, Pointer<Int32>);

typedef _FreeScanC = Void Function(Pointer<Pointer<Utf8>>, Int32);
typedef _FreeScanD = void Function(Pointer<Pointer<Utf8>>, int);

final _OpenD _open = _lib.lookupFunction<_OpenC, _OpenD>('open_serial');
final _ReadD _read = _lib.lookupFunction<_ReadC, _ReadD>('read_serial');
final _WriteD _write = _lib.lookupFunction<_WriteC, _WriteD>('write_serial');
final _CloseD _close = _lib.lookupFunction<_CloseC, _CloseD>('close_serial');
final _ScanD _scan = _lib.lookupFunction<_ScanC, _ScanD>('scan_devices');
final _FreeScanD _freeScan =
    _lib.lookupFunction<_FreeScanC, _FreeScanD>('free_scan_list');

List<String> scanDevices() {
  final outPtr = calloc<Pointer<Pointer<Utf8>>>();
  final countPtr = calloc<Int32>();

  final result = _scan(outPtr, countPtr);
  if (result != 0) {
    calloc.free(outPtr);
    calloc.free(countPtr);
    return <String>[];
  }

  final int count = countPtr.value;
  final Pointer<Pointer<Utf8>> listPtr = outPtr.value;

  final List<String> devices = <String>[];
  for (int i = 0; i < count; i++) {
    final Pointer<Utf8> ptr = listPtr[i];
    if (ptr.address != 0) {
      devices.add(ptr.toDartString());
    }
  }

  _freeScan(listPtr, count);
  calloc.free(outPtr);
  calloc.free(countPtr);

  return devices;
}

class _ReaderArgs {
  const _ReaderArgs(this.fd, this.sendPort);

  final int fd;
  final SendPort sendPort;
}

class FfiSerialConnection implements SerialConnection {
  FfiSerialConnection(this._fd) {
    _startReader();
  }

  final int _fd;
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
        final Object? tag = message.first;
        if (tag == 'control' && message.length == 2 && message[1] is SendPort) {
          _controlPort = message[1] as SendPort;
          return;
        }
        if (tag == 'done') {
          if (!_doneCompleter.isCompleted) {
            _doneCompleter.complete();
          }
          if (!_controller.isClosed) {
            _controller.close();
          }
          return;
        }
      }
    });

    Isolate.spawn<_ReaderArgs>(
      _readerEntry,
      _ReaderArgs(_fd, _receivePort!.sendPort),
      errorsAreFatal: false,
    ).then((Isolate isolate) {
      _readerIsolate = isolate;
    });
  }

  static void _readerEntry(_ReaderArgs args) {
    bool running = true;
    final ReceivePort control = ReceivePort();
    control.listen((Object? message) {
      if (message == 'stop') {
        running = false;
      }
    });

    args.sendPort.send(<Object?>['control', control.sendPort]);

    final Pointer<Uint8> buffer = calloc<Uint8>(4096);
    try {
      while (running) {
        final int readCount = _read(args.fd, buffer, 4096);
        if (readCount <= 0) {
          break;
        }
        args.sendPort.send(Uint8List.fromList(buffer.asTypedList(readCount)));
      }
    } finally {
      control.close();
      calloc.free(buffer);
      args.sendPort.send(<Object?>['done']);
    }
  }

  @override
  Future<int> write(Uint8List data) async {
    final Pointer<Uint8> ptr = calloc<Uint8>(data.length);
    try {
      ptr.asTypedList(data.length).setAll(0, data);
      return _write(_fd, ptr, data.length);
    } finally {
      calloc.free(ptr);
    }
  }

  @override
  Future<void> close() async {
    if (_closed) return;
    _closed = true;

    _controlPort?.send('stop');
    _close(_fd);

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

FfiSerialConnection openSerial(String path, int baudRate) {
  final Pointer<Utf8> nativePath = path.toNativeUtf8();
  try {
    final int fd = _open(nativePath, baudRate);
    if (fd < 0) {
      throw Exception('Failed to open serial port: $path');
    }
    return FfiSerialConnection(fd);
  } finally {
    calloc.free(nativePath);
  }
}
