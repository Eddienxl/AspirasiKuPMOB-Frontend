import 'package:flutter/widgets.dart';
import '../models/post_model.dart';
import '../services/api_service.dart';
import '../utils/constants.dart';

class PostProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<Post> _posts = [];
  bool _isLoading = false;
  String? _error;
  String _currentFilter = 'semua';
  String _currentSort = 'terbaru';

  // Getters
  List<Post> get posts => _posts;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get currentFilter => _currentFilter;
  String get currentSort => _currentSort;

  // Load posts with filter and sort
  Future<void> loadPosts({
    String filter = 'semua',
    String sort = 'terbaru',
    bool refresh = false,
  }) async {
    if (refresh || _posts.isEmpty) {
      _setLoading(true);
    }
    
    _clearError();
    _currentFilter = filter;
    _currentSort = sort;

    try {
      final queryParams = <String, String>{};
      if (filter != 'semua') queryParams['filter'] = filter;
      if (sort != 'terbaru') queryParams['sort'] = sort;

      final queryString = queryParams.entries
          .map((e) => '${e.key}=${e.value}')
          .join('&');

      final endpoint = queryString.isNotEmpty
          ? '${AppConstants.postEndpoint}?$queryString'
          : AppConstants.postEndpoint;

      final response = await _apiService.get(endpoint);
      
      if (response is List) {
        _posts = (response as List).map((json) => Post.fromJson(json as Map<String, dynamic>)).toList();
      } else if (response is Map<String, dynamic> && response.containsKey('data') && response['data'] is List) {
        _posts = (response['data'] as List).map((json) => Post.fromJson(json as Map<String, dynamic>)).toList();
      } else {
        _posts = [];
      }
      
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Get post by ID
  Future<Post?> getPostById(int id) async {
    try {
      final response = await _apiService.get('${AppConstants.postEndpoint}/$id');
      return Post.fromJson(response);
    } catch (e) {
      debugPrint('Error getting post by ID: $e');
      return null;
    }
  }

  // Create new post
  Future<bool> createPost({
    required String judul,
    required String konten,
    required int idKategori,
    bool anonim = false,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final data = {
        'judul': judul,
        'konten': konten,
        'id_kategori': idKategori,
        'anonim': anonim,
      };

      final response = await _apiService.post(AppConstants.postEndpoint, data);
      
      if (response['id'] != null) {
        // Add new post to the beginning of the list
        final newPost = Post.fromJson(response);
        _posts.insert(0, newPost);
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

  // Update post
  Future<bool> updatePost({
    required int id,
    required String judul,
    required String konten,
    required int idKategori,
    bool? anonim,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final data = {
        'judul': judul,
        'konten': konten,
        'id_kategori': idKategori,
        if (anonim != null) 'anonim': anonim,
      };

      final response = await _apiService.put('${AppConstants.postEndpoint}/$id', data);
      
      // Update post in the list
      final index = _posts.indexWhere((post) => post.id == id);
      if (index != -1) {
        _posts[index] = Post.fromJson(response);
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

  // Delete post
  Future<bool> deletePost(int id) async {
    _setLoading(true);
    _clearError();

    try {
      await _apiService.delete('${AppConstants.postEndpoint}/$id');
      
      // Remove post from the list
      _posts.removeWhere((post) => post.id == id);
      notifyListeners();
      
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Toggle upvote
  Future<bool> toggleUpvote(int postId) async {
    try {
      await _apiService.post('${AppConstants.interactionEndpoint}/postingan', {
        'id_postingan': postId,
        'tipe': AppConstants.upvote,
      });

      // Update post in the list
      final index = _posts.indexWhere((post) => post.id == postId);
      if (index != -1) {
        final post = _posts[index];
        final wasUpvoted = post.hasUserUpvoted;
        final wasDownvoted = post.hasUserDownvoted;

        _posts[index] = post.copyWith(
          upvoteCount: wasUpvoted ? post.upvoteCount - 1 : post.upvoteCount + 1,
          downvoteCount: wasDownvoted ? post.downvoteCount - 1 : post.downvoteCount,
          userInteraction: wasUpvoted ? null : AppConstants.upvote,
        );
        notifyListeners();
      }

      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  // Toggle downvote
  Future<bool> toggleDownvote(int postId) async {
    try {
      await _apiService.post('${AppConstants.interactionEndpoint}/postingan', {
        'id_postingan': postId,
        'tipe': AppConstants.downvote,
      });

      // Update post in the list
      final index = _posts.indexWhere((post) => post.id == postId);
      if (index != -1) {
        final post = _posts[index];
        final wasUpvoted = post.hasUserUpvoted;
        final wasDownvoted = post.hasUserDownvoted;

        _posts[index] = post.copyWith(
          upvoteCount: wasUpvoted ? post.upvoteCount - 1 : post.upvoteCount,
          downvoteCount: wasDownvoted ? post.downvoteCount - 1 : post.downvoteCount + 1,
          userInteraction: wasDownvoted ? null : AppConstants.downvote,
        );
        notifyListeners();
      }

      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  // Report post
  Future<bool> reportPost(int postId, String reason) async {
    try {
      await _apiService.post('${AppConstants.interactionEndpoint}/postingan', {
        'id_postingan': postId,
        'tipe': AppConstants.report,
        'alasan_laporan': reason,
      });

      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  // Clear posts
  void clearPosts() {
    _posts.clear();
    notifyListeners();
  }

  // Private methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
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
