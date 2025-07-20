import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_frontend/model/news_model.dart';
import 'package:mobile_frontend/views/users/news_webview.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

class NewsService {
  static String newsApiKey = '${dotenv.env['NEWS_API']}';
  static const String newsBaseUrl = 'https://gnews.io/api/v4/search?';

  Future<List<NewsArticle>> fetchHealthNews() async {
    try {
      final url =
          '${newsBaseUrl}q=health AND Malaysia&lang=en&max=100&apikey=$newsApiKey';

      debugPrint(
          'Request URL: ${url.length > 200 ? url.substring(0, 200) + "..." : url}');

      final response = await http.get(Uri.parse(url));
      debugPrint('Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List articles = data['articles'] ?? [];
        final int totalResults = data['totalArticles'] ?? 0;

        debugPrint('Raw article count: ${articles.length}');
        debugPrint('Total results: $totalResults');

        return articles
            .map((article) => NewsArticle.fromJson(article))
            .toList();
      } else {
        debugPrint('Error response body: ${response.body}');
        throw Exception('Failed to load news: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching health news: $e');
      debugPrint('Stack trace: ${StackTrace.current}');
      return _getMockNews();
    }
  }

  Future<List<dynamic>> fetchCovidCases({int limit = 3}) async {
    try {
      final url = Uri.parse(
          'https://api.data.gov.my/data-catalogue?id=covid_cases&state=Malaysia&limit=$limit');
      debugPrint('Fetching COVID cases from: $url');

      final response = await http.get(url);
      debugPrint('COVID API response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final List<dynamic> result = json.decode(response.body);
        debugPrint('Fetched ${result.length} COVID cases');
        return result;
      } else {
        debugPrint('Error response body: ${response.body}');
        throw Exception('Failed to load COVID cases: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching COVID cases: $e');
      debugPrint('Stack trace: ${StackTrace.current}');
      return _getMockCovidCases();
    }
  }

  List<NewsArticle> _getMockNews() {
    return [
      NewsArticle(
        title: "Mock Health News",
        description: "This is a mock news article for testing purposes",
        url: "https://example.com",
        imageUrl: null,
        publishedAt: DateTime.now().toString(),
        content: "Mock content",
        sourceName: "Mock Source",
      )
    ];
  }

  List<dynamic> _getMockCovidCases() {
    return [];
  }
}

class NewsController extends ChangeNotifier {
  final NewsService _apiService = NewsService();
  List<NewsArticle> _articles = [];
  List<dynamic> _covidCases = [];
  bool _isLoading = false;
  String? _error;
  bool _disposed = false;

  List<NewsArticle> get articles => _articles;
  List<dynamic> get covidCases => _covidCases;
  bool get isLoading => _isLoading;
  String? get error => _error;

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  void _safeNotifyListeners() {
    if (!_disposed) {
      notifyListeners();
    }
  }

  Future<void> refreshData() async {
    if (_disposed) return;

    _isLoading = true;
    _error = null;
    _safeNotifyListeners();

    try {
      await Future.wait([
        _apiService.fetchHealthNews().then((articles) {
          _articles = articles;
          _articles.sort((a, b) {
            final aDate = a.publishedAt != null
                ? DateTime.parse(a.publishedAt!)
                : DateTime.now();
            final bDate = b.publishedAt != null
                ? DateTime.parse(b.publishedAt!)
                : DateTime.now();
            return bDate.compareTo(aDate);
          });
        }),
        _apiService.fetchCovidCases(limit: 3).then((cases) {
          _covidCases = cases;
        }),
      ]);
    } catch (e) {
      if (!_disposed) {
        _error = e.toString();
        debugPrint('Error loading data: $_error');
      }
    } finally {
      if (!_disposed) {
        _isLoading = false;
        _safeNotifyListeners();
      }
    }
  }
}

class CovidCasesCard extends StatelessWidget {
  final List<dynamic> cases;

  const CovidCasesCard({super.key, required this.cases});

  @override
  Widget build(BuildContext context) {
    if (cases.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.health_and_safety, color: Colors.red[600]),
                const SizedBox(width: 8),
                Text(
                  'Latest COVID-19',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...cases.map((caseData) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        caseData['state'] ?? 'Unknown',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                      ),
                      Text(
                        '${caseData['cases_new'] ?? 0} cases',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.red[600],
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                )),
            const SizedBox(height: 8),
            Text(
              'Last updated: ${_formatDate(cases.isNotEmpty ? cases[0]['date'] : '')}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('dd MMM yyyy').format(date);
    } catch (e) {
      return dateString;
    }
  }
}

class NewsCard extends StatelessWidget {
  final NewsArticle article;
  final VoidCallback? onTap;

  const NewsCard({
    super.key,
    required this.article,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      child: InkWell(
        onTap: () => _openWebView(context),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (article.imageUrl != null) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    article.imageUrl!,
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 200,
                        color: Colors.grey[300],
                        child: Icon(
                          Icons.image_not_supported,
                          size: 50,
                          color: Colors.grey[600],
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 12),
              ],
              Text(
                article.title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Text(
                article.description,
                style: Theme.of(context).textTheme.bodyMedium,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (article.sourceName != null)
                    Text(
                      article.sourceName!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.blue[700],
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                  if (article.publishedAt != null)
                    Text(
                      _formatDate(article.publishedAt!),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openWebView(BuildContext context) async {
    if (article.url != null && article.url!.isNotEmpty) {
      try {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => FullArticleWebView(url: article.url!),
          ),
        );
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Could not open article: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
          _showArticleDetails(context);
        }
      }
    } else {
      _showArticleDetails(context);
    }
  }

  void _showArticleDetails(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.3,
        builder: (context, scrollController) => Container(
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            controller: scrollController,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  article.title,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                if (article.sourceName != null)
                  Text(
                    article.sourceName!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.blue[700],
                        ),
                  ),
                const SizedBox(height: 16),
                Text(
                  article.description,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                if (article.content != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    article.content!,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
                const SizedBox(height: 16),
                if (article.url != null && article.url!.isNotEmpty)
                  ElevatedButton.icon(
                    onPressed: () async {
                      Navigator.pop(context);
                      try {
                        await Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) =>
                                FullArticleWebView(url: article.url!),
                          ),
                        );
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                  'Could not open article: ${e.toString()}'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    },
                    icon: const Icon(Icons.open_in_browser),
                    label: const Text('Read Full Article'),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final difference = now.difference(date).inHours;

      if (difference < 24) {
        return '${difference}h ago';
      } else {
        return DateFormat('dd MMM').format(date);
      }
    } catch (e) {
      return dateString;
    }
  }
}

class News extends StatefulWidget {
  const News({super.key});

  @override
  State<News> createState() => _NewsState();
}

class _NewsState extends State<News> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = Provider.of<NewsController>(context, listen: false);
      controller.refreshData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Malaysia Health News'),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
      ),
      body: Consumer<NewsController>(
        builder: (context, controller, child) {
          if (controller.isLoading && controller.articles.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (controller.error != null) {
            return Center(child: Text('Error: ${controller.error}'));
          }

          return RefreshIndicator(
            onRefresh: controller.refreshData,
            child: ListView(
              children: [
                CovidCasesCard(cases: controller.covidCases),
                ...controller.articles
                    .map((article) => NewsCard(article: article)),
              ],
            ),
          );
        },
      ),
    );
  }
}
