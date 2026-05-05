import 'package:flutter/foundation.dart';

/// Notifies the GoRouter to re-evaluate its redirect when the local session
/// is cleared (unrecoverable 401 after token refresh attempt).
class SessionExpiredNotifier extends ChangeNotifier {
  void notifySessionExpired() => notifyListeners();
}
