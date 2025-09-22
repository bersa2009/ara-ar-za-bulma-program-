import 'dart:async';

import 'elm_transport.dart';

/// A simple scripted transport for tests. Provide a map from the command
/// (including trailing \r) to the response that should be returned before '>'.
class MockElmTransport implements ElmTransport {
  MockElmTransport({required Map<String, String> scripted})
      : _scripted = Map.of(scripted);

  final Map<String, String> _scripted;
  bool _open = false;
  String _lastCommand = '';

  @override
  Future<void> open() async {
    _open = true;
  }

  @override
  Future<void> close() async {
    _open = false;
  }

  @override
  bool get isOpen => _open;

  @override
  Future<void> write(String data) async {
    if (!_open) throw StateError('Transport not open');
    _lastCommand = data;
  }

  @override
  Future<String> readUntil(String terminator, {Duration timeout = const Duration(seconds: 3)}) async {
    if (!_open) throw StateError('Transport not open');
    final response = _scripted[_lastCommand] ?? '';
    return response;
  }
}

