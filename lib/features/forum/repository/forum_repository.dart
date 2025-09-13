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
  final ForumProvider _provider;

  ForumRepository(this._provider);

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

  void setForums(String userId) async {
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

  void setForumById(int forumId) async {
    debugPrint('calling setForumById with forumId: $forumId');
    _isLoadingForum = true;
    _forum = null;
    notifyListeners();
    final result = await _provider.fetchForumById(forumId);
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
    notifyListeners();
    final result = await _provider.fetchForumChats(forumId);
    _isLoadingChats = false;
    if (result.isError) {
      _forumChats.clear();
      notifyListeners();
    } else {
      notifyListeners();

      _forumChats = result.value;
    }
  }

  void setForumChats(int forumId) async {
    final result = await _provider.fetchForumChats(forumId);
    _isLoadingChats = false;
    if (result.isError) {
      _forumChats.clear();
    } else {
      _forumChats = result.value;
    }
    notifyListeners();
  }
}
