import '../models/user.dart';

class AuthService {
  AuthService();

  SaathiUser? _currentUser;

  SaathiUser? get currentUser => _currentUser;

  Future<SaathiUser> signInWithPhone({required String phoneNumber, required String name}) async {
    _currentUser = SaathiUser.demo().copyWith(
      phoneNumber: phoneNumber,
      name: name,
    );
    return _currentUser!;
  }

  Future<void> verifyOtp(String otp) async {
    if (_currentUser == null) {
      throw StateError('No active user');
    }
    if (otp.trim().length < 4) {
      throw StateError('Invalid OTP');
    }
    _currentUser = _currentUser!.copyWith(isVerified: true);
  }

  Future<void> signOut() async {
    _currentUser = null;
  }
}
