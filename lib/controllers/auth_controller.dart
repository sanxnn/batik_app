import 'package:flutter/material.dart';

import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../core/network/api_client.dart';


class AuthController extends ChangeNotifier {
  final AuthService _authService = AuthService();

  UserModel? _user;
  bool _isLoading = false;
  String? _errorMessage;
  Map<String, dynamic>? _validationErrors;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  Map<String, dynamic>? get validationErrors => _validationErrors;
  bool get isLoggedIn => _user != null;

  // --- LOGIN ---
  Future<bool> login(String email, String password) async {
    _setLoading(true);
    final result = await _authService.login(email, password);
    _setLoading(false);

    if (result.isSuccess) {
      _user = result.data;
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

  // --- RESET PASSWORD ---
  Future<bool> resetPassword({
    required String email,
    required String otp,
    required String password,
    required String passwordConfirmation,
  }) async {
    _setLoading(true);
    final result = await _authService.resetPassword(
      email: email,
      otp: otp,
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
      _clearError();
      return true;
    } else {
      _setError(result.message, result.errors);
      return false;
    }
  }


  /// Dipanggil dari SplashView
  Future<String> determineInitialRoute() async {
    final token = ApiClient.instance.prefs?.getString('token');

    if (token == null || token.isEmpty) {
      return '/login';
    }

    final result = await _authService.getMe();

    if (result.isSuccess && result.data != null) {
      _user = result.data;

      if (!result.data!.isEmailVerified) {
        return '/verify-email';
      }

      return '/home';
    } else {
      await ApiClient.instance.prefs?.remove('token');
      return '/login';
    }
  }

  // --- LOGOUT ---
  Future<void> logout() async {
    _setLoading(true);
    await _authService.logout();
    _user = null;
    _setLoading(false);
  }

  // --- HELPERS ---
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
