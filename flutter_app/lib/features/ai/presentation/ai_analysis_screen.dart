import 'package:flutter/material.dart';
import '../../../app/config/theme.dart';
import '../../../core/api.dart';

class AIAnalysisScreen extends StatelessWidget {
  final String symbol;
  const AIAnalysisScreen({super.key, required this.symbol});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('$symbol Analysis'),
        leading: IconButton(icon: const Icon(Icons.arrow_back_rounded), onPressed: () => Navigator.pop(context)),
      ),
      body: SafeArea(child: _AIAnalysisBody(symbol: symbol)),
    );
  }
}

class _AIAnalysisBody extends StatefulWidget {
  final String symbol;
  const _AIAnalysisBody({required this.symbol});

  @override
  State<_AIAnalysisBody> createState() => _AIAnalysisBodyState();
}

class _AIAnalysisBodyState extends State<_AIAnalysisBody> {
  Map? _analysis;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final r = await Api.post('/ai/chat', {'message': 'Analyze ${widget.symbol} in detail with fundamentals, technicals, and recommendation'});
      final msg = r['response'] as String? ?? 'No analysis available.';
      final d = await Api.get('/markets/stocks/${widget.symbol}');
      if (mounted) setState(() { _analysis = {'analysis': msg, 'data': d is Map ? d : null}; _loading = false; });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    final data = _analysis?['data'] as Map<String, dynamic>?;
    final ltp = (data?['last_price'] ?? 0) as num;
    final chg = (data?['change'] ?? 0) as num;
    final up = chg >= 0;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        if (data != null) Container(
          width: double.infinity, padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF1E3A5F), Color(0xFF131D2E)], begin: Alignment.topLeft, end: Alignment.bottomRight), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white10)),
          child: Column(children: [
            Text(widget.symbol, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: Colors.white)),
            const SizedBox(height: 4),
            Text(data['name'] ?? '', style: const TextStyle(color: Colors.white60, fontSize: 14)),
            const SizedBox(height: 12),
            Text('₹${ltp.toStringAsFixed(2)}', style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: -1)),
            const SizedBox(height: 6),
            Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: (up ? AppTheme.emeraldGreen : AppTheme.red).withValues(alpha: 0.2), borderRadius: BorderRadius.circular(8)),
              child: Text('${up ? "+" : ""}${chg.toStringAsFixed(2)} (${(data!['change_percent'] ?? 0).toStringAsFixed(2)}%)', style: TextStyle(color: up ? AppTheme.emeraldGreen : AppTheme.red, fontSize: 14, fontWeight: FontWeight.w600))),
            const SizedBox(height: 16),
            Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
              _Stat(label: 'Open', value: '₹${(data!['open'] ?? 0).toStringAsFixed(0)}'),
              _Stat(label: 'High', value: '₹${(data!['high'] ?? 0).toStringAsFixed(0)}'),
              _Stat(label: 'Low', value: '₹${(data!['low'] ?? 0).toStringAsFixed(0)}'),
              _Stat(label: 'P/E', value: '${data!['pe_ratio'] ?? '--'}'),
            ]),
          ]),
        ),
        const SizedBox(height: 24),
        Row(children: [
          Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: AppTheme.accent.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(6)),
            child: const Text('AI Analysis', style: TextStyle(color: AppTheme.accent, fontSize: 11, fontWeight: FontWeight.w600))),
          const Spacer(),
          Icon(Icons.auto_awesome_rounded, color: AppTheme.accent.withValues(alpha: 0.5), size: 16),
        ]),
        const SizedBox(height: 12),
        Container(
          width: double.infinity, padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(color: AppTheme.cardOf(context), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white10)),
          child: Text(_analysis?['analysis'] as String? ?? 'No analysis available.', style: TextStyle(color: AppTheme.textOf(context), fontSize: 14, height: 1.7)),
        ),
        const SizedBox(height: 24),
        Center(child: TextButton.icon(
          icon: const Icon(Icons.chat_rounded, size: 18),
          label: const Text('Ask FinSwitch AI'),
          onPressed: () => Navigator.pop(context),
        )),
      ]),
    );
  }
}

class _Stat extends StatelessWidget {
  final String label, value;
  const _Stat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Text(label, style: const TextStyle(color: Colors.white60, fontSize: 11)),
      const SizedBox(height: 4),
      Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13)),
    ]);
  }
}
