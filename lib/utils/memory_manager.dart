import 'dart:async';

class MemoryManager {
  static final Map<String, Timer> _timers = {};
  static final Map<String, StreamSubscription> _subscriptions = {};

  // Timer yönetimi
  static void registerTimer(String key, Timer timer) {
    cancelTimer(key);
    _timers[key] = timer;
  }

  static void cancelTimer(String key) {
    _timers[key]?.cancel();
    _timers.remove(key);
  }

  static void cancelAllTimers() {
    for (final timer in _timers.values) {
      timer.cancel();
    }
    _timers.clear();
  }

  // Stream subscription yönetimi
  static void registerSubscription(String key, StreamSubscription subscription) {
    cancelSubscription(key);
    _subscriptions[key] = subscription;
  }

  static void cancelSubscription(String key) {
    _subscriptions[key]?.cancel();
    _subscriptions.remove(key);
  }

  static void cancelAllSubscriptions() {
    for (final subscription in _subscriptions.values) {
      subscription.cancel();
    }
    _subscriptions.clear();
  }

  // Tüm kaynakları temizle
  static void dispose() {
    cancelAllTimers();
    cancelAllSubscriptions();
  }

  // Debug bilgisi
  static Map<String, dynamic> getStatus() {
    return {
      'active_timers': _timers.length,
      'active_subscriptions': _subscriptions.length,
      'timer_keys': _timers.keys.toList(),
      'subscription_keys': _subscriptions.keys.toList(),
    };
  }
}