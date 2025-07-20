class NewsArticle {
  final String title;
  final String description;
  final String? url;
  final String? imageUrl;
  final String? publishedAt;
  final String? content;
  final String? sourceName;

  NewsArticle({
    required this.title,
    required this.description,
    this.url,
    this.imageUrl,
    this.publishedAt,
    this.content,
    this.sourceName,
  });

  factory NewsArticle.fromJson(Map<String, dynamic> json) {
    return NewsArticle(
      title: json['title'] ?? 'No title',
      description: json['description'] ?? 'No description',
      url: json['url'],
      imageUrl: json['image'],
      publishedAt: json['publishedAt'],
      content: json['content'],
      sourceName: json['source']?['name'],
    );
  }
}
