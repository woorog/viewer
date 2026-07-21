class RecentBook {
  final String title;
  final String episode;
  final String url;
  final DateTime lastRead;

  const RecentBook({
    required this.title,
    required this.episode,
    required this.url,
    required this.lastRead,
  });

  RecentBook copyWith({
    String? title,
    String? episode,
    String? url,
    DateTime? lastRead,
  }) {
    return RecentBook(
      title: title ?? this.title,
      episode: episode ?? this.episode,
      url: url ?? this.url,
      lastRead: lastRead ?? this.lastRead,
    );
  }

  @override
  String toString() {
    return 'RecentBook(title: $title, episode: $episode, url: $url)';
  }
}