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

      // Fix category filter parameter
      if (filter != 'semua') {
        queryParams['kategori'] = filter; // Use 'kategori' instead of 'filter'
      }

      // Fix sort parameter mapping
      if (sort != 'terbaru') {
        switch (sort) {
          case 'terlama':
            queryParams['sort'] = 'asc'; // Ascending order for oldest first
            break;
          case 'terpopuler':
            queryParams['sort'] = 'populer'; // Use 'populer' for backend
            break;
          default:
            queryParams['sort'] = sort;
        }
      }

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

  // Get single post by ID with real-time sync
  Future<Post?> getPostById(int postId) async {
    try {
      final response = await _apiService.get('${AppConstants.postEndpoint}/$postId');

      if (response != null) {
        final post = Post.fromJson(response);

        // Update the post in local list if it exists for real-time sync
        final index = _posts.indexWhere((p) => p.id == postId);
        if (index != -1) {
          _posts[index] = post;
          notifyListeners();
        }

        return post;
      }

      return null;
    } catch (e) {
      _setError('Gagal memuat detail postingan: ${e.toString()}');
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

  // Toggle upvote with real-time response handling
  Future<bool> toggleUpvote(int postId) async {
    final index = _posts.indexWhere((post) => post.id == postId);
    Post? originalPost;

    if (index != -1) {
      originalPost = _posts[index];
      final wasUpvoted = originalPost.hasUserUpvoted;
      final wasDownvoted = originalPost.hasUserDownvoted;

      // Optimistic update
      _posts[index] = originalPost.copyWith(
        upvoteCount: wasUpvoted ? originalPost.upvoteCount - 1 : originalPost.upvoteCount + 1,
        downvoteCount: wasDownvoted ? originalPost.downvoteCount - 1 : originalPost.downvoteCount,
        userInteraction: wasUpvoted ? null : AppConstants.upvote,
      );
      notifyListeners();
    }

    try {
      final response = await _apiService.post('${AppConstants.interactionEndpoint}/postingan', {
        'id_postingan': postId,
        'tipe': AppConstants.upvote,
      });

      // Get the actual action from server response
      final action = response['action']; // 'added' or 'removed'

      // Update with real server response to ensure consistency
      if (index != -1 && originalPost != null) {
        if (action == 'added') {
          // Upvote was added
          _posts[index] = originalPost.copyWith(
            upvoteCount: originalPost.upvoteCount + 1,
            downvoteCount: originalPost.hasUserDownvoted ? originalPost.downvoteCount - 1 : originalPost.downvoteCount,
            userInteraction: AppConstants.upvote,
          );
        } else if (action == 'removed') {
          // Upvote was removed
          _posts[index] = originalPost.copyWith(
            upvoteCount: originalPost.upvoteCount - 1,
            userInteraction: null,
          );
        }
        notifyListeners();
      }

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

  // Toggle downvote with real-time response handling
  Future<bool> toggleDownvote(int postId) async {
    final index = _posts.indexWhere((post) => post.id == postId);
    Post? originalPost;

    if (index != -1) {
      originalPost = _posts[index];
      final wasUpvoted = originalPost.hasUserUpvoted;
      final wasDownvoted = originalPost.hasUserDownvoted;

      // Optimistic update
      _posts[index] = originalPost.copyWith(
        upvoteCount: wasUpvoted ? originalPost.upvoteCount - 1 : originalPost.upvoteCount,
        downvoteCount: wasDownvoted ? originalPost.downvoteCount - 1 : originalPost.downvoteCount + 1,
        userInteraction: wasDownvoted ? null : AppConstants.downvote,
      );
      notifyListeners();
    }

    try {
      final response = await _apiService.post('${AppConstants.interactionEndpoint}/postingan', {
        'id_postingan': postId,
        'tipe': AppConstants.downvote,
      });

      // Get the actual action from server response
      final action = response['action']; // 'added' or 'removed'

      // Update with real server response to ensure consistency
      if (index != -1 && originalPost != null) {
        if (action == 'added') {
          // Downvote was added
          _posts[index] = originalPost.copyWith(
            upvoteCount: originalPost.hasUserUpvoted ? originalPost.upvoteCount - 1 : originalPost.upvoteCount,
            downvoteCount: originalPost.downvoteCount + 1,
            userInteraction: AppConstants.downvote,
          );
        } else if (action == 'removed') {
          // Downvote was removed
          _posts[index] = originalPost.copyWith(
            downvoteCount: originalPost.downvoteCount - 1,
            userInteraction: null,
          );
        }
        notifyListeners();
      }

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

  // Archive post
  Future<bool> archivePost(int postId) async {
    _setLoading(true);
    _clearError();

    try {
      await _apiService.patch('${AppConstants.postEndpoint}/$postId/archive', {});

      // Update post status in the list
      final index = _posts.indexWhere((post) => post.id == postId);
      if (index != -1) {
        _posts[index] = _posts[index].copyWith(status: 'terarsip');
        notifyListeners();
      }

      return true;
    } catch (e) {
      _setError('Gagal mengarsipkan postingan: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Activate post
  Future<bool> activatePost(int postId) async {
    _setLoading(true);
    _clearError();

    try {
      await _apiService.patch('${AppConstants.postEndpoint}/$postId/activate', {});

      // Update post status in the list
      final index = _posts.indexWhere((post) => post.id == postId);
      if (index != -1) {
        _posts[index] = _posts[index].copyWith(status: 'aktif');
        notifyListeners();
      }

      return true;
    } catch (e) {
      _setError('Gagal mengaktifkan postingan: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
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
