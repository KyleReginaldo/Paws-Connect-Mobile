class ChatVisibilityService {
  static int? _activeForumId;

  static void enterForum(int forumId) {
    _activeForumId = forumId;
  }

  static void exitForum() {
    _activeForumId = null;
  }

  static int? get activeForumId => _activeForumId;

  static bool isViewingForum(int forumId) {
    return _activeForumId != null && _activeForumId == forumId;
  }
}
