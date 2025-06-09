import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/api_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  final ApiService _apiService = ApiService();

  User? _user;
  bool _isLoading = false;
  bool _isLoggedIn = false;
  String? _error;

  // Getters
  User? get user => _user;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _isLoggedIn;
  String? get error => _error;
  bool get isReviewer => _user?.isReviewer ?? false;
  bool get isUser => _user?.isUser ?? false;

  // Initialize auth state
  Future<void> init() async {
    _setLoading(true);

    try {
      await _apiService.init();

      final isLoggedIn = await _authService.isLoggedIn();
      if (isLoggedIn) {
        final storedUser = await _authService.getStoredUser();
        final storedToken = await _authService.getStoredToken();

        if (storedUser != null && storedToken != null) {
          _user = storedUser;
          _isLoggedIn = true;
          _apiService.setToken(storedToken);

          // Try to refresh user data
          try {
            _user = await _authService.getCurrentUser();
          } catch (e) {
            // If refresh fails, keep stored user data
            debugPrint('Failed to refresh user data: $e');
          }
        }
      }
    } catch (e) {
      _setError('Failed to initialize auth: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Check auth status without notifying listeners during build
  Future<bool> checkAuthStatus() async {
    try {
      await _apiService.init();

      final isLoggedIn = await _authService.isLoggedIn();
      if (isLoggedIn) {
        final storedUser = await _authService.getStoredUser();
        final storedToken = await _authService.getStoredToken();

        if (storedUser != null && storedToken != null) {
          _user = storedUser;
          _isLoggedIn = true;
          _apiService.setToken(storedToken);

          // Try to refresh user data
          try {
            _user = await _authService.getCurrentUser();
          } catch (e) {
            // If refresh fails, keep stored user data
            debugPrint('Failed to refresh user data: $e');
          }

          return true;
        }
      }

      return false;
    } catch (e) {
      debugPrint('Failed to check auth status: $e');
      return false;
    }
  }

  // Login
  Future<bool> login(String email, String password) async {
    _setLoading(true);
    _clearError();

    try {
      final result = await _authService.login(email, password);
      
      if (result['success'] == true) {
        _user = result['user'];
        _isLoggedIn = true;
        notifyListeners();
        return true;
      } else {
        _setError('Login failed');
        return false;
      }
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Register
  Future<bool> register({
    required String nim,
    required String nama,
    required String email,
    required String password,
    String peran = 'pengguna',
    String? kodeRahasia,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final result = await _authService.register(
        nim: nim,
        nama: nama,
        email: email,
        password: password,
        peran: peran,
        kodeRahasia: kodeRahasia,
      );

      if (result['success'] == true) {
        // If registration includes auto-login (token and user), set logged in state
        if (result['token'] != null && result['user'] != null) {
          _user = result['user'];
          _isLoggedIn = true;
          notifyListeners();
        }
        return true;
      } else {
        String errorMessage = result['message'] ?? 'Registration failed';

        // Provide more user-friendly error messages
        if (errorMessage.contains('Network error')) {
          errorMessage = 'Tidak dapat terhubung ke server. Pastikan koneksi internet Anda stabil.';
        } else if (errorMessage.contains('Email sudah digunakan')) {
          errorMessage = 'Email sudah terdaftar. Silakan gunakan email lain atau login.';
        } else if (errorMessage.contains('NIM sudah digunakan')) {
          errorMessage = 'NIM sudah terdaftar. Silakan gunakan NIM lain atau login.';
        } else if (errorMessage.contains('Kode rahasia tidak valid')) {
          errorMessage = 'Kode rahasia peninjau tidak valid.';
        }

        _setError(errorMessage);
        return false;
      }
    } catch (e) {
      String errorMessage = e.toString().replaceAll('Exception: ', '');

      // Provide more user-friendly error messages
      if (errorMessage.contains('Network error')) {
        errorMessage = 'Tidak dapat terhubung ke server. Pastikan koneksi internet Anda stabil.';
      } else if (errorMessage.contains('Connection refused')) {
        errorMessage = 'Server tidak dapat dijangkau. Mencoba server alternatif...';
      }

      _setError(errorMessage);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Update profile
  Future<bool> updateProfile({
    required String nama,
    required String email,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final updatedUser = await _authService.updateProfile(
        nama: nama,
        email: email,
      );
      
      _user = updatedUser;
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Change password
  Future<bool> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      await _authService.changePassword(
        oldPassword: oldPassword,
        newPassword: newPassword,
      );
      
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Upload profile picture
  Future<bool> uploadProfilePicture(String base64Image) async {
    _setLoading(true);
    _clearError();

    try {
      final updatedUser = await _authService.uploadProfilePicture(base64Image);
      _user = updatedUser;
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Logout
  Future<void> logout() async {
    _setLoading(true);
    
    try {
      await _authService.logout();
    } catch (e) {
      debugPrint('Logout error: $e');
    } finally {
      _user = null;
      _isLoggedIn = false;
      _setLoading(false);
    }
  }

  // Update user profile picture URL
  void updateUserProfilePicture(String? profilePictureUrl) {
    if (_user != null) {
      _user = _user!.copyWith(profilePicture: profilePictureUrl);
      notifyListeners();
    }
  }

  // Refresh user data
  Future<void> refreshUser() async {
    if (!_isLoggedIn) return;

    try {
      _user = await _authService.getCurrentUser();
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to refresh user: $e');
    }
  }

  // Private methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }
}
