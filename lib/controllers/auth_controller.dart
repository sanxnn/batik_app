import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../core/network/token_store.dart';

class AuthController extends ChangeNotifier {
  final AuthService _authService = AuthService();

  UserModel? _user;
  bool _isLoading = false;
  String? _errorMessage;
  Map<String, dynamic>? _validationErrors;
  String? _pendingVerificationEmail;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  Map<String, dynamic>? get validationErrors => _validationErrors;
  String? get pendingVerificationEmail => _pendingVerificationEmail;
  bool get isLoggedIn => _user != null;

  // --- LOGIN ---
  Future<bool> login(String email, String password) async {
    _setLoading(true);
    final result = await _authService.login(email, password);
    _setLoading(false);

    if (result.isSuccess) {
      _user = result.data;
      await _storePendingVerificationEmail(null);
      _clearError();
      return true;
    } else {
      _setError(result.message, result.errors);
      return false;
    }
  }

  // --- REGISTER ---
  Future<bool> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
    required String gender,
    required DateTime birthDate,
    String? phone,
  }) async {
    _setLoading(true);
    final result = await _authService.register(
      name: name,
      email: email,
      password: password,
      passwordConfirmation: passwordConfirmation,
      gender: gender,
      birthDate: birthDate,
      phone: phone,
    );
    _setLoading(false);

    if (result.isSuccess) {
      _user = result.data;
      await _storePendingVerificationEmail(email);
      _clearError();
      return true;
    } else {
      _setError(result.message, result.errors);
      return false;
    }
  }

  // --- VERIFY EMAIL ---
  Future<bool> verifyEmail(String email, String otp) async {
    _setLoading(true);
    final result = await _authService.verifyEmail(email, otp);
    _setLoading(false);

    if (result.isSuccess) {
      if (result.data != null) _user = result.data;
      await _storePendingVerificationEmail(null);
      _clearError();
      return true;
    } else {
      _setError(result.message);
      return false;
    }
  }

  // --- RESEND OTP ---
  Future<bool> resendOtp(String email) async {
    _setLoading(true);
    final result = await _authService.resendVerificationOtp(email);
    _setLoading(false);

    if (result.isSuccess) {
      _clearError();
      return true;
    } else {
      _setError(result.message);
      return false;
    }
  }

  // --- FORGOT PASSWORD ---
  Future<bool> forgotPassword(String email) async {
    _setLoading(true);
    final result = await _authService.forgotPassword(email);
    _setLoading(false);

    if (result.isSuccess) {
      _clearError();
      return true;
    } else {
      _setError(result.message);
      return false;
    }
  }

  // --- VERIFY PASSWORD RESET OTP (Step 2: Verifikasi OTP untuk dapat Token) ---
  Future<String?> verifyPasswordResetOtp(String email, String otp) async {
    _setLoading(true);
    final result = await _authService.verifyPasswordResetOtp(email, otp);
    _setLoading(false);

    if (result.isSuccess && result.data != null) {
      _clearError();
      // result.data berisi: {'email': '...', 'reset_token': '...', 'expires_in': 600}
      return result.data!['reset_token'] as String?;
    } else {
      _setError(result.message, result.errors);
      return null;
    }
  }

  // --- RESET PASSWORD ---
  Future<bool> resetPassword({
    required String email,
    required String resetToken,
    required String password,
    required String passwordConfirmation,
  }) async {
    _setLoading(true);
    final result = await _authService.resetPassword(
      email: email,
      resetToken: resetToken,
      password: password,
      passwordConfirmation: passwordConfirmation,
    );
    _setLoading(false);

    if (result.isSuccess) {
      _clearError();
      return true;
    } else {
      _setError(result.message, result.errors);
      return false;
    }
  }

  // --- CHECK AUTH STATUS ---
  Future<bool> checkAuthStatus() async {
    _setLoading(true);
    final result = await _authService.getMe();
    _setLoading(false);

    if (result.isSuccess) {
      _user = result.data;
      await _storePendingVerificationEmail(
        result.data?.isEmailVerified == false ? result.data!.email : null,
      );
      _clearError();
      return true;
    } else {
      _user = null;
      return false;
    }
  }

  // --- UPDATE PROFILE ---
  Future<bool> updateProfile({
    required String name,
    required String email,
    required String gender,
    required DateTime birthDate,
    String? phone,
  }) async {
    _setLoading(true);
    final result = await _authService.updateProfile(
      name: name,
      email: email,
      gender: gender,
      birthDate: birthDate,
      phone: phone,
    );
    _setLoading(false);

    if (result.isSuccess) {
      _user = result.data;
      await _storePendingVerificationEmail(
        result.data?.isEmailVerified == false ? result.data!.email : null,
      );
      _clearError();
      return true;
    } else {
      _setError(result.message, result.errors);
      return false;
    }
  }

  // --- LOGOUT ---
  Future<void> logout() async {
    _setLoading(true);
    await _authService.logout();
    _user = null;
    await _storePendingVerificationEmail(null);
    _setLoading(false);
  }

  // -- DETERMINE INITIAL ROUTE ---
  Future<String> determineInitialRoute() async {
    final token = TokenStore.instance.token;
    _pendingVerificationEmail = (await SharedPreferences.getInstance())
        .getString('pending_verification_email');

    if (token == null || token.isEmpty) {
      return _pendingVerificationEmail == null ? '/login' : '/verify-email';
    }

    final result = await _authService.getMe();

    if (result.isSuccess && result.data != null) {
      _user = result.data;

      if (!result.data!.isEmailVerified) {
        await _storePendingVerificationEmail(result.data!.email);
        return '/verify-email';
      }

      await _storePendingVerificationEmail(null);
      return '/home';
    } else {
      return _pendingVerificationEmail == null ? '/login' : '/verify-email';
    }
  }

  // --- HELPERS ---
  Future<void> _storePendingVerificationEmail(String? email) async {
    final preferences = await SharedPreferences.getInstance();
    _pendingVerificationEmail = email;
    if (email == null) {
      await preferences.remove('pending_verification_email');
    } else {
      await preferences.setString('pending_verification_email', email);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? message, [Map<String, dynamic>? errors]) {
    _errorMessage = message;
    _validationErrors = errors;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    _validationErrors = null;
    notifyListeners();
  }
}
