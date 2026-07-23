import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../app/config/theme.dart';
import '../../../app/config/brand_logo_header.dart';
import '../../../core/api.dart';
import '../../../core/app_update_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Map? _portfolio;
  List _indices = [];
  List _news = [];
  List _insights = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AppUpdateService.checkForUpdate(context);
    });
  }

  Future<void> _load() async {
    try {
      final results = await Future.wait([
        Api.get('/portfolio/summary'),
        Api.get('/markets/indices'),
        Api.get('/news'),
        Api.post('/ai/chat', {'message': 'Daily market insights and key levels for today July 22, 2026'}),
      ]);
      if (mounted) setState(() {
        _portfolio = results[0] is Map ? results[0] : null;
        _indices = (results[1] is List ? results[1] : <dynamic>[]).cast<Map<String, dynamic>>();
        _news = (results[2] is List ? results[2] : <dynamic>[]).take(3).toList();
        final aiResponse = results[3] is Map ? results[3]['response'] as String? : null;
        _insights = aiResponse != null ? aiResponse.split('\n').where((l) => l.trim().isNotEmpty && !l.startsWith('**')).take(4).toList() : _defaultInsights();
        _loading = false;
      });
    } catch (_) {
      if (mounted) setState(() { _insights = _defaultInsights(); _loading = false; });
    }
  }

  List<String> _defaultInsights() => [
    'Nifty support at 23,200, resistance at 23,600. Banking and energy leading.',
    'FII outflows of ₹2,100 Cr offset by DII buying of ₹1,850 Cr.',
    'IT sector under pressure from global rate uncertainty. Watch INFY, TCS.',
    'Gold hits all-time high at ₹76,500. Safe-haven demand rising.',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const BrandLogoHeader(height: 32),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline_rounded),
            onPressed: () => context.push('/profile'),
          ),
        ],
      ),
      body: SafeArea(
        child: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  _PortfolioOverview(portfolio: _portfolio),
                  const SizedBox(height: 20),
                  _QuickActions(),
                  const SizedBox(height: 24),
                  Text('Market Overview', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 12),
                  _MarketTicker(indices: _indices),
                  const SizedBox(height: 24),
                  Row(children: [
                    Text('AI Insights', style: Theme.of(context).textTheme.titleLarge),
                    const Spacer(),
                    Icon(Icons.auto_awesome_rounded, color: AppTheme.accent, size: 16),
                  ]),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity, padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: Theme.of(context).dividerTheme.color ?? Theme.of(context).colorScheme.outlineVariant)),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: _insights.map((i) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Container(width: 6, height: 6, margin: const EdgeInsets.only(top: 6, right: 10), decoration: BoxDecoration(color: AppTheme.accent, shape: BoxShape.circle)),
                        Expanded(child: Text(i, style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 13, height: 1.4))),
                      ]),
                    )).toList()),
                  ),
                  const SizedBox(height: 24),
                  Text('Latest News', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 12),
                  ..._news.map((n) => _buildNewsItem(n as Map<String, dynamic>)),
                ]),
              ),
            ),
      ),
    );
  }

  Widget _buildNewsItem(Map n) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12), padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: Theme.of(context).dividerTheme.color ?? Theme.of(context).colorScheme.outlineVariant)),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(width: 48, height: 48, decoration: BoxDecoration(color: AppTheme.emeraldGreen.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(12)),
          child: const Icon(Icons.article_rounded, color: AppTheme.emeraldGreen, size: 22)),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(n['title'] ?? '', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Theme.of(context).colorScheme.onSurface)),
          const SizedBox(height: 2),
          Text(n['summary'] ?? '', style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6)), maxLines: 2),
        ])),
      ]),
    );
  }
}

class _PortfolioOverview extends StatelessWidget {
  final Map? portfolio;
  const _PortfolioOverview({this.portfolio});

  @override
  Widget build(BuildContext context) {
    final p = portfolio;
    final todayPl = (p?['today_pl'] as num?)?.toDouble() ?? 0.0;
    final todayPlPct = (p?['today_pl_percent'] as num?)?.toDouble() ?? 0.0;
    final isPos = todayPl >= 0;
    final plColor = isPos ? AppTheme.emeraldGreen : AppTheme.red;
    final prefix = isPos ? '+' : '';

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF059669), Color(0xFF10B981)], begin: Alignment.topLeft, end: Alignment.bottomRight), borderRadius: BorderRadius.circular(20)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Portfolio Value', style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500)),
        const SizedBox(height: 4),
        Text('₹${p?['current_value']?.toStringAsFixed(0) ?? '--'}', style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: -1)),
        const SizedBox(height: 6),
        Row(children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(color: plColor.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(6)),
            child: Text('$prefix${todayPlPct.toStringAsFixed(2)}% today', style: TextStyle(color: plColor, fontSize: 12, fontWeight: FontWeight.w600)),
          ),
          const SizedBox(width: 12),
          Text('Net $prefix₹${todayPl.abs().toStringAsFixed(0)}', style: const TextStyle(color: Colors.white70, fontSize: 13)),
        ]),
      ]),
    );
  }
}

class _QuickActions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final actions = [
      (Icons.add_circle_outline, 'Invest', AppTheme.emeraldGreen),
      (Icons.swap_horiz_rounded, 'SIP', AppTheme.accent),
      (Icons.sell_outlined, 'Sell', AppTheme.emeraldGreen),
      (Icons.history_rounded, 'History', const Color(0xFFA78BFA)),
    ];
    return Row(mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: actions.map((a) => Column(children: [
        Container(width: 52, height: 52, decoration: BoxDecoration(color: a.$3.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(16)),
          child: IconButton(onPressed: () {}, icon: Icon(a.$1, color: a.$3, size: 24), padding: EdgeInsets.zero)),
        const SizedBox(height: 6),
        Text(a.$2, style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6), fontSize: 12, fontWeight: FontWeight.w500)),
      ])).toList(),
    );
  }
}

class _MarketTicker extends StatelessWidget {
  final List indices;
  const _MarketTicker({required this.indices});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface, borderRadius: BorderRadius.circular(20), border: Border.all(color: Theme.of(context).dividerTheme.color ?? Theme.of(context).colorScheme.outlineVariant)),
      child: Column(children: indices.map((d) {
        final up = (d['change_percent'] ?? 0) >= 0;
        return Column(children: [
          if (indices.indexOf(d) > 0) const Divider(height: 20),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(d['symbol'] ?? '', style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6), fontSize: 14, fontWeight: FontWeight.w500)),
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text(d['last_value']?.toStringAsFixed(2) ?? '', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Theme.of(context).colorScheme.onSurface)),
              Text('${d['change_percent'] >= 0 ? '+' : ''}${d['change_percent']?.toStringAsFixed(2) ?? ''}%', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: up ? AppTheme.emeraldGreen : AppTheme.red)),
            ]),
          ]),
        ]);
      }).toList()),
    );
  }
}
