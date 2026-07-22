import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:go_router/go_router.dart';
import '../../../app/config/theme.dart';
import '../../../core/api.dart';

class StockDetailScreen extends StatefulWidget {
  final String symbol;
  const StockDetailScreen({super.key, required this.symbol});

  @override
  State<StockDetailScreen> createState() => _StockDetailScreenState();
}

class _StockDetailScreenState extends State<StockDetailScreen> {
  Map? _data;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final d = await Api.get('/markets/stocks/${widget.symbol}');
      if (mounted) setState(() { _data = d is Map ? d : null; _loading = false; });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.symbol),
        leading: IconButton(icon: const Icon(Icons.arrow_back_rounded), onPressed: () => Navigator.pop(context)),
        actions: [
        IconButton(icon: const Icon(Icons.auto_awesome_rounded, color: AppTheme.accent), onPressed: () => context.push('/stock/${widget.symbol}/analysis')),
        IconButton(icon: const Icon(Icons.notifications_outlined), onPressed: () {}),
      ],
      ),
      body: SafeArea(
        child: _loading
          ? const Center(child: CircularProgressIndicator())
          : _StockBody(data: _data, symbol: widget.symbol),
      ),
    );
  }
}

class _PriceRow extends StatelessWidget {
  final bool up;
  final num ltp, chg, pct;
  const _PriceRow({required this.up, required this.ltp, required this.chg, required this.pct});

  @override
  Widget build(BuildContext context) {
    final badgeColor = up ? AppTheme.emeraldGreen : AppTheme.red;
    return Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
      Text('₹${ltp.toStringAsFixed(2)}', style: TextStyle(fontSize: 36, fontWeight: FontWeight.w800, color: AppTheme.textOf(context), letterSpacing: -1)),
      const SizedBox(width: 12),
      Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(color: badgeColor.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(6)),
          child: Text('${up ? "+" : ""}${chg.toStringAsFixed(2)} (${pct.toStringAsFixed(2)}%)', style: TextStyle(color: badgeColor, fontSize: 13, fontWeight: FontWeight.w600)),
        ),
      ),
    ]);
  }
}

class _StockBody extends StatelessWidget {
  final Map? data;
  final String symbol;
  const _StockBody({this.data, required this.symbol});

  @override
  Widget build(BuildContext context) {
    final d = data;
    final ltp = (d?['last_price'] ?? 0) as num;
    final chg = (d?['change'] ?? 0) as num;
    final pct = (d?['change_percent'] ?? 0) as num;
    final up = chg >= 0;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _PriceRow(up: up, ltp: ltp, chg: chg, pct: pct),
        const SizedBox(height: 8),
        Text('NSE: $symbol', style: TextStyle(color: AppTheme.mutedOf(context), fontSize: 13)),
        const SizedBox(height: 24),
        SizedBox(height: 220, child: _Chart(data: d)),
        const SizedBox(height: 24),
        _QuickStats(data: d),
        const SizedBox(height: 24),
        _ActionButtons(),
        const SizedBox(height: 24),
        Text('About $symbol', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        Text(d?['description'] ?? 'No description available.', style: TextStyle(color: AppTheme.mutedOf(context), fontSize: 14, height: 1.6)),
      ]),
    );
  }
}

class _Chart extends StatelessWidget {
  final Map? data;
  const _Chart({this.data});

  @override
  Widget build(BuildContext context) {
    final spots = (data?['chart_data'] as List?)?.asMap().entries.map((e) => FlSpot(e.key.toDouble(), (e.value as num).toDouble())).toList() ??
      List.generate(20, (i) => FlSpot(i.toDouble(), 60 + i * 3 + (i % 5) * 10));
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppTheme.cardOf(context), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white10)),
      child: LineChart(LineChartData(
        gridData: const FlGridData(show: false), titlesData: const FlTitlesData(show: false), borderData: FlBorderData(show: false),
        lineBarsData: [LineChartBarData(spots: spots, isCurved: true, color: AppTheme.primaryBlue, barWidth: 2, dotData: const FlDotData(show: false), belowBarData: BarAreaData(show: true, color: AppTheme.primaryBlue.withValues(alpha: 0.1)))],
      ), duration: Duration.zero),
    );
  }
}

class _QuickStats extends StatelessWidget {
  final Map? data;
  const _QuickStats({this.data});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      _StatCard(label: 'Open', value: '₹${(data?['open'] ?? 0).toStringAsFixed(2)}'),
      _StatCard(label: 'High', value: '₹${(data?['high'] ?? 0).toStringAsFixed(2)}'),
      _StatCard(label: 'Low', value: '₹${(data?['low'] ?? 0).toStringAsFixed(2)}'),
      _StatCard(label: 'Volume', value: '${data?['volume'] ?? '--'}'),
      _StatCard(label: 'P/E', value: '${data?['pe_ratio'] ?? '--'}'),
    ]);
  }
}

class _StatCard extends StatelessWidget {
  final String label, value;
  const _StatCard({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.only(right: 8), padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(color: AppTheme.cardOf(context), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white10)),
        child: Column(children: [
          Text(label, style: TextStyle(color: AppTheme.mutedOf(context), fontSize: 11)),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppTheme.textOf(context))),
        ]),
      ),
    );
  }
}

class _ActionButtons extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Expanded(child: ElevatedButton(onPressed: () {}, child: const Text('Buy'))),
      const SizedBox(width: 12),
      Expanded(child: OutlinedButton(onPressed: () {}, style: OutlinedButton.styleFrom(foregroundColor: AppTheme.textOf(context), side: const BorderSide(color: AppTheme.primaryBlue), padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))), child: Text('Sell'))),
    ]);
  }
}
