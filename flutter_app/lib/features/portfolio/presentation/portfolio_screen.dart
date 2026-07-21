import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/config/theme.dart';

class PortfolioScreen extends ConsumerWidget {
  const PortfolioScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Portfolio')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _PortfolioSummary(),
              const SizedBox(height: 24),
              Text('Holdings', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 12),
              _HoldingCard(
                symbol: 'RELIANCE', name: 'Reliance Industries',
                qty: 10, avgPrice: 2850, currentPrice: 2890.45,
              ),
              const SizedBox(height: 10),
              _HoldingCard(
                symbol: 'TCS', name: 'Tata Consultancy Services',
                qty: 5, avgPrice: 4050, currentPrice: 4120.80,
              ),
              const SizedBox(height: 10),
              _HoldingCard(
                symbol: 'HDFCBANK', name: 'HDFC Bank',
                qty: 20, avgPrice: 1650, currentPrice: 1678.25,
              ),
              const SizedBox(height: 10),
              _HoldingCard(
                symbol: 'INFY', name: 'Infosys',
                qty: 15, avgPrice: 1850, currentPrice: 1892.60,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PortfolioSummary extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E3A5F), Color(0xFF131D2E)],
          begin: Alignment.topLeft, end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _SummaryItem(label: 'Total Value', value: '₹12,45,890'),
              _SummaryItem(label: 'Invested', value: '₹11,20,000'),
              _SummaryItem(label: 'Returns', value: '+₹1,25,890'),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppTheme.emeraldGreen.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.trending_up_rounded, color: AppTheme.emeraldGreen, size: 18),
                const SizedBox(width: 6),
                Text('Portfolio up 2.34% today | ₹28,450 gain', style: TextStyle(
                  color: AppTheme.emeraldGreen, fontSize: 13, fontWeight: FontWeight.w600,
                )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final String label, value;
  const _SummaryItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: TextStyle(color: AppTheme.muted, fontSize: 12)),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppTheme.text)),
      ],
    );
  }
}

class _HoldingCard extends StatelessWidget {
  final String symbol, name;
  final int qty;
  final double avgPrice, currentPrice;

  const _HoldingCard({
    required this.symbol, required this.name,
    required this.qty, required this.avgPrice, required this.currentPrice,
  });

  @override
  Widget build(BuildContext context) {
    final invested = qty * avgPrice;
    final current = qty * currentPrice;
    final pl = current - invested;
    final plPct = (pl / invested) * 100;
    final up = pl >= 0;

    return Container(
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
            child: Center(child: Text(symbol[0], style: TextStyle(color: AppTheme.primaryBlue, fontWeight: FontWeight.w800, fontSize: 16))),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(symbol, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: AppTheme.text)),
                Text(name, style: TextStyle(color: AppTheme.muted, fontSize: 12)),
                const SizedBox(height: 4),
                Text('$qty shares · Avg ₹${avgPrice.toStringAsFixed(2)}', style: TextStyle(color: AppTheme.muted, fontSize: 11)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('₹${current.toStringAsFixed(2)}', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: AppTheme.text)),
              const SizedBox(height: 2),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: (up ? AppTheme.emeraldGreen : AppTheme.red).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text('${up ? '+' : ''}${plPct.toStringAsFixed(2)}%', style: TextStyle(
                  fontWeight: FontWeight.w600, fontSize: 12,
                  color: up ? AppTheme.emeraldGreen : AppTheme.red,
                )),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
