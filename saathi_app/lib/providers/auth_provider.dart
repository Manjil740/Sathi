import 'package:flutter/foundation.dart';

import '../models/user.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  AuthProvider(this._authService);

  final AuthService _authService;
  SaathiUser? _user;
  bool _loading = false;

  SaathiUser? get user => _user ?? _authService.currentUser;
  bool get isAuthenticated => user != null;
  bool get isLoading => _loading;

  Future<void> signIn({required String phoneNumber, required String name}) async {
    _loading = true;
    notifyListeners();
    _user = await _authService.signInWithPhone(phoneNumber: phoneNumber, name: name);
    _loading = false;
    notifyListeners();
  }

  Future<void> verifyOtp(String otp) async {
    _loading = true;
    notifyListeners();
    await _authService.verifyOtp(otp);
    _user = _authService.currentUser;
    _loading = false;
    notifyListeners();
  }

  Future<void> markVerified() async {
    if (_user == null) {
      return;
    }
    _user = _user!.copyWith(isVerified: true);
    notifyListeners();
  }

  Future<void> logout() async {
    await _authService.signOut();
    _user = null;
    notifyListeners();
  }
}
