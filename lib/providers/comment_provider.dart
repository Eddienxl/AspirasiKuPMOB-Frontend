import 'package:flutter/foundation.dart';
import '../models/comment_model.dart';
import '../services/api_service.dart';
import '../utils/constants.dart';

class CommentProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<Comment> _comments = [];
  bool _isLoading = false;
  String? _error;

  // Cache for newly created comments when backend loading fails
  final Map<int, List<Comment>> _localCommentsCache = {};

  // Getters
  List<Comment> get comments => _comments;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Private methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }

  // Load comments for a specific post
  Future<void> loadComments(int postId) async {
    _setLoading(true);
    _clearError();

    try {
      // Try to get comments from backend
      final response = await _apiService.get(AppConstants.commentEndpoint);

      if (response is List) {
        final allComments = response.map((json) => Comment.fromJson(json)).toList();
        // Filter comments for the specific post
        _comments = allComments.where((comment) => comment.idPostingan == postId).toList();
        // Sort by creation date (newest first)
        _comments.sort((a, b) => b.dibuatPada.compareTo(a.dibuatPada));
      } else {
        _comments = [];
      }
    } catch (e) {
      debugPrint('Error loading comments: $e');

      // Handle specific backend database errors
      if (e.toString().contains('column') && e.toString().contains('does not exist')) {
        // Backend database schema issue - use cached comments if available
        _comments = _localCommentsCache[postId] ?? [];
        _setError('Sistem komentar sedang dalam perbaikan. Komentar baru masih bisa dibuat.');
      } else if (e.toString().contains('Session expired') || e.toString().contains('Token')) {
        _setError('Sesi Anda telah berakhir, silakan login kembali');
      } else {
        _setError('Gagal memuat komentar. Silakan coba lagi.');
      }
    } finally {
      _setLoading(false);
    }
  }

  // Create new comment
  Future<bool> createComment({
    required int postId,
    required String konten,
  }) async {
    _clearError();

    try {
      final data = {
        'id_postingan': postId,
        'konten': konten,
      };

      final response = await _apiService.post(AppConstants.commentEndpoint, data);

      if (response['id'] != null) {
        // Try to reload comments, but don't fail if it doesn't work
        try {
          await loadComments(postId);
        } catch (loadError) {
          debugPrint('Failed to reload comments after creation: $loadError');
          // Create a temporary comment from the response to show immediately
          if (response['penulis'] != null) {
            final newComment = Comment.fromJson(response);
            _comments.add(newComment);
            _comments.sort((a, b) => b.dibuatPada.compareTo(a.dibuatPada));

            // Cache the comment for this post
            _localCommentsCache[postId] = List.from(_comments);
            notifyListeners();
          }
        }
        return true;
      }

      return false;
    } catch (e) {
      if (e.toString().contains('Session expired') || e.toString().contains('Token')) {
        _setError('Sesi Anda telah berakhir, silakan login kembali');
      } else {
        _setError('Gagal membuat komentar. Silakan coba lagi.');
      }
      debugPrint('Error creating comment: $e');
      return false;
    }
  }

  // Update comment
  Future<bool> updateComment({
    required int commentId,
    required String konten,
  }) async {
    _clearError();

    try {
      final data = {
        'konten': konten,
      };

      await _apiService.put('${AppConstants.commentEndpoint}/$commentId', data);
      
      // Update local comment
      final index = _comments.indexWhere((comment) => comment.id == commentId);
      if (index != -1) {
        _comments[index] = _comments[index].copyWith(
          konten: konten,
          diperbaruiPada: DateTime.now(),
        );
        notifyListeners();
      }

      return true;
    } catch (e) {
      _setError(e.toString());
      debugPrint('Error updating comment: $e');
      return false;
    }
  }

  // Delete comment
  Future<bool> deleteComment(int commentId) async {
    _clearError();

    try {
      await _apiService.delete('${AppConstants.commentEndpoint}/$commentId');
      
      // Remove from local list
      _comments.removeWhere((comment) => comment.id == commentId);
      notifyListeners();

      return true;
    } catch (e) {
      _setError(e.toString());
      debugPrint('Error deleting comment: $e');
      return false;
    }
  }

  // Get comments count for a post
  int getCommentsCount(int postId) {
    return _comments.where((comment) => comment.idPostingan == postId).length;
  }

  // Clear comments (useful when navigating away)
  void clearComments() {
    _comments.clear();
    _error = null;
    notifyListeners();
  }

  // Clear cache for a specific post
  void clearCacheForPost(int postId) {
    _localCommentsCache.remove(postId);
  }

  // Clear all cache
  void clearAllCache() {
    _localCommentsCache.clear();
  }

  // Refresh comments
  Future<void> refreshComments(int postId) async {
    await loadComments(postId);
  }
}
