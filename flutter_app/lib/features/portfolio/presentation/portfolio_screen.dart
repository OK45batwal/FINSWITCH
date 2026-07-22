import 'package:flutter/material.dart';
import '../../../app/config/theme.dart';
import '../../../core/api.dart';

class PortfolioScreen extends StatefulWidget {
  const PortfolioScreen({super.key});

  @override
  State<PortfolioScreen> createState() => _PortfolioScreenState();
}

class _PortfolioScreenState extends State<PortfolioScreen> {
  Map? _summary;
  List _holdings = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final s = await Api.get('/portfolio/summary');
      final h = await Api.get('/portfolio/holdings');
      if (mounted) setState(() {
        _summary = s;
        _holdings = h is List ? h : [];
        _loading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Portfolio')),
      body: SafeArea(
        child: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  _PortfolioSummary(summary: _summary),
                  const SizedBox(height: 24),
                  Text('Holdings', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 12),
                  if (_holdings.isEmpty)
                    Padding(padding: EdgeInsets.all(32), child: Center(child: Text('No holdings', style: TextStyle(color: AppTheme.mutedOf(context)))))
                  else
                    ..._holdings.map((h) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _HoldingCard(holding: h),
                    )),
                ]),
              ),
            ),
      ),
    );
  }
}

class _PortfolioSummary extends StatelessWidget {
  final Map? summary;
  const _PortfolioSummary({this.summary});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF1E3A5F), Color(0xFF131D2E)], begin: Alignment.topLeft, end: Alignment.bottomRight), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white10)),
      child: Column(children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          _SummaryItem(label: 'Total Value', value: '₹${summary?['current_value']?.toStringAsFixed(0) ?? '--'}'),
          _SummaryItem(label: 'Invested', value: '₹${summary?['total_invested']?.toStringAsFixed(0) ?? '--'}'),
          _SummaryItem(label: 'Returns', value: '₹${summary?['total_returns']?.toStringAsFixed(0) ?? '--'}'),
        ]),
        const SizedBox(height: 16),
        Container(
          width: double.infinity, padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: (summary?['today_pl'] ?? 0) >= 0 ? AppTheme.emeraldGreen.withValues(alpha: 0.1) : AppTheme.red.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon((summary?['today_pl'] ?? 0) >= 0 ? Icons.trending_up_rounded : Icons.trending_down_rounded, color: (summary?['today_pl'] ?? 0) >= 0 ? AppTheme.emeraldGreen : AppTheme.red, size: 18),
            const SizedBox(width: 6),
            Text('${(summary?['today_pl'] ?? 0) >= 0 ? '+' : ''}${summary?['today_pl']?.toStringAsFixed(0) ?? '0'} today', style: TextStyle(color: (summary?['today_pl'] ?? 0) >= 0 ? AppTheme.emeraldGreen : AppTheme.red, fontSize: 13, fontWeight: FontWeight.w600)),
          ]),
        ),
      ]),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final String label, value;
  const _SummaryItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Text(label, style: TextStyle(color: AppTheme.mutedOf(context), fontSize: 12)),
      const SizedBox(height: 4),
      Text(value, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppTheme.textOf(context))),
    ]);
  }
}

class _HoldingCard extends StatelessWidget {
  final Map holding;
  const _HoldingCard({required this.holding});

  @override
  Widget build(BuildContext context) {
    final qty = (holding['quantity'] ?? 1).toDouble();
    final avg = (holding['avg_price'] ?? 0).toDouble();
    final ltp = (holding['ltp'] ?? 0).toDouble();
    final invested = qty * avg;
    final current = qty * ltp;
    final pl = current - invested;
    final plPct = invested > 0 ? (pl / invested) * 100 : 0.0;
    final up = pl >= 0;
    final sym = holding['symbol'] as String? ?? '?';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppTheme.cardOf(context), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white10)),
      child: Row(children: [
        Container(width: 44, height: 44, decoration: BoxDecoration(color: AppTheme.primaryBlue.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(12)),
          child: Center(child: Text(sym[0], style: const TextStyle(color: AppTheme.primaryBlue, fontWeight: FontWeight.w800, fontSize: 16)))),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(sym, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: AppTheme.textOf(context))),
          if (holding['name'] != null) Text(holding['name'], style: TextStyle(color: AppTheme.mutedOf(context), fontSize: 12)),
          const SizedBox(height: 4),
          Text('${qty.toInt()} shares · Avg ₹${avg.toStringAsFixed(2)}', style: TextStyle(color: AppTheme.mutedOf(context), fontSize: 11)),
        ])),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text('₹${current.toStringAsFixed(2)}', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: AppTheme.textOf(context))),
          const SizedBox(height: 2),
          Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: (up ? AppTheme.emeraldGreen : AppTheme.red).withValues(alpha: 0.15), borderRadius: BorderRadius.circular(6)),
            child: Text('${up ? '+' : ''}${plPct.toStringAsFixed(2)}%', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: up ? AppTheme.emeraldGreen : AppTheme.red))),
        ]),
      ]),
    );
  }
}
