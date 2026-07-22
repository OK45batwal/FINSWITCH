import 'package:flutter/material.dart';
import '../../../app/config/theme.dart';
import '../../../core/api.dart';

class NewsScreen extends StatefulWidget {
  const NewsScreen({super.key});

  @override
  State<NewsScreen> createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> {
  List _articles = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final n = await Api.get('/news');
      if (mounted) setState(() {
        _articles = n is List ? n : [];
        _loading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('News')),
      body: SafeArea(
        child: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const SizedBox(height: 16),
                  if (_articles.isNotEmpty) _FeaturedArticle(article: _articles.first),
                  if (_articles.isNotEmpty) const SizedBox(height: 24),
                  Text('Latest', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 12),
                  ..._articles.map((a) => Container(
                    margin: const EdgeInsets.only(bottom: 12), padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: AppTheme.cardOf(context), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white10)),
                    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Container(width: 48, height: 48, decoration: BoxDecoration(color: AppTheme.primaryBlue.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(12)),
                        child: const Icon(Icons.article_rounded, color: AppTheme.primaryBlue, size: 22)),
                      const SizedBox(width: 12),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Row(children: [
                          Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: AppTheme.accent.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(4)),
                            child: Text(a['category'] ?? 'General', style: const TextStyle(color: AppTheme.accent, fontSize: 10, fontWeight: FontWeight.w600))),
                          const Spacer(),
                          Text(a['published_at'] ?? '', style: TextStyle(color: AppTheme.mutedOf(context), fontSize: 11)),
                        ]),
                        const SizedBox(height: 6),
                        Text(a['title'] ?? '', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: AppTheme.textOf(context))),
                        const SizedBox(height: 4),
                        Text(a['summary'] ?? '', style: TextStyle(fontSize: 12, color: AppTheme.mutedOf(context)), maxLines: 2),
                      ])),
                    ]),
                  )),
                ]),
              ),
            ),
      ),
    );
  }
}

class _FeaturedArticle extends StatelessWidget {
  final Map article;
  const _FeaturedArticle({required this.article});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity, height: 180,
      decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF1D4ED8), Color(0xFF2563EB)], begin: Alignment.topLeft, end: Alignment.bottomRight), borderRadius: BorderRadius.circular(20)),
      padding: const EdgeInsets.all(20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.end, children: [
        Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3), decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(6)),
          child: const Text('Featured', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600))),
        const SizedBox(height: 8),
        Text(article['title'] ?? '', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700, height: 1.2)),
        const SizedBox(height: 6),
        Text(article['summary'] ?? '', style: TextStyle(color: Colors.white70, fontSize: 13), maxLines: 2),
      ]),
    );
  }
}
