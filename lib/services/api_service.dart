import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  String? _token;
  bool _useFallback = false; // Start with primary URL (localhost)

  // Get the appropriate API URL
  String get _apiUrl {
    final url = _useFallback ? AppConstants.fallbackApiUrl : AppConstants.apiUrl;
    debugPrint('🌐 Using API URL: $url (fallback: $_useFallback)');
    return url;
  }

  // Initialize token from storage
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString(AppConstants.tokenKey);
  }

  // Set token
  void setToken(String token) {
    _token = token;
  }

  // Clear token
  void clearToken() {
    _token = null;
  }

  // Test connection to server
  Future<bool> testConnection() async {
    try {
      final url = Uri.parse(_useFallback ? AppConstants.fallbackUrl : AppConstants.baseUrl);
      final response = await http.get(url).timeout(const Duration(seconds: 5));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // Get headers with authentication
  Map<String, String> get _headers {
    final headers = {
      'Content-Type': 'application/json',
    };
    
    if (_token != null) {
      headers['Authorization'] = 'Bearer $_token';
    }
    
    return headers;
  }

  // Generic GET request
  Future<Map<String, dynamic>> get(String endpoint) async {
    return await _makeRequest(() async {
      final url = Uri.parse('$_apiUrl$endpoint');
      return await http.get(url, headers: _headers);
    });
  }

  // Generic POST request
  Future<Map<String, dynamic>> post(String endpoint, Map<String, dynamic> data) async {
    return await _makeRequest(() async {
      final url = Uri.parse('$_apiUrl$endpoint');
      debugPrint('🚀 POST Request: $url');
      debugPrint('📦 POST Data: $data');
      return await http.post(
        url,
        headers: _headers,
        body: json.encode(data),
      );
    });
  }

  // Generic PUT request
  Future<Map<String, dynamic>> put(String endpoint, Map<String, dynamic> data) async {
    return await _makeRequest(() async {
      final url = Uri.parse('$_apiUrl$endpoint');
      return await http.put(
        url,
        headers: _headers,
        body: json.encode(data),
      );
    });
  }

  // Generic DELETE request
  Future<Map<String, dynamic>> delete(String endpoint) async {
    return await _makeRequest(() async {
      final url = Uri.parse('$_apiUrl$endpoint');
      return await http.delete(url, headers: _headers);
    });
  }

  // Make request with fallback logic
  Future<Map<String, dynamic>> _makeRequest(Future<http.Response> Function() requestFunction) async {
    debugPrint('Making request to: $_apiUrl');
    try {
      final response = await requestFunction();
      debugPrint('Request successful: ${response.statusCode}');
      return _handleResponse(response);
    } catch (e) {
      debugPrint('Request failed: $e');
      // If primary server fails, try fallback
      if (!_useFallback && (e.toString().contains('Connection refused') ||
          e.toString().contains('Network is unreachable') ||
          e.toString().contains('Failed host lookup') ||
          e.toString().contains('XMLHttpRequest error') ||
          e.toString().contains('502') ||
          e.toString().contains('Application failed to respond'))) {

        debugPrint('Primary server failed, trying fallback server...');
        _useFallback = true;

        try {
          final response = await requestFunction();
          return _handleResponse(response);
        } catch (fallbackError) {
          throw Exception('Network error: Both primary and fallback server failed. $fallbackError');
        }
      }

      throw Exception('Network error: $e');
    }
  }

  // Handle HTTP response
  Map<String, dynamic> _handleResponse(http.Response response) {
    final statusCode = response.statusCode;
    
    if (statusCode >= 200 && statusCode < 300) {
      // Success
      if (response.body.isEmpty) {
        return {'success': true};
      }
      
      try {
        return json.decode(response.body);
      } catch (e) {
        return {'success': true, 'data': response.body};
      }
    } else if (statusCode == 401) {
      // Unauthorized - clear token and throw
      clearToken();
      _clearStoredToken();
      throw Exception('Session expired. Please login again.');
    } else {
      // Error
      String errorMessage = 'HTTP Error: $statusCode';
      
      try {
        final errorData = json.decode(response.body);
        if (errorData['message'] != null) {
          errorMessage = errorData['message'];
        } else if (errorData['error'] != null) {
          errorMessage = errorData['error'];
        }
      } catch (e) {
        // Use default error message
      }
      
      throw Exception(errorMessage);
    }
  }

  // Clear stored token
  Future<void> _clearStoredToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.tokenKey);
    await prefs.remove(AppConstants.userKey);
  }
}
