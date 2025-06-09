import 'package:flutter/foundation.dart';
import '../models/report_model.dart';
import '../models/post_model.dart';
import '../services/admin_service.dart';

class AdminProvider with ChangeNotifier {
  final AdminService _adminService = AdminService();

  List<Report> _reports = [];
  List<Post> _allPosts = [];
  bool _isLoadingReports = false;
  bool _isLoadingPosts = false;
  String? _reportsError;
  String? _postsError;

  // Getters
  List<Report> get reports => _reports;
  List<Post> get allPosts => _allPosts;
  bool get isLoadingReports => _isLoadingReports;
  bool get isLoadingPosts => _isLoadingPosts;
  bool get isLoading => _isLoadingReports || _isLoadingPosts;
  String? get reportsError => _reportsError;
  String? get postsError => _postsError;
  String? get error => _reportsError ?? _postsError;

  // Private methods
  void _setLoadingReports(bool loading) {
    _isLoadingReports = loading;
    notifyListeners();
  }

  void _setLoadingPosts(bool loading) {
    _isLoadingPosts = loading;
    notifyListeners();
  }

  void _setReportsError(String? error) {
    _reportsError = error;
    notifyListeners();
  }

  void _setPostsError(String? error) {
    _postsError = error;
    notifyListeners();
  }

  void _clearReportsError() {
    _reportsError = null;
  }

  void _clearPostsError() {
    _postsError = null;
  }

  // Load all reports
  Future<void> loadReports() async {
    _setLoadingReports(true);
    _clearReportsError();

    try {
      final reports = await _adminService.getAllReports();
      _reports = reports;
    } catch (e) {
      _setReportsError(e.toString().replaceAll('Exception: ', ''));
    } finally {
      _setLoadingReports(false);
    }
  }

  // Load all posts (for admin management)
  Future<void> loadAllPosts() async {
    _setLoadingPosts(true);
    _clearPostsError();

    try {
      final posts = await _adminService.getAllPosts();
      _allPosts = posts;
    } catch (e) {
      _setPostsError(e.toString().replaceAll('Exception: ', ''));
    } finally {
      _setLoadingPosts(false);
    }
  }

  // Handle report actions
  Future<bool> ignoreReport(int reportId) async {
    _clearReportsError();

    try {
      final success = await _adminService.ignoreReport(reportId);
      if (success) {
        // Remove report from local list
        _reports.removeWhere((report) => report.id == reportId);
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _setReportsError(e.toString().replaceAll('Exception: ', ''));
      return false;
    }
  }

  Future<bool> archivePostFromReport(int reportId, int postId) async {
    _clearReportsError();
    _clearPostsError();

    try {
      final success = await _adminService.archivePost(postId);
      if (success) {
        // Remove report from local list
        _reports.removeWhere((report) => report.id == reportId);
        // Remove post from all posts list (since it's actually deleted)
        _allPosts.removeWhere((post) => post.id == postId);
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _setReportsError(e.toString().replaceAll('Exception: ', ''));
      return false;
    }
  }

  Future<bool> deletePostFromReport(int reportId, int postId) async {
    _clearReportsError();
    _clearPostsError();

    try {
      final success = await _adminService.deletePost(postId);
      if (success) {
        // Remove report from local list
        _reports.removeWhere((report) => report.id == reportId);
        // Remove post from all posts list
        _allPosts.removeWhere((post) => post.id == postId);
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _setReportsError(e.toString().replaceAll('Exception: ', ''));
      return false;
    }
  }

  // Post management actions
  Future<bool> archivePost(int postId) async {
    _clearPostsError();

    try {
      final success = await _adminService.archivePost(postId);
      if (success) {
        // Remove post from local list (since it's actually deleted)
        _allPosts.removeWhere((post) => post.id == postId);
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _setPostsError(e.toString().replaceAll('Exception: ', ''));
      return false;
    }
  }

  Future<bool> activatePost(int postId) async {
    _clearPostsError();

    try {
      final success = await _adminService.activatePost(postId);
      if (success) {
        // Update post status in local list
        final postIndex = _allPosts.indexWhere((post) => post.id == postId);
        if (postIndex != -1) {
          _allPosts[postIndex] = _allPosts[postIndex].copyWith(status: 'aktif');
          notifyListeners();
        }
        return true;
      }
      return false;
    } catch (e) {
      _setPostsError(e.toString().replaceAll('Exception: ', ''));
      return false;
    }
  }

  Future<bool> deletePost(int postId) async {
    _clearPostsError();

    try {
      final success = await _adminService.deletePost(postId);
      if (success) {
        // Remove post from local list
        _allPosts.removeWhere((post) => post.id == postId);
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _setPostsError(e.toString().replaceAll('Exception: ', ''));
      return false;
    }
  }

  // Clear all data
  void clearData() {
    _reports.clear();
    _allPosts.clear();
    _reportsError = null;
    _postsError = null;
    _isLoadingReports = false;
    _isLoadingPosts = false;
    notifyListeners();
  }
}
