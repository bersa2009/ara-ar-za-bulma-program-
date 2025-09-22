import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:strcar/core/connection_manager.dart';

void main() {
  test('connection state updates', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final state0 = container.read(connectionStateProvider);
    expect(state0.scanning, false);
    container.read(connectionStateProvider.notifier).state = const ConnectionStateModel(scanning: true);
    final state1 = container.read(connectionStateProvider);
    expect(state1.scanning, true);
  });
}