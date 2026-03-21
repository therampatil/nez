class ApiRoutes {
  const ApiRoutes._();

  static const feed = '/feed/';

  static const headlinesLatest = '/headlines/latest/';
  static const headlinesLatestNoSlash = '/headlines/latest';
  static const headlinesList = '/headlines/';
  static const headlinesListNoSlash = '/headlines';

  static const followedStories = '/followed-stories/';
  static const followedStoriesNoSlash = '/followed-stories';
  static const followedStoriesFeed = '/followed-stories/feed';

  static const userBookmarks = '/users/me/bookmarks';
  static String userBookmarkById(int articleId) => '/users/me/bookmarks/$articleId';
}
