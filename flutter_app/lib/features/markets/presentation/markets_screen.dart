import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../app/config/theme.dart';
import '../../../core/api.dart';

class MarketsScreen extends StatefulWidget {
  const MarketsScreen({super.key});

  @override
  State<MarketsScreen> createState() => _MarketsScreenState();
}

class _MarketsScreenState extends State<MarketsScreen> {
  List _indices = [];
  List _stocks = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _error = null; _loading = true; });
    try {
      final i = await Api.get('/markets/indices');
      final s = await Api.get('/markets/stocks');
      if (mounted) setState(() {
        _indices = i is List ? i : [];
        _stocks = s is List ? s : [];
        _loading = false;
      });
    } catch (_) {
      if (mounted) setState(() { _error = 'Failed to load market data'; _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Markets')),
      body: SafeArea(
        child: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? ErrorWithRetry(message: _error!, onRetry: _load)
              : RefreshIndicator(
              onRefresh: _load,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  _MarketIndices(indices: _indices),
                  const SizedBox(height: 24),
                  Text('Top Stocks', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 12),
                  _StockList(stocks: _stocks),
                ]),
              ),
            ),
      ),
    );
  }
}

class _MarketIndices extends StatelessWidget {
  final List indices;
  const _MarketIndices({required this.indices});

  @override
  Widget build(BuildContext context) {
    final items = indices.take(3).toList();
    if (items.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface, borderRadius: BorderRadius.circular(20), border: Border.all(color: Theme.of(context).dividerTheme.color ?? Theme.of(context).colorScheme.outlineVariant)),
        child: Center(child: Text('No indices available', style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6)))),
      );
    }
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface, borderRadius: BorderRadius.circular(20), border: Border.all(color: Theme.of(context).dividerTheme.color ?? Theme.of(context).colorScheme.outlineVariant)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: items.expand((d) => [
          if (items.indexOf(d) > 0) SizedBox(width: 1, child: VerticalDivider(color: Theme.of(context).dividerTheme.color ?? Theme.of(context).colorScheme.outlineVariant)),
          _IndexStat(name: d['symbol'] ?? '', value: d['last_value']?.toStringAsFixed(2) ?? '', change: '${d['change_percent'] >= 0 ? '+' : ''}${d['change_percent']?.toStringAsFixed(2) ?? ''}%', up: (d['change_percent'] ?? 0) >= 0),
        ]).toList(),
      ),
    );
  }
}

class _IndexStat extends StatelessWidget {
  final String name, value, change;
  final bool up;
  const _IndexStat({required this.name, required this.value, required this.change, required this.up});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Text(name, style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6), fontSize: 12)),
      const SizedBox(height: 4),
      Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Theme.of(context).colorScheme.onSurface)),
      const SizedBox(height: 2),
      Text(change, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: up ? AppTheme.emeraldGreen : AppTheme.red)),
    ]);
  }
}

class _StockList extends StatelessWidget {
  final List stocks;
  const _StockList({required this.stocks});

  @override
  Widget build(BuildContext context) {
    if (stocks.isEmpty) {
      return Padding(padding: const EdgeInsets.all(32), child: Center(child: Text('No stocks available', style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6)))));
    }
    return Column(
      children: stocks.map((s) => GestureDetector(
        onTap: () => context.push('/stock/${s['symbol']}'),
        child: Container(
          margin: const EdgeInsets.only(bottom: 10), padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: Theme.of(context).dividerTheme.color ?? Theme.of(context).colorScheme.outlineVariant)),
          child: Row(children: [
            Container(width: 44, height: 44, decoration: BoxDecoration(color: AppTheme.emeraldGreen.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(12)),
              child: Center(child: Text((s['symbol'] as String? ?? '?')[0], style: const TextStyle(color: AppTheme.emeraldGreen, fontWeight: FontWeight.w800, fontSize: 16)))),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(s['symbol'] ?? '', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: Theme.of(context).colorScheme.onSurface)),
              Text(s['name'] ?? '', style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6), fontSize: 12)),
            ])),
            const SizedBox(width: 8),
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text('₹${(s['last_price'] ?? 0).toStringAsFixed(2)}', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: Theme.of(context).colorScheme.onSurface)),
              const SizedBox(height: 2),
              Text('${(s['change_percent'] ?? 0) >= 0 ? '+' : ''}${(s['change_percent'] ?? 0).toStringAsFixed(2)}', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: (s['change_percent'] ?? 0) >= 0 ? AppTheme.emeraldGreen : AppTheme.red)),
            ]),
          ]),
        ),
      )).toList(),
    );
  }
}
