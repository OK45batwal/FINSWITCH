import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import '../../../app/config/theme.dart';

class MarketsScreen extends ConsumerWidget {
  const MarketsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Markets')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _MarketIndices(),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Top Stocks', style: Theme.of(context).textTheme.titleLarge),
                  _FilterChips(),
                ],
              ),
              const SizedBox(height: 12),
              _StockList(),
            ],
          ),
        ),
      ),
    );
  }
}

class _MarketIndices extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0F2239), Color(0xFF1A2538)],
          begin: Alignment.topLeft, end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _IndexStat(name: 'NIFTY', value: '24,682.75', change: '+0.76%', up: true),
          Container(width: 1, height: 40, color: Colors.white10),
          _IndexStat(name: 'SENSEX', value: '81,523.40', change: '+0.76%', up: true),
          Container(width: 1, height: 40, color: Colors.white10),
          _IndexStat(name: 'BANK NIFTY', value: '52,891.15', change: '-0.23%', up: false),
        ],
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
    return Column(
      children: [
        Text(name, style: TextStyle(color: AppTheme.muted, fontSize: 12)),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.text)),
        const SizedBox(height: 2),
        Text(change, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: up ? AppTheme.emeraldGreen : AppTheme.red)),
      ],
    );
  }
}

class _FilterChips extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: ['NIFTY', 'BSE'].map((f) => Container(
        margin: const EdgeInsets.only(left: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: f == 'NIFTY' ? AppTheme.primaryBlue.withValues(alpha: 0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: f == 'NIFTY' ? AppTheme.primaryBlue : Colors.white15),
        ),
        child: Text(f, style: TextStyle(
          fontSize: 12, fontWeight: FontWeight.w600,
          color: f == 'NIFTY' ? AppTheme.primaryBlue : AppTheme.muted,
        )),
      )).toList(),
    );
  }
}

class _StockList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final stocks = [
      ('RELIANCE', 2890.45, 12.30, true, '₹2.3T'),
      ('TCS', 4120.80, 45.20, true, '₹1.5T'),
      ('HDFCBANK', 1678.25, -8.50, false, '₹9.4L'),
      ('INFY', 1892.60, 32.40, true, '₹8.1L'),
      ('ICICIBANK', 1185.30, -5.20, false, '₹8.3L'),
    ];
    return Column(
      children: stocks.map((s) => GestureDetector(
        onTap: () => context.push('/stock/${s.$1}'),
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.card,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white10),
          ),
          child: Row(
            children: [
              Container(
                width: 44, height: 44,
                decoration: BoxDecoration(
                  color: AppTheme.primaryBlue.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(child: Text(s.$1[0], style: TextStyle(color: AppTheme.primaryBlue, fontWeight: FontWeight.w800, fontSize: 16))),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(s.$1, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppTheme.text)),
                    const SizedBox(height: 1),
                    Text(s.$5, style: TextStyle(color: AppTheme.muted, fontSize: 12)),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('₹${s.$2.toStringAsFixed(2)}', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: AppTheme.text)),
                  const SizedBox(height: 2),
                  Text('${s.$4 ? '+' : ''}${s.$3.toStringAsFixed(2)}', style: TextStyle(
                    fontWeight: FontWeight.w600, fontSize: 12,
                    color: s.$4 ? AppTheme.emeraldGreen : AppTheme.red,
                  )),
                ],
              ),
            ],
          ),
        ),
      )).toList(),
    );
  }
}
