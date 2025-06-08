import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../utils/constants.dart';
import 'api_service.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final ApiService _apiService = ApiService();

  // Login
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      print('🔐 AuthService: Attempting login for $email');
      final response = await _apiService.post(
        '${AppConstants.authEndpoint}/login',
        {
          'email': email,
          'kata_sandi': password,
        },
      );
      print('🔐 AuthService: Login response received: ${response.keys}');

      if (response['token'] != null && response['user'] != null) {
        // Save token and user data
        await _saveAuthData(response['token'], response['user']);
        _apiService.setToken(response['token']);
        
        return {
          'success': true,
          'user': User.fromJson(response['user']),
          'token': response['token'],
        };
      } else {
        throw Exception('Invalid response from server');
      }
    } catch (e) {
      throw Exception('Login failed: $e');
    }
  }

  // Register
  Future<Map<String, dynamic>> register({
    required String nim,
    required String nama,
    required String email,
    required String password,
    String peran = 'pengguna',
    String? kodeRahasia,
  }) async {
    try {
      print('📝 AuthService: Attempting register for $email');
      final data = {
        'nim': nim,
        'nama': nama,
        'email': email,
        'kata_sandi': password,
        'peran': peran,
      };

      if (kodeRahasia != null && kodeRahasia.isNotEmpty) {
        data['kodeRahasia'] = kodeRahasia;
      }

      print('📝 AuthService: Register data: $data');
      final response = await _apiService.post(
        '${AppConstants.authEndpoint}/register',
        data,
      );
      print('📝 AuthService: Register response received: ${response.keys}');

      // Check if registration was successful
      if (response['token'] != null && response['user'] != null) {
        // Save token and user data for auto-login
        await _saveAuthData(response['token'], response['user']);
        _apiService.setToken(response['token']);

        return {
          'success': true,
          'message': response['message'] ?? 'Registration successful',
          'user': User.fromJson(response['user']),
          'token': response['token'],
        };
      } else {
        return {
          'success': true,
          'message': response['message'] ?? 'Registration successful',
          'data': response,
        };
      }
    } catch (e) {
      print('📝 AuthService: Register error: $e');
      return {
        'success': false,
        'message': e.toString().replaceAll('Exception: ', ''),
      };
    }
  }

  // Get current user profile
  Future<User> getCurrentUser() async {
    try {
      final response = await _apiService.get('${AppConstants.authEndpoint}/profile');
      return User.fromJson(response);
    } catch (e) {
      throw Exception('Failed to get user profile: $e');
    }
  }

  // Update profile
  Future<User> updateProfile({
    required String nama,
    required String email,
  }) async {
    try {
      final response = await _apiService.put(
        '${AppConstants.authEndpoint}/ubah-profil',
        {
          'nama': nama,
          'email': email,
        },
      );

      final updatedUser = User.fromJson(response['user']);
      await _updateStoredUser(updatedUser);
      
      return updatedUser;
    } catch (e) {
      throw Exception('Failed to update profile: $e');
    }
  }

  // Change password
  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    try {
      await _apiService.put(
        '${AppConstants.authEndpoint}/ubah-kata-sandi',
        {
          'kata_sandi_lama': oldPassword,
          'kata_sandi_baru': newPassword,
        },
      );
    } catch (e) {
      throw Exception('Failed to change password: $e');
    }
  }

  // Upload profile picture
  Future<User> uploadProfilePicture(String base64Image) async {
    try {
      final response = await _apiService.put(
        '${AppConstants.authEndpoint}/upload-profile-picture',
        {
          'profile_picture': base64Image,
        },
      );

      final updatedUser = User.fromJson(response['user']);
      await _updateStoredUser(updatedUser);
      
      return updatedUser;
    } catch (e) {
      throw Exception('Failed to upload profile picture: $e');
    }
  }

  // Logout
  Future<void> logout() async {
    try {
      await _clearAuthData();
      _apiService.clearToken();
    } catch (e) {
      // Even if logout fails, clear local data
      await _clearAuthData();
      _apiService.clearToken();
    }
  }

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(AppConstants.tokenKey);
    return token != null && token.isNotEmpty;
  }

  // Get stored user
  Future<User?> getStoredUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(AppConstants.userKey);
    
    if (userJson != null) {
      try {
        final userData = json.decode(userJson);
        return User.fromJson(userData);
      } catch (e) {
        // Invalid user data, clear it
        await prefs.remove(AppConstants.userKey);
      }
    }
    
    return null;
  }

  // Get stored token
  Future<String?> getStoredToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(AppConstants.tokenKey);
  }

  // Save authentication data
  Future<void> _saveAuthData(String token, Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.tokenKey, token);
    await prefs.setString(AppConstants.userKey, json.encode(userData));
  }

  // Update stored user data
  Future<void> _updateStoredUser(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.userKey, json.encode(user.toJson()));
  }

  // Clear authentication data
  Future<void> _clearAuthData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.tokenKey);
    await prefs.remove(AppConstants.userKey);
  }
}
