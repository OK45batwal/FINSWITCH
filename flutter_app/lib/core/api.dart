import 'dart:convert';

import 'package:http/http.dart' as http;

import 'supabase_service.dart';

class Api {
  static const _aiUrl = 'https://finswitch.pages.dev/api/ai';

  static Future<dynamic> get(String path) async {
    final route = Uri.parse(path).path;
    try {
      if (route == '/markets/indices') {
        final response = await http.get(Uri.parse('$_aiUrl?type=indices'));
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        if (json['success'] != true) return null;
        return (json['data'] as List).map((d) => {
          'symbol': d['symbol'],
          'name': d['name'],
          'last_value': (d['price'] as num).toDouble(),
          'change': (d['change'] as num).toDouble(),
          'change_percent': (d['change_percent'] as num).toDouble(),
        }).toList();
      }
      if (route == '/markets/stocks') {
        final response = await http.get(Uri.parse('$_aiUrl?type=stocks'));
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        if (json['success'] != true) return null;
        return json['data'];
      }
      if (route.startsWith('/markets/stocks/')) {
        final symbol = route.split('/').last.toUpperCase();
        final response =
            await http.get(Uri.parse('$_aiUrl?type=stock&symbol=$symbol'));
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        if (json['success'] != true) return null;
        return json['data'];
      }
      if (route == '/markets/gainers') {
        final response = await http.get(Uri.parse('$_aiUrl?type=stocks'));
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        if (json['success'] != true) return null;
        final data = (json['data'] as List).cast<Map<String, dynamic>>();
        data.sort((a, b) =>
            (b['change_percent'] as num).compareTo(a['change_percent'] as num));
        return data.take(5).toList();
      }
      if (route == '/markets/losers') {
        final response = await http.get(Uri.parse('$_aiUrl?type=stocks'));
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        if (json['success'] != true) return null;
        final data = (json['data'] as List).cast<Map<String, dynamic>>();
        data.sort((a, b) =>
            (a['change_percent'] as num).compareTo(b['change_percent'] as num));
        return data.take(5).toList();
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
}
