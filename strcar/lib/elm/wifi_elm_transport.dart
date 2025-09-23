import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'elm_transport.dart';

class WifiElmTransport implements ElmTransport {
  WifiElmTransport({required this.host, this.port = 35000});

  final String host;
  final int port;

  Socket? _socket;

  @override
  bool get isOpen => _socket != null;

  @override
  Future<void> open() async {
    if (_socket != null) return;
    _socket = await Socket.connect(host, port, timeout: const Duration(seconds: 3));
    _socket!.setOption(SocketOption.tcpNoDelay, true);
  }

  @override
  Future<void> close() async {
    await _socket?.flush();
    await _socket?.close();
    _socket = null;
  }

  @override
  Future<void> write(String data) async {
    final sock = _socket;
    if (sock == null) throw StateError('Socket not open');
    sock.add(utf8.encode(data));
    await sock.flush();
  }

  @override
  Future<String> readUntil(String terminator, {Duration timeout = const Duration(seconds: 3)}) async {
    final sock = _socket;
    if (sock == null) throw StateError('Socket not open');
    final completer = Completer<String>();
    final buffer = StringBuffer();
    late StreamSubscription<List<int>> sub;
    final timer = Timer(timeout, () {
      sub.cancel();
      if (!completer.isCompleted) completer.complete(buffer.toString());
    });
    sub = sock.listen((data) {
      buffer.write(utf8.decode(data, allowMalformed: true));
      if (buffer.toString().contains(terminator)) {
        timer.cancel();
        sub.cancel();
        if (!completer.isCompleted) {
          final text = buffer.toString();
          final idx = text.indexOf(terminator);
          completer.complete(idx >= 0 ? text.substring(0, idx) : text);
        }
      }
    }, onError: (e) {
      timer.cancel();
      sub.cancel();
      if (!completer.isCompleted) completer.completeError(e);
    }, onDone: () {
      timer.cancel();
      if (!completer.isCompleted) completer.complete(buffer.toString());
    }, cancelOnError: true);
    return completer.future;
  }
}

