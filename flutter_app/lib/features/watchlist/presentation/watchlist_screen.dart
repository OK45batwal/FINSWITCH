import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../app/config/theme.dart';
import '../../../core/api.dart';

class WatchlistScreen extends StatefulWidget {
  const WatchlistScreen({super.key});

  @override
  State<WatchlistScreen> createState() => _WatchlistScreenState();
}

class _WatchlistScreenState extends State<WatchlistScreen> {
  List _items = [];
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
      final r = await Api.get('/watchlist');
      final lists = r is List ? r : (r['data'] is List ? r['data'] : []);
      _items = lists.isNotEmpty ? (lists.first['items'] ?? []) : [];
      if (mounted) setState(() => _loading = false);
    } catch (_) {
      if (mounted) setState(() { _error = 'Failed to load watchlist'; _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Watchlist')),
      body: SafeArea(
        child: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? ErrorWithRetry(message: _error!, onRetry: _load)
              : RefreshIndicator(
              onRefresh: _load,
              child: _items.isEmpty
                ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                    Icon(Icons.visibility_off_rounded, size: 48, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6)),
                    const SizedBox(height: 12),
                    Text('No stocks in watchlist', style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6), fontSize: 15)),
                  ]))
                : ListView.separated(
                    padding: const EdgeInsets.all(20),
                    itemCount: _items.length + 1,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (_, i) {
                      if (i == 0) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Row(children: [
                            Text('${_items.length} stocks', style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6), fontSize: 13)),
                          ]),
                        );
                      }
                      final item = _items[i - 1] as Map;
                      final sym = item['symbol'] as String? ?? '';
                      return _WatchlistItem(symbol: sym, name: item['name'] as String? ?? '');
                    },
                  ),
            ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDialog,
        child: const Icon(Icons.add_rounded),
      ),
    );
  }

  void _showAddDialog() {
    final ctl = TextEditingController();
    showDialog(context: context, builder: (ctx) => AlertDialog(
      title: const Text('Add Stock'),
      content: TextField(controller: ctl, decoration: const InputDecoration(hintText: 'Symbol (e.g. RELIANCE)', prefixIcon: Icon(Icons.search)), autofocus: true),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
        TextButton(onPressed: () {
          final sym = ctl.text.trim().toUpperCase();
          if (sym.isNotEmpty) {
            setState(() => _items.add({'symbol': sym, 'name': sym}));
          }
          Navigator.pop(ctx);
        }, child: const Text('Add')),
      ],
    ));
  }
}

class _WatchlistItem extends StatelessWidget {
  final String symbol, name;
  const _WatchlistItem({required this.symbol, required this.name});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/stock/$symbol'),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: Theme.of(context).dividerTheme.color ?? Theme.of(context).colorScheme.outlineVariant)),
        child: Row(children: [
          Container(width: 44, height: 44, decoration: BoxDecoration(color: AppTheme.emeraldGreen.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(12)),
            child: Center(child: Text(symbol.isNotEmpty ? symbol[0] : '?', style: const TextStyle(color: AppTheme.emeraldGreen, fontWeight: FontWeight.w800, fontSize: 16)))),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(symbol, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: Theme.of(context).colorScheme.onSurface)),
            if (name.isNotEmpty) Text(name, style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6), fontSize: 12)),
          ])),
          Icon(Icons.chevron_right_rounded, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6), size: 20),
        ]),
      ),
    );
  }
}
