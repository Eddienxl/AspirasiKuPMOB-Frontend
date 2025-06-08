import 'package:flutter/foundation.dart';
import '../models/category_model.dart';
import '../services/api_service.dart';
import '../utils/constants.dart';

class CategoryProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<CategoryModel> _categories = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  List<CategoryModel> get categories => _categories;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Load categories
  Future<void> loadCategories() async {
    if (_categories.isNotEmpty) return; // Don't reload if already loaded

    _setLoading(true);
    _clearError();

    try {
      final response = await _apiService.get(AppConstants.categoryEndpoint);

      List<dynamic> categoryData = [];

      if (response is List) {
        categoryData = response;
      } else if (response is Map<String, dynamic> && response.containsKey('data') && response['data'] is List) {
        categoryData = response['data'] as List<dynamic>;
      } else {
        // If API fails, use fallback categories
        _categories = _createFallbackCategories();
        _categories.sort((a, b) => a.id.compareTo(b.id));
        notifyListeners();
        return;
      }

      // Convert API data to CategoryModel with emoji mapping
      _categories = categoryData.map((json) {
        final categoryJson = json as Map<String, dynamic>;

        // Add emoji from constants if not present
        if (categoryJson['emoji'] == null) {
          categoryJson['emoji'] = AppConstants.getCategoryEmoji(categoryJson['id'] as int);
        }

        return CategoryModel.fromJson(categoryJson);
      }).toList();

      // Sort categories by ID
      _categories.sort((a, b) => a.id.compareTo(b.id));

      notifyListeners();
    } catch (e) {
      debugPrint('Failed to load categories from API: $e');
      // Use fallback categories if API fails
      _categories = _createFallbackCategories();
      _categories.sort((a, b) => a.id.compareTo(b.id));
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  // Create fallback categories from constants
  List<CategoryModel> _createFallbackCategories() {
    return AppConstants.categories.entries.map((entry) {
      return CategoryModel(
        id: entry.key,
        nama: entry.value['name']!,
        emoji: entry.value['emoji']!,
      );
    }).toList();
  }

  // Get category by ID
  CategoryModel? getCategoryById(int id) {
    try {
      return _categories.firstWhere((category) => category.id == id);
    } catch (e) {
      return null;
    }
  }

  // Get category name by ID
  String getCategoryName(int id) {
    final category = getCategoryById(id);
    return category?.nama ?? AppConstants.getCategoryName(id);
  }

  // Get category emoji by ID
  String getCategoryEmoji(int id) {
    final category = getCategoryById(id);
    return category?.emoji ?? AppConstants.getCategoryEmoji(id);
  }

  // Get category display name by ID
  String getCategoryDisplay(int id) {
    final category = getCategoryById(id);
    return category?.displayName ?? AppConstants.getCategoryDisplay(id);
  }

  // Create new category (admin only)
  Future<bool> createCategory({
    required String nama,
    String? emoji,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final data = {
        'nama': nama,
        if (emoji != null) 'emoji': emoji,
      };

      final response = await _apiService.post(AppConstants.categoryEndpoint, data);
      
      if (response['id'] != null) {
        // Add new category to the list
        final newCategory = CategoryModel.fromJson(response);
        _categories.add(newCategory);
        _categories.sort((a, b) => a.id.compareTo(b.id));
        notifyListeners();
        return true;
      }
      
      return false;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Update category (admin only)
  Future<bool> updateCategory({
    required int id,
    required String nama,
    String? emoji,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final data = {
        'nama': nama,
        if (emoji != null) 'emoji': emoji,
      };

      final response = await _apiService.put('${AppConstants.categoryEndpoint}/$id', data);
      
      // Update category in the list
      final index = _categories.indexWhere((category) => category.id == id);
      if (index != -1) {
        _categories[index] = CategoryModel.fromJson(response);
        notifyListeners();
      }
      
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Delete category (admin only)
  Future<bool> deleteCategory(int id) async {
    _setLoading(true);
    _clearError();

    try {
      await _apiService.delete('${AppConstants.categoryEndpoint}/$id');
      
      // Remove category from the list
      _categories.removeWhere((category) => category.id == id);
      notifyListeners();
      
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Clear categories
  void clearCategories() {
    _categories.clear();
    notifyListeners();
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
