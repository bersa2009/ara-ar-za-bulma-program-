/// Transport abstraction for communicating with ELM327 devices over
/// BLE, Bluetooth Classic (SPP), or WiFi TCP sockets.
abstract class ElmTransport {
  /// Opens the underlying connection.
  Future<void> open();

  /// Closes the underlying connection.
  Future<void> close();

  /// Whether the connection is currently open.
  bool get isOpen;

  /// Writes a raw command string (typically ending with \r) to the transport.
  Future<void> write(String data);

  /// Reads until the given [terminator] sequence is encountered, then returns
  /// the accumulated text (including any line breaks but excluding the terminator).
  Future<String> readUntil(
    String terminator, {
    Duration timeout = const Duration(seconds: 3),
  });
}

