import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../app/config/theme.dart';

class StockDetailScreen extends StatelessWidget {
  final String symbol;
  const StockDetailScreen({super.key, required this.symbol});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(symbol),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications_outlined, color: AppTheme.muted),
            onPressed: () {},
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('₹2,890.45',
                    style: TextStyle(fontSize: 36, fontWeight: FontWeight.w800, color: AppTheme.text, letterSpacing: -1)),
                  const SizedBox(width: 12),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppTheme.emeraldGreen.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text('+12.30 (+0.43%)',
                        style: TextStyle(color: AppTheme.emeraldGreen, fontSize: 13, fontWeight: FontWeight.w600)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text('NSE: RELIANCE', style: TextStyle(color: AppTheme.muted, fontSize: 13)),
              const SizedBox(height: 24),
              SizedBox(
                height: 220,
                child: _Chart(),
              ),
              const SizedBox(height: 24),
              _QuickStats(),
              const SizedBox(height: 24),
              _ActionButtons(),
              const SizedBox(height: 24),
              Text('About ${symbol}', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              Text(
                'Reliance Industries Limited is an Indian multinational conglomerate headquartered in Mumbai. '
                'Its businesses include energy, petrochemicals, textiles, natural resources, retail, and telecommunications.',
                style: TextStyle(color: AppTheme.muted, fontSize: 14, height: 1.6),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Chart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white10),
      ),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(show: false),
          titlesData: FlTitlesData(show: false),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: List.generate(20, (i) => FlSpot(i.toDouble(), 60 + i * 3 + (i % 5) * 10)),
              isCurved: true,
              color: AppTheme.primaryBlue,
              barWidth: 2,
              dotData: FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                color: AppTheme.primaryBlue.withValues(alpha: 0.1),
              ),
            ),
          ],
        ),
        duration: Duration.zero,
      ),
    );
  }
}

class _QuickStats extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _StatCard(label: 'Open', value: '₹2,878.15'),
        _StatCard(label: 'High', value: '₹2,898.60'),
        _StatCard(label: 'Low', value: '₹2,874.20'),
        _StatCard(label: 'Volume', value: '1.2M'),
        _StatCard(label: 'P/E', value: '28.6'),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label, value;
  const _StatCard({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: AppTheme.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white10),
        ),
        child: Column(
          children: [
            Text(label, style: TextStyle(color: AppTheme.muted, fontSize: 11)),
            const SizedBox(height: 4),
            Text(value, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppTheme.text)),
          ],
        ),
      ),
    );
  }
}

class _ActionButtons extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: () {},
            child: const Text('Buy'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              foregroundColor: AppTheme.text,
              side: const BorderSide(color: AppTheme.primaryBlue),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            child: const Text('Sell'),
          ),
        ),
      ],
    );
  }
}
