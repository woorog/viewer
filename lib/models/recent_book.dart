class RecentBook {
  final String title;
  final String episode;
  final String url;

  final String thumbnail;
  final String site;

  final DateTime lastRead;

  RecentBook({
    required this.title,
    required this.episode,
    required this.url,
    required this.lastRead,
    this.thumbnail = "",
    this.site = "",
  });

  Map<String, dynamic> toJson() {
    return {
      "title": title,
      "episode": episode,
      "url": url,
      "thumbnail": thumbnail,
      "site": site,
      "lastRead": lastRead.toIso8601String(),
    };
  }

  factory RecentBook.fromJson(Map<String, dynamic> json) {
    return RecentBook(
      title: json["title"] ?? "",
      episode: json["episode"] ?? "",
      url: json["url"] ?? "",
      thumbnail: json["thumbnail"] ?? "",
      site: json["site"] ?? "",
      lastRead: DateTime.parse(json["lastRead"]),
    );
  }
}