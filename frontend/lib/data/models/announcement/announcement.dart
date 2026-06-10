class Announcement {
  final int announcementId;
  final String title;
  final String content;
  final String tag; // 'NOTICE' | 'EVENT'
  final String? imageUrl;
  final bool? isNew;
  final String? publishedAt;
  final String? createdAt;

  Announcement({
    required this.announcementId,
    required this.title,
    required this.content,
    required this.tag,
    this.imageUrl,
    this.isNew,
    this.publishedAt,
    this.createdAt,
  });

  factory Announcement.fromJson(Map<String, dynamic> json) {
    return Announcement(
      announcementId: json['announcementId'],
      title: json['title'],
      content: json['content'],
      tag: json['tag'] ?? 'NOTICE',
      imageUrl: json['imageUrl'],
      isNew: json['isNew'],
      publishedAt: json['publishedAt']?.toString(),
      createdAt: json['createdAt']?.toString(),
    );
  }
}
