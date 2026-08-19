import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/services/auth_service.dart';
import '../models/user_model.dart';

enum AuthStatus {
  uninitialized,
  loading,
  authenticated,
  unauthenticated,
}

class AppAuthProvider extends ChangeNotifier {
  final AuthService _authService;
  StreamSubscription<User?>? _authSubscription;

  UserModel? _currentUser;
  AuthStatus _status = AuthStatus.uninitialized;
  String? _errorMessage;
  bool _isSubmitting = false;

  AppAuthProvider({AuthService? authService})
      : _authService = authService ?? AuthService() {
    _initAuthListener();
  }

  // Getters
  UserModel? get currentUser => _currentUser;
  AuthStatus get status => _status;
  String? get errorMessage => _errorMessage;
  bool get isSubmitting => _isSubmitting;
  bool get isAuthenticated => _status == AuthStatus.authenticated && _currentUser != null;

  /// Inisialisasi listener Firebase Auth State
  void _initAuthListener() {
    _authSubscription = _authService.authStateChanges.listen((User? firebaseUser) async {
      if (firebaseUser == null) {
        _currentUser = null;
        _status = AuthStatus.unauthenticated;
        notifyListeners();
      } else {
        // Ambil data profile dan role dari Firestore
        await _fetchUserProfile(firebaseUser.uid);
      }
    });
  }

  /// Mengambil data user profile dari Firestore
  Future<void> _fetchUserProfile(String uid) async {
    try {
      _status = AuthStatus.loading;
      notifyListeners();

      final UserModel? profile = await _authService.getUserProfile(uid);
      if (profile != null) {
        _currentUser = profile;
        _status = AuthStatus.authenticated;
        _errorMessage = null;
      } else {
        _currentUser = null;
        _status = AuthStatus.unauthenticated;
        _errorMessage = 'Profil pengguna tidak ditemukan di database.';
      }
    } catch (e) {
      _currentUser = null;
      _status = AuthStatus.unauthenticated;
      _errorMessage = e.toString();
    } finally {
      notifyListeners();
    }
  }

  /// Fungsi Login untuk User
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _isSubmitting = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final UserModel user = await _authService.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      _currentUser = user;
      _status = AuthStatus.authenticated;
      _errorMessage = null;
      _isSubmitting = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '').trim();
      _isSubmitting = false;
      notifyListeners();
      return false;
    }
  }

  /// Refresh profil user terbaru
  Future<void> refreshProfile() async {
    if (_currentUser != null) {
      final updated = await _authService.getUserProfile(_currentUser!.uid);
      if (updated != null) {
        _currentUser = updated;
        notifyListeners();
      }
    }
  }

  /// Fungsi Logout
  Future<void> logout() async {
    await _authService.signOut();
    _currentUser = null;
    _status = AuthStatus.unauthenticated;
    _errorMessage = null;
    notifyListeners();
  }

  /// Membersihkan pesan error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}
