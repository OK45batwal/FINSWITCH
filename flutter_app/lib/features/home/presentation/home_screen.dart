import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../app/config/theme.dart';
import '../../../core/api.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Map? _portfolio;
  List _indices = [];
  List _news = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final p = await Api.get('/portfolio/summary');
    final i = await Api.get('/markets/indices');
    final n = await Api.get('/news');
    if (mounted) setState(() {
      _portfolio = p is Map ? p : null;
      _indices = (i is List ? i : <dynamic>[]).cast<Map<String, dynamic>>();
      _news = (n is List ? n : <dynamic>[]).take(3).toList();
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: SizedBox(
          height: 28,
          child: Image.asset('assets/logo-horizontal.png', fit: BoxFit.contain, filterQuality: FilterQuality.high),
        ),
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
      decoration: BoxDecoration(color: AppTheme.cardOf(context), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white10)),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(width: 48, height: 48, decoration: BoxDecoration(color: AppTheme.primaryBlue.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(12)),
          child: const Icon(Icons.article_rounded, color: AppTheme.primaryBlue, size: 22)),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(n['title'] ?? '', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: AppTheme.textOf(context))),
          const SizedBox(height: 2),
          Text(n['summary'] ?? '', style: TextStyle(fontSize: 12, color: AppTheme.mutedOf(context)), maxLines: 2),
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
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF1D4ED8), Color(0xFF2563EB)], begin: Alignment.topLeft, end: Alignment.bottomRight), borderRadius: BorderRadius.circular(20)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Portfolio Value', style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500)),
        const SizedBox(height: 4),
        Text('₹${p?['current_value']?.toStringAsFixed(0) ?? '--'}', style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: -1)),
        const SizedBox(height: 6),
        Row(children: [
          Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3), decoration: BoxDecoration(color: AppTheme.emeraldGreen.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(6)),
            child: Text('+${p?['today_pl_percent']?.toStringAsFixed(2) ?? '--'}% today', style: const TextStyle(color: AppTheme.emeraldGreen, fontSize: 12, fontWeight: FontWeight.w600))),
          const SizedBox(width: 12),
          Text('Net +₹${p?['today_pl']?.toStringAsFixed(0) ?? '--'}', style: const TextStyle(color: Colors.white70, fontSize: 13)),
        ]),
      ]),
    );
  }
}

class _QuickActions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final actions = [
      (Icons.add_circle_outline, 'Invest', AppTheme.primaryBlue),
      (Icons.swap_horiz_rounded, 'SIP', AppTheme.accent),
      (Icons.sell_outlined, 'Sell', AppTheme.emeraldGreen),
      (Icons.history_rounded, 'History', const Color(0xFFA78BFA)),
    ];
    return Row(mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: actions.map((a) => Column(children: [
        Container(width: 52, height: 52, decoration: BoxDecoration(color: a.$3.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(16)),
          child: IconButton(onPressed: () {}, icon: Icon(a.$1, color: a.$3, size: 24), padding: EdgeInsets.zero)),
        const SizedBox(height: 6),
        Text(a.$2, style: TextStyle(color: AppTheme.mutedOf(context), fontSize: 12, fontWeight: FontWeight.w500)),
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
      decoration: BoxDecoration(color: AppTheme.cardOf(context), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white10)),
      child: Column(children: indices.map((d) {
        final up = (d['change_percent'] ?? 0) >= 0;
        return Column(children: [
          if (indices.indexOf(d) > 0) const Divider(height: 20),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(d['symbol'] ?? '', style: TextStyle(color: AppTheme.mutedOf(context), fontSize: 14, fontWeight: FontWeight.w500)),
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text(d['last_value']?.toStringAsFixed(2) ?? '', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppTheme.textOf(context))),
              Text('${d['change_percent'] >= 0 ? '+' : ''}${d['change_percent']?.toStringAsFixed(2) ?? ''}%', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: up ? AppTheme.emeraldGreen : AppTheme.red)),
            ]),
          ]),
        ]);
      }).toList()),
    );
  }
}
