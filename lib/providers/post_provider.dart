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

      print('🔄 Loading posts from: $endpoint');
      final response = await _apiService.get(endpoint);
      print('📦 Raw response type: ${response.runtimeType}');

      // Handle different response formats
      List<dynamic> postsData = [];

      if (response is List) {
        print('✅ Response is direct array');
        postsData = response;
      } else if (response is Map<String, dynamic>) {
        print('✅ Response is object, checking for data fields...');
        if (response.containsKey('data') && response['data'] is List) {
          print('✅ Found data field with array');
          postsData = response['data'] as List<dynamic>;
        } else if (response.containsKey('postingan') && response['postingan'] is List) {
          print('✅ Found postingan field with array');
          postsData = response['postingan'] as List<dynamic>;
        } else if (response.containsKey('posts') && response['posts'] is List) {
          print('✅ Found posts field with array');
          postsData = response['posts'] as List<dynamic>;
        } else {
          print('❌ No recognized array field found in response');
          print('📋 Available keys: ${response.keys.toList()}');
        }
      } else {
        print('❌ Unexpected response format: ${response.runtimeType}');
      }

      print('📊 Loaded ${postsData.length} posts from API');
      _posts = postsData.map((json) => Post.fromJson(json as Map<String, dynamic>)).toList();
      _clearError();
      notifyListeners();
      print('✅ Posts updated in provider: ${_posts.length} posts');
    } catch (e) {
      print('❌ Error loading posts: $e');
      String errorMessage = e.toString().replaceAll('Exception: ', '');

      // Provide more user-friendly error messages
      if (errorMessage.contains('500')) {
        errorMessage = 'Server sedang mengalami masalah. Silakan coba lagi nanti.';
      } else if (errorMessage.contains('Connection refused') || errorMessage.contains('Network')) {
        errorMessage = 'Tidak dapat terhubung ke server. Periksa koneksi internet Anda.';
      } else if (errorMessage.contains('Timeout')) {
        errorMessage = 'Koneksi timeout. Silakan coba lagi.';
      }

      _setError(errorMessage);
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
        // Refresh all posts to get the latest data with proper relationships
        await loadPosts(
          filter: _currentFilter,
          sort: _currentSort,
          refresh: true,
        );
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
    // Optimistically update UI first for better UX
    final index = _posts.indexWhere((post) => post.id == postId);
    Post? originalPost;

    if (index != -1) {
      originalPost = _posts[index];
      final wasUpvoted = originalPost.hasUserUpvoted;
      final wasDownvoted = originalPost.hasUserDownvoted;

      _posts[index] = originalPost.copyWith(
        upvoteCount: wasUpvoted ? originalPost.upvoteCount - 1 : originalPost.upvoteCount + 1,
        downvoteCount: wasDownvoted ? originalPost.downvoteCount - 1 : originalPost.downvoteCount,
        userInteraction: wasUpvoted ? null : AppConstants.upvote,
      );
      notifyListeners();
    }

    try {
      await _apiService.post('${AppConstants.interactionEndpoint}/postingan', {
        'id_postingan': postId,
        'tipe': AppConstants.upvote,
      });

      return true;
    } catch (e) {
      // Revert optimistic update on error
      if (originalPost != null && index != -1) {
        _posts[index] = originalPost;
        notifyListeners();
      }

      // Provide user-friendly error messages
      if (e.toString().contains('column') && e.toString().contains('does not exist')) {
        _setError('Fitur upvote sedang dalam perbaikan. Silakan coba lagi nanti.');
      } else if (e.toString().contains('Session expired') || e.toString().contains('Token')) {
        _setError('Sesi Anda telah berakhir, silakan login kembali');
      } else {
        _setError('Gagal memberikan upvote. Silakan coba lagi.');
      }
      return false;
    }
  }

  // Toggle downvote
  Future<bool> toggleDownvote(int postId) async {
    // Optimistically update UI first for better UX
    final index = _posts.indexWhere((post) => post.id == postId);
    Post? originalPost;

    if (index != -1) {
      originalPost = _posts[index];
      final wasUpvoted = originalPost.hasUserUpvoted;
      final wasDownvoted = originalPost.hasUserDownvoted;

      _posts[index] = originalPost.copyWith(
        upvoteCount: wasUpvoted ? originalPost.upvoteCount - 1 : originalPost.upvoteCount,
        downvoteCount: wasDownvoted ? originalPost.downvoteCount - 1 : originalPost.downvoteCount + 1,
        userInteraction: wasDownvoted ? null : AppConstants.downvote,
      );
      notifyListeners();
    }

    try {
      await _apiService.post('${AppConstants.interactionEndpoint}/postingan', {
        'id_postingan': postId,
        'tipe': AppConstants.downvote,
      });

      return true;
    } catch (e) {
      // Revert optimistic update on error
      if (originalPost != null && index != -1) {
        _posts[index] = originalPost;
        notifyListeners();
      }

      // Provide user-friendly error messages
      if (e.toString().contains('column') && e.toString().contains('does not exist')) {
        _setError('Fitur downvote sedang dalam perbaikan. Silakan coba lagi nanti.');
      } else if (e.toString().contains('Session expired') || e.toString().contains('Token')) {
        _setError('Sesi Anda telah berakhir, silakan login kembali');
      } else {
        _setError('Gagal memberikan downvote. Silakan coba lagi.');
      }
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
      // Provide user-friendly error messages
      if (e.toString().contains('column') && e.toString().contains('does not exist')) {
        _setError('Terjadi masalah dengan server. Tim teknis sedang memperbaiki.');
      } else if (e.toString().contains('Session expired') || e.toString().contains('Token')) {
        _setError('Sesi Anda telah berakhir, silakan login kembali');
      } else {
        _setError('Gagal mengirim laporan. Silakan coba lagi.');
      }
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }
}
