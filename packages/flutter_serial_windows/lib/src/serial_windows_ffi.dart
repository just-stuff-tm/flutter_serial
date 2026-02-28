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

typedef _CloseHandleC = Int32 Function(IntPtr);
typedef _CloseHandleD = int Function(int);

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

typedef _GetCommStateC = Int32 Function(IntPtr, Pointer<DCB>);
typedef _GetCommStateD = int Function(int, Pointer<DCB>);

typedef _SetCommStateC = Int32 Function(IntPtr, Pointer<DCB>);
typedef _SetCommStateD = int Function(int, Pointer<DCB>);

typedef _SetCommTimeoutsC = Int32 Function(IntPtr, Pointer<COMMTIMEOUTS>);
typedef _SetCommTimeoutsD = int Function(int, Pointer<COMMTIMEOUTS>);

final _createFile = _kernel32.lookupFunction<_CreateFileC, _CreateFileD>(
  'CreateFileW',
);
final _closeHandle =
    _kernel32.lookupFunction<_CloseHandleC, _CloseHandleD>('CloseHandle');
final _readFile =
    _kernel32.lookupFunction<_ReadFileC, _ReadFileD>('ReadFile');
final _writeFile =
    _kernel32.lookupFunction<_WriteFileC, _WriteFileD>('WriteFile');
final _getCommState =
    _kernel32.lookupFunction<_GetCommStateC, _GetCommStateD>('GetCommState');
final _setCommState =
    _kernel32.lookupFunction<_SetCommStateC, _SetCommStateD>('SetCommState');
final _setCommTimeouts = _kernel32
    .lookupFunction<_SetCommTimeoutsC, _SetCommTimeoutsD>('SetCommTimeouts');

const int genericRead = 0x80000000;
const int genericWrite = 0x40000000;
const int openExisting = 3;
const int fileAttributeNormal = 0x80;

base class DCB extends Struct {
  @Uint32()
  external int dcbLength;
  @Uint32()
  external int baudRate;
  @Uint32()
  external int flags;
  @Uint16()
  external int wReserved;
  @Uint16()
  external int xonLim;
  @Uint16()
  external int xoffLim;
  @Uint8()
  external int byteSize;
  @Uint8()
  external int parity;
  @Uint8()
  external int stopBits;
  @Uint8()
  external int wReserved1;
}

base class COMMTIMEOUTS extends Struct {
  @Uint32()
  external int readIntervalTimeout;
  @Uint32()
  external int readTotalTimeoutMultiplier;
  @Uint32()
  external int readTotalTimeoutConstant;
  @Uint32()
  external int writeTotalTimeoutMultiplier;
  @Uint32()
  external int writeTotalTimeoutConstant;
}

List<String> scanDevices() {
  final ports = <String>[];
  for (var i = 1; i <= 64; i++) {
    final name = 'COM$i';
    final path = '\\\\.\\$name';
    final ptr = path.toNativeUtf16();
    final handle = _createFile(
      ptr,
      genericRead | genericWrite,
      0,
      nullptr,
      openExisting,
      fileAttributeNormal,
      0,
    );
    calloc.free(ptr);
    if (handle != -1) {
      ports.add(name);
      _closeHandle(handle);
    }
  }
  return ports;
}

class _SerialConnectionImpl implements SerialConnection {
  final int _handle;
  bool _closed = false;

  final _controller = StreamController<Uint8List>();
  late final Isolate _reader;
  late final SendPort _controlPort;

  _SerialConnectionImpl(this._handle, int baud) {
    _configure(baud);
    _startReader();
  }

  @override
  Stream<Uint8List> get input => _controller.stream;

  void _configure(int baud) {
    final dcb = calloc<DCB>();
    dcb.ref.dcbLength = sizeOf<DCB>();

    if (_getCommState(_handle, dcb) == 0) {
      calloc.free(dcb);
      throw Exception('GetCommState failed');
    }

    dcb.ref.baudRate = baud;
    dcb.ref.byteSize = 8;
    dcb.ref.parity = 0;
    dcb.ref.stopBits = 0;

    if (_setCommState(_handle, dcb) == 0) {
      calloc.free(dcb);
      throw Exception('SetCommState failed');
    }

    final timeouts = calloc<COMMTIMEOUTS>();
    timeouts.ref.readIntervalTimeout = 50;
    timeouts.ref.readTotalTimeoutConstant = 50;
    timeouts.ref.readTotalTimeoutMultiplier = 0;
    timeouts.ref.writeTotalTimeoutMultiplier = 0;
    timeouts.ref.writeTotalTimeoutConstant = 0;

    _setCommTimeouts(_handle, timeouts);

    calloc.free(dcb);
    calloc.free(timeouts);
  }

  void _startReader() async {
    final ready = ReceivePort();
    _reader = await Isolate.spawn<_ReaderInit>(
      _readerEntry,
      _ReaderInit(_handle, ready.sendPort),
      errorsAreFatal: false,
    );
    _controlPort = await ready.first as SendPort;
  }

  static void _readerEntry(_ReaderInit init) {
    final handle = init.handle;
    final readyPort = init.readyPort;
    final control = ReceivePort();
    readyPort.send(control.sendPort);

    bool running = true;
    control.listen((msg) {
      if (msg == 'stop') {
        running = false;
      }
    });

    final buffer = calloc<Uint8>(4096);
    final bytesRead = calloc<Uint32>();

    try {
      while (running) {
        final ok = _readFile(handle, buffer, 4096, bytesRead, nullptr);
        if (ok == 0) continue;
        final count = bytesRead.value;
        if (count > 0) {
          final data = Uint8List.fromList(buffer.asTypedList(count));
          control.sendPort.send(data);
        }
      }
    } finally {
      calloc.free(buffer);
      calloc.free(bytesRead);
      control.close();
    }
  }

  @override
  Future<int> write(Uint8List data) async {
    final ptr = calloc<Uint8>(data.length);
    ptr.asTypedList(data.length).setAll(0, data);
    final written = calloc<Uint32>();
    final ok = _writeFile(_handle, ptr, data.length, written, nullptr);
    final result = ok == 0 ? -1 : written.value;
    calloc.free(written);
    calloc.free(ptr);
    return result;
  }

  @override
  Future<void> close() async {
    if (_closed) return;
    _closed = true;
    _controlPort.send('stop');
    _closeHandle(_handle);
    _reader.kill(priority: Isolate.immediate);
    await _controller.close();
  }
}

class _ReaderInit {
  final int handle;
  final SendPort readyPort;
  const _ReaderInit(this.handle, this.readyPort);
}

SerialConnection openSerial(String port, int baud) {
  final full = '\\\\.\\$port';
  final ptr = full.toNativeUtf16();
  final handle = _createFile(
    ptr,
    genericRead | genericWrite,
    0,
    nullptr,
    openExisting,
    fileAttributeNormal,
    0,
  );
  calloc.free(ptr);

  if (handle == -1) {
    throw Exception('Failed to open serial port $port');
  }

  return _SerialConnectionImpl(handle, baud);
}
