import 'package:flutter/material.dart';
import 'package:paws_connect/features/posts/provider/posts_provider.dart';

class PostsRepository extends ChangeNotifier {
  PostsRepository({required this.provider, int? pageLimit})
    : _pageLimit = pageLimit ?? 10;

  final PostsProvider provider;

  // Internal state
  List<Post> _posts = [];
  String _errorMessage = '';
  bool _isLoadingPosts = false;
  bool _isLoadingMorePosts = false;
  bool _hasMorePosts = true;
  int _currentPage = 1;
  final int _pageLimit;

  // Getters
  List<Post> get posts => _posts;
  String get errorMessage => _errorMessage;
  bool get isLoadingPosts => _isLoadingPosts;
  bool get isLoadingMorePosts => _isLoadingMorePosts;
  bool get hasMorePosts => _hasMorePosts;
  int get currentPage => _currentPage;
  int get pageLimit => _pageLimit;
  bool get isAnyLoading => _isLoadingPosts || _isLoadingMorePosts;

  Future<void> fetchPosts({bool refresh = false}) async {
    if (_isLoadingPosts) return;
    if (refresh) {
      _currentPage = 1;
      _hasMorePosts = true;
      _posts = [];
      _errorMessage = '';
      notifyListeners();
    }

    _isLoadingPosts = true;
    notifyListeners();

    final result = await provider.fetchPosts(
      page: _currentPage,
      limit: _pageLimit,
    );

    _isLoadingPosts = false;

    if (result.isError) {
      if (_currentPage == 1) {
        _posts = [];
      }
      _errorMessage = result.error;
      notifyListeners();
      return;
    }

    final newPosts = result.value;
    if (_currentPage == 1) {
      _posts = newPosts;
    } else {
      _posts.addAll(newPosts);
    }
    _hasMorePosts = newPosts.length == _pageLimit;
    _errorMessage = '';
    notifyListeners();
  }

  Future<void> loadMore() async {
    if (_isLoadingMorePosts || !_hasMorePosts) return;
    _isLoadingMorePosts = true;
    _currentPage++;
    notifyListeners();

    final result = await provider.fetchPosts(
      page: _currentPage,
      limit: _pageLimit,
    );
    _isLoadingMorePosts = false;

    if (result.isError) {
      _currentPage--; // revert page on failure
      _errorMessage = result.error;
    } else {
      final newPosts = result.value;
      _posts.addAll(newPosts);
      _hasMorePosts = newPosts.length == _pageLimit;
      _errorMessage = '';
    }
    notifyListeners();
  }

  void reset() {
    _posts = [];
    _errorMessage = '';
    _isLoadingPosts = false;
    _isLoadingMorePosts = false;
    _hasMorePosts = true;
    _currentPage = 1;
    notifyListeners();
  }

  Future<void> addComment({
    required int postId,
    required String userId,
    required String comment,
    String? username,
    String? profileImage,
  }) async {
    if (comment.trim().isEmpty) return;

    // Optimistic update with user info
    final index = _posts.indexWhere((p) => p.id == postId);
    if (index >= 0) {
      final post = _posts[index];
      final updatedComments = List<Map<String, dynamic>>.from(
        post.comments ?? [],
      );
      updatedComments.add({
        'user_id': userId,
        'username': username ?? 'You',
        'profile_image': profileImage,
        'comment': comment,
        'created_at': DateTime.now().toIso8601String(),
      });
      _posts[index] = post.copyWith(comments: updatedComments);
      notifyListeners();
    }

    // Send to server
    final result = await provider.addComment(
      postId: postId,
      userId: userId,
      comment: comment,
    );

    if (result.isError) {
      // Revert on error
      if (index >= 0) {
        final post = _posts[index];
        final revertedComments = List<Map<String, dynamic>>.from(
          post.comments ?? [],
        );
        if (revertedComments.isNotEmpty) {
          revertedComments.removeLast();
        }
        _posts[index] = post.copyWith(comments: revertedComments);
        notifyListeners();
      }
      _errorMessage = result.error;
    }
  }

  Future<void> toggleReaction({
    required int postId,
    required String userId,
  }) async {
    // Optimistic update
    final index = _posts.indexWhere((p) => p.id == postId);
    if (index >= 0) {
      final post = _posts[index];
      final updatedReactions = List<Map<String, dynamic>>.from(
        post.reactions ?? [],
      );
      final existingIndex = updatedReactions.indexWhere(
        (r) => r['user_id'] == userId,
      );

      if (existingIndex >= 0) {
        updatedReactions.removeAt(existingIndex);
      } else {
        updatedReactions.add({
          'user_id': userId,
          'created_at': DateTime.now().toIso8601String(),
        });
      }
      _posts[index] = post.copyWith(reactions: updatedReactions);
      notifyListeners();
    }

    // Send to server
    final result = await provider.toggleReaction(
      postId: postId,
      userId: userId,
    );

    if (result.isError) {
      // Revert on error - toggle back
      if (index >= 0) {
        final post = _posts[index];
        final revertedReactions = List<Map<String, dynamic>>.from(
          post.reactions ?? [],
        );
        final existingIndex = revertedReactions.indexWhere(
          (r) => r['user_id'] == userId,
        );

        if (existingIndex >= 0) {
          revertedReactions.removeAt(existingIndex);
        } else {
          revertedReactions.add({
            'user_id': userId,
            'created_at': DateTime.now().toIso8601String(),
          });
        }
        _posts[index] = post.copyWith(reactions: revertedReactions);
        notifyListeners();
      }
      _errorMessage = result.error;
    }
  }

  Future<void> deleteComment({
    required int postId,
    required int commentIndex,
  }) async {
    // Optimistic update - remove comment immediately
    final postIndex = _posts.indexWhere((p) => p.id == postId);
    Map<String, dynamic>? deletedComment;

    if (postIndex >= 0) {
      final post = _posts[postIndex];
      final updatedComments = List<Map<String, dynamic>>.from(
        post.comments ?? [],
      );

      if (commentIndex >= 0 && commentIndex < updatedComments.length) {
        deletedComment = updatedComments[commentIndex];
        updatedComments.removeAt(commentIndex);
        _posts[postIndex] = post.copyWith(comments: updatedComments);
        notifyListeners();
      }
    }

    // Send to server
    final result = await provider.deleteComment(
      postId: postId,
      commentIndex: commentIndex,
    );

    if (result.isError) {
      // Revert on error - restore the deleted comment
      if (postIndex >= 0 && deletedComment != null) {
        final post = _posts[postIndex];
        final revertedComments = List<Map<String, dynamic>>.from(
          post.comments ?? [],
        );
        revertedComments.insert(commentIndex, deletedComment);
        _posts[postIndex] = post.copyWith(comments: revertedComments);
        notifyListeners();
      }
      _errorMessage = result.error;
    }
  }
}
