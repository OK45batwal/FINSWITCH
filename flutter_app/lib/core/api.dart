import 'dart:convert';

import 'package:http/http.dart' as http;

import 'supabase_service.dart';

class Api {
  static const _aiUrl = 'https://finswitch.pages.dev/api/ai';

  static Future<dynamic> get(String path) async {
    final route = Uri.parse(path).path;
    try {
      if (route == '/markets/indices') {
        final rows = await SupabaseService.client.from('indices').select();
        return rows.map(_mapIndex).toList();
      }
      if (route == '/markets/stocks') {
        final rows = await SupabaseService.client.from('stocks').select();
        return rows.map(_mapStock).toList();
      }
      if (route.startsWith('/markets/stocks/')) {
        final row = await SupabaseService.client
            .from('stocks')
            .select()
            .eq('symbol', route.split('/').last.toUpperCase())
            .maybeSingle();
        return row == null ? null : _mapStock(row);
      }
      if (route == '/markets/gainers' || route == '/markets/losers') {
        final rows = await SupabaseService.client
            .from('stocks')
            .select()
            .order('change_percent', ascending: route == '/markets/losers')
            .limit(5);
        return rows.map(_mapStock).toList();
      }
      if (route == '/news') {
        return await SupabaseService.client
            .from('news_articles')
            .select()
            .order('published_at', ascending: false)
            .limit(20);
      }
      if (route == '/portfolio/summary') return _portfolioSummary();
      if (route == '/portfolio/holdings') return _holdings();
      if (route == '/watchlist') return <dynamic>[];
    } catch (_) {
      return null;
    }
    return null;
  }

  static Future<dynamic> post(String path, Map<String, dynamic> body) async {
    if (path != '/ai/chat') return <String, dynamic>{};
    final response = await http.post(
      Uri.parse(_aiUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'action': 'chat', 'message': body['message'] ?? ''}),
    );
    final json = jsonDecode(response.body) as Map<String, dynamic>;
    return json['data'] is Map<String, dynamic>
        ? json['data']
        : <String, dynamic>{};
  }

  static Future<Map<String, dynamic>?> _portfolioSummary() async {
    final userId = SupabaseService.currentUser?.id;
    if (userId == null) return null;
    final row = await SupabaseService.client
        .from('portfolios')
        .select()
        .eq('user_id', userId)
        .maybeSingle();
    return row == null ? null : Map<String, dynamic>.from(row);
  }

  static Future<List<Map<String, dynamic>>> _holdings() async {
    final userId = SupabaseService.currentUser?.id;
    if (userId == null) return [];
    final portfolio = await SupabaseService.client
        .from('portfolios')
        .select('id')
        .eq('user_id', userId)
        .maybeSingle();
    if (portfolio == null) return [];
    final holdings = await SupabaseService.client
        .from('holdings')
        .select('symbol, quantity, avg_price')
        .eq('portfolio_id', portfolio['id']);
    final stocks = await SupabaseService.client
        .from('stocks')
        .select('symbol, name, price');
    final bySymbol = {for (final stock in stocks) stock['symbol']: stock};
    return holdings.map((holding) {
      final stock = bySymbol[holding['symbol']] ??
          {'name': holding['symbol'], 'price': 0};
      final quantity = (holding['quantity'] as num).toDouble();
      final average = (holding['avg_price'] as num).toDouble();
      final price = (stock['price'] as num).toDouble();
      final value = quantity * price;
      final invested = quantity * average;
      final returns = value - invested;
      return {
        'symbol': holding['symbol'],
        'name': stock['name'],
        'quantity': quantity,
        'avg_price': average,
        'current_price': price,
        'total_value': value,
        'total_returns': returns,
        'returns_percent': invested == 0 ? 0 : returns / invested * 100,
      };
    }).toList();
  }

  static Map<String, dynamic> _mapIndex(Map<String, dynamic> row) => {
        'symbol': row['symbol'],
        'name': row['name'],
        'last_value': (row['price'] as num).toDouble(),
        'change': (row['change'] as num).toDouble(),
        'change_percent': (row['change_percent'] as num).toDouble(),
      };

  static Map<String, dynamic> _mapStock(Map<String, dynamic> row) {
    final price = (row['price'] as num).toDouble();
    return {
      'symbol': row['symbol'],
      'name': row['name'],
      'sector': row['sector'],
      'last_price': price,
      'change': (row['change'] as num).toDouble(),
      'change_percent': (row['change_percent'] as num).toDouble(),
      'volume': row['volume'] ?? 0,
      'pe_ratio': (row['pe_ratio'] as num?)?.toDouble() ?? 20.0,
      'open': price * 0.99,
      'high': (row['high_52w'] as num?)?.toDouble() ?? price * 1.05,
      'low': (row['low_52w'] as num?)?.toDouble() ?? price * 0.95,
      'description': row['description'] ?? '',
    };
  }
}
