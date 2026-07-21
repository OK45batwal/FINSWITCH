import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../app/config/theme.dart';

final _categories = ['All', 'Markets', 'Economy', 'Earnings', 'IPO', 'Global'];
final _articles = [
  _Article(
    'SEBI New F&O Rules: What Investors Need to Know', 'Markets',
    'SEBI tightens index derivatives norms effective April 2026, increasing contract size and reducing expiry frequency.',
    '2h ago', Icons.trending_up_rounded,
  ),
  _Article(
    'RBI Holds Repo Rate at 6.50%', 'Economy',
    'RBI keeps repo rate unchanged for eighth straight monetary policy meet, maintains neutral stance.',
    '5h ago', Icons.account_balance_rounded,
  ),
  _Article(
    'TCS Q3 Results Beat Estimates', 'Earnings',
    'TCS reports 12% net profit growth in Q3 FY26, exceeds analyst expectations with strong deal pipeline.',
    '8h ago', Icons.business_rounded,
  ),
  _Article(
    'Zomato IPO: Should You Subscribe?', 'IPO',
    'Zomato\'s upcoming IPO has garnered significant attention with a price band of ₹72-76 per share.',
    '12h ago', Icons.rocket_launch_rounded,
  ),
  _Article(
    'Budget 2026: Key Market Impact', 'Economy',
    'Union Budget 2026 focuses on infrastructure spending, tax reforms, and fiscal consolidation targets.',
    '1d ago', Icons.description_rounded,
  ),
];

class NewsScreen extends ConsumerWidget {
  const NewsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('News')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 38,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _categories.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (_, i) => _CategoryChip(
                    label: _categories[i],
                    selected: i == 0,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _FeaturedArticle(),
              const SizedBox(height: 24),
              Text('Latest', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 12),
              ..._articles.map((a) => Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.card,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white10),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 48, height: 48,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryBlue.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(a.icon, color: AppTheme.primaryBlue, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppTheme.accent.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(a.category, style: TextStyle(color: AppTheme.accent, fontSize: 10, fontWeight: FontWeight.w600)),
                              ),
                              const Spacer(),
                              Text(a.time, style: TextStyle(color: AppTheme.muted, fontSize: 11)),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(a.title, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: AppTheme.text)),
                          const SizedBox(height: 4),
                          Text(a.snippet, style: TextStyle(fontSize: 12, color: AppTheme.muted), maxLines: 2),
                        ],
                      ),
                    ),
                  ],
                ),
              )),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final bool selected;
  const _CategoryChip({required this.label, required this.selected});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: selected ? AppTheme.primaryBlue : Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: selected ? AppTheme.primaryBlue : Colors.white15),
      ),
      child: Text(label, style: TextStyle(
        fontSize: 13, fontWeight: FontWeight.w600,
        color: selected ? Colors.white : AppTheme.muted,
      )),
    );
  }
}

class _FeaturedArticle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 180,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1D4ED8), Color(0xFF2563EB)],
          begin: Alignment.topLeft, end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Text('Featured', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
          ),
          const SizedBox(height: 8),
          const Text(
            'Budget 2026: Key Announcements & Market Impact',
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700, height: 1.2),
          ),
          const SizedBox(height: 6),
          Text('Read the full analysis and market reaction', style: TextStyle(color: Colors.white70, fontSize: 13)),
        ],
      ),
    );
  }
}

class _Article {
  final String title, category, snippet, time;
  final IconData icon;
  _Article(this.title, this.category, this.snippet, this.time, this.icon);
}
