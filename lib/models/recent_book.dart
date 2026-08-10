class RecentBook {
  final String title;
  final String episode;
  final String url;

  // 새 사이트에서 사용하는 식별자
  final String novelId;
  final String episodeId;

  final String thumbnail;
  final String site;

  final DateTime lastRead;

  RecentBook({
    required this.title,
    required this.episode,
    required this.url,
    required this.lastRead,
    this.novelId = "",
    this.episodeId = "",
    this.thumbnail = "",
    this.site = "",
  });

  Map<String, dynamic> toJson() {
    return {
      "title": title,
      "episode": episode,
      "url": url,

      "novelId": novelId,
      "episodeId": episodeId,

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

      // 기존에 저장된 책에는 이 값이 없으므로 "" 처리
      novelId: json["novelId"] ?? "",
      episodeId: json["episodeId"] ?? "",

      thumbnail: json["thumbnail"] ?? "",
      site: json["site"] ?? "",

      lastRead: DateTime.tryParse(
        json["lastRead"] ?? "",
      ) ??
          DateTime.now(),
    );
  }
}