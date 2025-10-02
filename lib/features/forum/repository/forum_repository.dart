import 'package:flutter/material.dart';
import 'package:paws_connect/features/forum/provider/forum_provider.dart';

import '../models/forum_model.dart';

class ForumRepository extends ChangeNotifier {
  List<Forum> _forums = [];
  Forum? _forum;
  List<ForumChat> _forumChats = [];
  String _errorMessage = '';
  bool _isLoadingForums = false;
  bool _isLoadingForum = false;
  bool _isLoadingChats = false;
  bool _usersLoading = false;
  String? _userErrorMessage;

  // Pagination state
  bool _isLoadingMoreChats = false;
  bool _hasMoreChats = true;
  int _currentPage = 1;
  final int _pageLimit = 20;

  List<Forum> get forums => _forums;
  List<AvailableUser> _availableUsers = [];
  List<AvailableUser> get availableUsers => _availableUsers;
  Forum? get forum => _forum;
  List<ForumChat> get forumChats => _forumChats;
  String get errorMessage => _errorMessage;
  bool get isLoadingForums => _isLoadingForums;
  bool get isLoadingChats => _isLoadingChats;
  bool get usersLoading => _usersLoading;
  bool get isLoadingForum => _isLoadingForum;
  String? get userErrorMessage => _userErrorMessage;
  bool get isLoadingMoreChats => _isLoadingMoreChats;
  bool get hasMoreChats => _hasMoreChats;
  final List<String> _pendingChats = [];

  List<String> get pendingChats => _pendingChats;
  final ForumProvider _provider;

  ForumRepository(this._provider);

  void addPendingChat(String chat) {
    _pendingChats.add(chat);
    notifyListeners();
  }

  void fetchAvailableUsers(int forumId, {String? username}) async {
    _usersLoading = true;
    notifyListeners();
    final result = await _provider.fetchAvailableUser(
      forumId,
      username: username,
    );
    debugPrint(result.toString());
    if (result.isError) {
      _availableUsers = [];
      _usersLoading = false;
      _userErrorMessage = result.error;
      notifyListeners();
    } else {
      _availableUsers = result.value;
      _usersLoading = false;
      _userErrorMessage = null;
      notifyListeners();
    }
  }

  Future<void> setForums(String userId) async {
    _isLoadingForums = true;
    _errorMessage = '';
    notifyListeners();

    final result = await _provider.fetchForums(userId);

    _isLoadingForums = false;
    if (result.isError) {
      _forums.clear();
      _errorMessage = result.error;
      notifyListeners();
    } else {
      _forums = result.value;
      _errorMessage = '';
      notifyListeners();
    }
  }

  void setForumById(int forumId, String userId) async {
    debugPrint('calling setForumById with forumId: $forumId');
    _isLoadingForum = true;
    _forum = null;
    notifyListeners();
    final result = await _provider.fetchForumById(forumId, userId);
    if (result.isError) {
      _isLoadingForum = false;
      _forum = null;
      notifyListeners();
    } else {
      _isLoadingForum = false;
      _forum = result.value;
      notifyListeners();
    }
  }

  void getRealChats(int forumId) async {
    _isLoadingChats = true;
    _currentPage = 1;
    _hasMoreChats = true;
    notifyListeners();
    final result = await _provider.fetchForumChats(
      forumId,
      page: _currentPage,
      limit: _pageLimit,
    );
    _isLoadingChats = false;
    if (result.isError) {
      _forumChats.clear();
      _pendingChats.clear();
      notifyListeners();
    } else {
      notifyListeners();
      _pendingChats.clear();
      _forumChats = result.value;
      _hasMoreChats = result.value.length == _pageLimit;
    }
  }

  void setForumChats(int forumId) async {
    final result = await _provider.fetchForumChats(
      forumId,
      page: 1,
      limit: _pageLimit,
    );
    _isLoadingChats = false;
    if (result.isError) {
      _forumChats.clear();
      _pendingChats.clear();
    } else {
      _forumChats = result.value;
      _pendingChats.clear();
      _currentPage = 1;
      _hasMoreChats = result.value.length == _pageLimit;
    }
    notifyListeners();
  }

  Future<void> loadMoreChats(int forumId) async {
    if (_isLoadingMoreChats || !_hasMoreChats) return;

    _isLoadingMoreChats = true;
    notifyListeners();

    final nextPage = _currentPage + 1;
    final result = await _provider.fetchForumChats(
      forumId,
      page: nextPage,
      limit: _pageLimit,
    );

    _isLoadingMoreChats = false;

    if (!result.isError && result.value.isNotEmpty) {
      // Insert older messages at the beginning of the list
      // Since the list is ordered with newest first, older messages go at the start
      _forumChats.insertAll(0, result.value);
      _currentPage = nextPage;
      _hasMoreChats = result.value.length == _pageLimit;
    } else {
      _hasMoreChats = false;
    }

    notifyListeners();
  }

  void reset() {
    _forums = [];
    _forum = null;
    _forumChats = [];
    _availableUsers = [];
    _pendingChats.clear();
    _errorMessage = '';
    _userErrorMessage = null;
    _isLoadingForums = false;
    _isLoadingForum = false;
    _isLoadingChats = false;
    _usersLoading = false;
    _isLoadingMoreChats = false;
    _hasMoreChats = true;
    _currentPage = 1;
    notifyListeners();
  }
}
