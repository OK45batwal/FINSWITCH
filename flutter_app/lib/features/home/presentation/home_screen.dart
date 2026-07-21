import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import '../../../app/config/theme.dart';

final f = NumberFormat('#,##0.00');
final fp = NumberFormat('#,##0');

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mq = MediaQuery.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Image.asset('assets/logo-horizontal.png', height: 28, fit: BoxFit.contain, filterQuality: FilterQuality.high),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline_rounded),
            onPressed: () => context.push('/profile'),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _PortfolioOverview(),
              const SizedBox(height: 20),
              _QuickActions(),
              const SizedBox(height: 24),
              _SectionHeader(title: 'Market Overview'),
              const SizedBox(height: 12),
              _MarketTicker(),
              const SizedBox(height: 24),
              _SectionHeader(title: 'Latest News'),
              const SizedBox(height: 12),
              _NewsPreview(),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final Widget? trailing;
  const _SectionHeader({required this.title, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleLarge),
        trailing ?? Text('See all', style: TextStyle(color: AppTheme.primaryBlue, fontSize: 13, fontWeight: FontWeight.w600)),
      ],
    );
  }
}

class _PortfolioOverview extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1D4ED8), Color(0xFF2563EB)],
          begin: Alignment.topLeft, end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Portfolio Value', style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500)),
          const SizedBox(height: 4),
          Text('\u{20B9}12,45,890', style: TextStyle(
            fontSize: 32, fontWeight: FontWeight.w800,
            color: Colors.white, letterSpacing: -1,
          )),
          const SizedBox(height: 6),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppTheme.emeraldGreen.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text('+2.34% today', style: TextStyle(color: AppTheme.emeraldGreen, fontSize: 12, fontWeight: FontWeight.w600)),
              ),
              const SizedBox(width: 12),
              Text('Net +₹28,450', style: TextStyle(color: Colors.white70, fontSize: 13)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _StatChip(label: 'Invested', value: '₹11,20,000'),
              const SizedBox(width: 16),
              _StatChip(label: 'Returns', value: '₹1,25,890'),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label, value;
  const _StatChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: Colors.white60, fontSize: 12)),
        const SizedBox(height: 2),
        Text(value, style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700)),
      ],
    );
  }
}

class _QuickActions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final actions = [
      _ActionItem(icon: Icons.add_circle_outline, label: 'Invest', color: AppTheme.primaryBlue),
      _ActionItem(icon: Icons.swap_horiz_rounded, label: 'SIP', color: AppTheme.accent),
      _ActionItem(icon: Icons.sell_outlined, label: 'Sell', color: AppTheme.emeraldGreen),
      _ActionItem(icon: Icons.history_rounded, label: 'History', color: const Color(0xFFA78BFA)),
    ];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: actions.map((a) => Column(
        children: [
          Container(
            width: 52, height: 52,
            decoration: BoxDecoration(
              color: a.color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: IconButton(
              onPressed: () {},
              icon: Icon(a.icon, color: a.color, size: 24),
              padding: EdgeInsets.zero,
            ),
          ),
          const SizedBox(height: 6),
          Text(a.label, style: TextStyle(color: AppTheme.muted, fontSize: 12, fontWeight: FontWeight.w500)),
        ],
      )).toList(),
    );
  }
}

class _ActionItem {
  final IconData icon;
  final String label;
  final Color color;
  _ActionItem({required this.icon, required this.label, required this.color});
}

class _MarketTicker extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        children: [
          _IndexRow(name: 'NIFTY 50', value: '24,682.75', change: '+185.40 (+0.76%)', up: true),
          const Divider(height: 20),
          _IndexRow(name: 'SENSEX', value: '81,523.40', change: '+612.80 (+0.76%)', up: true),
          const Divider(height: 20),
          _IndexRow(name: 'BANK NIFTY', value: '52,891.15', change: '-124.30 (-0.23%)', up: false),
        ],
      ),
    );
  }
}

class _IndexRow extends StatelessWidget {
  final String name, value, change;
  final bool up;
  const _IndexRow({required this.name, required this.value, required this.change, required this.up});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(name, style: TextStyle(color: AppTheme.muted, fontSize: 14, fontWeight: FontWeight.w500)),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(value, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppTheme.text)),
            const SizedBox(height: 1),
            Text(change, style: TextStyle(
              fontSize: 12, fontWeight: FontWeight.w600,
              color: up ? AppTheme.emeraldGreen : AppTheme.red,
            )),
          ],
        ),
      ],
    );
  }
}

class _NewsPreview extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final items = [
      ('SEBI New F&O Rules', 'SEBI tightens index derivatives norms effective April 2026', '2h ago'),
      ('RBI Repo Rate', 'RBI keeps repo rate unchanged at 6.50% for eighth straight meet', '5h ago'),
      ('Q3 Earnings', 'TCS beats estimates with 12% net profit growth in Q3 FY26', '8h ago'),
    ];
    return Column(
      children: items.map((n) => Container(
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
              child: const Icon(Icons.article_rounded, color: AppTheme.primaryBlue, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(n.$1, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: AppTheme.text)),
                  const SizedBox(height: 2),
                  Text(n.$2, style: TextStyle(fontSize: 12, color: AppTheme.muted), maxLines: 2),
                  const SizedBox(height: 4),
                  Text(n.$3, style: TextStyle(fontSize: 11, color: AppTheme.muted.withValues(alpha: 0.7))),
                ],
              ),
            ),
          ],
        ),
      )).toList(),
    );
  }
}
