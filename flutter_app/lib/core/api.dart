import 'dart:convert';
import 'dart:io' show Platform;
import 'package:http/http.dart' as http;
import 'supabase_service.dart';

class Api {
  static String _host = '';
  static bool _useLocal = false;

  static String get host {
    if (_host.isEmpty) {
      _host = Platform.isAndroid
          ? 'http://10.0.2.2:8000/api/v1'
          : 'http://localhost:8000/api/v1';
    }
    return _host;
  }

  static set host(String h) => _host = h;
  static set useLocal(bool v) => _useLocal = v;

  static Future<dynamic> get(String path) async {
    // 1. Attempt fetching from Supabase Database first
    final supabaseData = await _supabaseData(path);
    if (supabaseData != null) return supabaseData;

    // 2. If Supabase is empty/offline, attempt HTTP API backend
    if (!_useLocal) {
      try {
        final res = await http
            .get(Uri.parse('$host$path'))
            .timeout(const Duration(seconds: 3));
        final body = jsonDecode(res.body);
        if (body is Map && body['data'] != null) return body['data'];
        return body;
      } catch (_) {
        _useLocal = true;
      }
    }

    // 3. Fallback to local static mock data
    return _localData(path);
  }

  static Future<dynamic> post(String path, Map<String, dynamic> body) async {
    if (!_useLocal) {
      try {
        final res = await http
            .post(Uri.parse('$host$path'),
                headers: {'Content-Type': 'application/json'},
                body: jsonEncode(body))
            .timeout(const Duration(seconds: 3));
        final decoded = jsonDecode(res.body);
        if (decoded is Map && decoded['data'] != null) return decoded['data'];
        return decoded;
      } catch (_) {
        _useLocal = true;
      }
    }
    return _localPost(path, body);
  }

  // ---- Live Supabase Database Query Layer ----
  static Future<dynamic> _supabaseData(String path) async {
    try {
      if (!SupabaseService.isAuthenticated &&
          (path.startsWith('/portfolio') || path.startsWith('/watchlist'))) {
        return null;
      }

      if (path == '/markets/indices') {
        final res = await SupabaseService.client.from('indices').select();
        if (res.isNotEmpty) {
          return res.map((r) => {
            'symbol': r['symbol'],
            'name': r['name'],
            'last_value': (r['price'] as num).toDouble(),
            'change': (r['change'] as num).toDouble(),
            'change_percent': (r['change_percent'] as num).toDouble(),
          }).toList();
        }
      }

      if (path == '/markets/stocks') {
        final res = await SupabaseService.client.from('stocks').select();
        if (res.isNotEmpty) {
          return res.map((r) => _mapStock(r)).toList();
        }
      }

      if (path.startsWith('/markets/stocks/')) {
        final sym = path.split('/').last.toUpperCase();
        final res = await SupabaseService.client.from('stocks').select().eq('symbol', sym).maybeSingle();
        if (res != null) return _mapStock(res);
      }

      if (path == '/markets/gainers') {
        final res = await SupabaseService.client.from('stocks').select().order('change_percent', ascending: false).limit(5);
        if (res.isNotEmpty) return res.map((r) => _mapStock(r)).toList();
      }

      if (path == '/markets/losers') {
        final res = await SupabaseService.client.from('stocks').select().order('change_percent', ascending: true).limit(5);
        if (res.isNotEmpty) return res.map((r) => _mapStock(r)).toList();
      }

      if (path == '/news') {
        final res = await SupabaseService.client.from('news_articles').select().order('published_at', ascending: false).limit(20);
        if (res.isNotEmpty) {
          return res.map((r) => {
            'id': r['id'].toString(),
            'title': r['title'],
            'summary': r['summary'] ?? '',
            'category': 'Markets',
            'sentiment': 'positive',
            'source': r['source'] ?? 'FinSwitch',
            'published_at': r['published_at'] ?? 'Just now',
          }).toList();
        }
      }

      if (path == '/portfolio/summary') {
        final userId = SupabaseService.currentUser?.id;
        if (userId != null) {
          final res = await SupabaseService.client.from('portfolios').select().eq('user_id', userId).maybeSingle();
          if (res != null) {
            final cur = (res['current_value'] as num).toDouble();
            final inv = (res['total_invested'] as num).toDouble();
            final ret = (res['total_returns'] as num).toDouble();
            final retPct = (res['returns_percent'] as num).toDouble();
            return {
              'total_invested': inv,
              'current_value': cur,
              'total_returns': ret,
              'returns_percent': retPct,
              'today_pl': ret * 0.01,
              'today_pl_percent': 0.21,
            };
          }
        }
      }
    } catch (_) {
      // Fallback silently if query fails
    }
    return null;
  }

  static Map<String, dynamic> _mapStock(Map<String, dynamic> r) {
    return {
      'symbol': r['symbol'],
      'name': r['name'],
      'sector': r['sector'],
      'last_price': (r['price'] as num).toDouble(),
      'change': (r['change'] as num).toDouble(),
      'change_percent': (r['change_percent'] as num).toDouble(),
      'volume': r['volume'] ?? 0,
      'pe_ratio': (r['pe_ratio'] as num?)?.toDouble() ?? 20.0,
      'open': (r['price'] as num).toDouble() * 0.99,
      'high': (r['high_52w'] as num?)?.toDouble() ?? (r['price'] as num).toDouble() * 1.05,
      'low': (r['low_52w'] as num?)?.toDouble() ?? (r['price'] as num).toDouble() * 0.95,
      'description': r['description'] ?? '',
    };
  }

  // ---- Local Static Mock Data Fallback ----
  static dynamic _localData(String path) {
    if (path.startsWith('/portfolio/summary')) return _portfolioSummary;
    if (path.startsWith('/portfolio/holdings')) return _holdings;
    if (path.startsWith('/markets/indices')) return _indices;
    if (path.startsWith('/markets/stocks/')) {
      final sym = path.split('/').last.toUpperCase();
      return _stocks.whereType<Map<String, dynamic>>().firstWhere(
          (s) => s['symbol'] == sym,
          orElse: () => <String, dynamic>{});
    }
    if (path.startsWith('/markets/stocks')) return _stocks;
    if (path.startsWith('/markets/gainers')) return _gainers;
    if (path.startsWith('/markets/losers')) return _losers;
    if (path.startsWith('/news')) return _news;
    return <dynamic>[];
  }

  static Future<dynamic> _localPost(
      String path, Map<String, dynamic> body) async {
    if (path.startsWith('/ai/chat')) {
      final msg = (body['message'] as String?)?.toLowerCase() ?? '';
      String response;
      if (msg.contains('reliance') || msg.contains('ril'))
        response = 'Reliance Industries (RELIANCE) — ₹2,845.30 (+1.16%). Oil & Gas leader with Jio and Retail driving growth. Strong buy on dips support ₹2,700.';
      else if (msg.contains('hdfc') || msg.contains('bank'))
        response = 'HDFC Bank (HDFCBANK) — ₹1,635.75 (+0.55%). Solid quarterly margins at 4.1%. One of the strongest banking picks in India.';
      else if (msg.contains('tcs'))
        response = 'TCS (TCS) — ₹3,920.00 (-0.47%). IT bellwether with steady deal wins. Recent 2.5B USD deal adds pipeline visibility.';
      else if (msg.contains('nifty'))
        response = 'Nifty 50 at 23,456.80 (+0.55%). Up led by banking and energy stocks. Key support at 23,200, resistance 23,600.';
      else if (msg.contains('sensex'))
        response = 'Sensex at 77,123.45 (+0.44%). Positive momentum with FII buying in large-caps.';
      else if (msg.contains('portfolio') || msg.contains('holding'))
        response = 'Your portfolio of 7 stocks is valued at ₹15,82,340 (+27.1%). Top performer: SBI (+20.35%). Consider rebalancing if IT sector exposure exceeds 10%.';
      else if (msg.contains('gain') || msg.contains('top'))
        response = 'Top gainers: RELIANCE (+1.16%), BHARTIARTL (+1.19%), ICICIBANK (+0.60%). Broad-based buying in energy and banking.';
      else if (msg.contains('los') || msg.contains('bottom'))
        response = 'Top losers: INFY (-0.82%), ITC (-0.53%), TCS (-0.47%). IT under pressure from global rate uncertainty.';
      else
        response = 'I can help with: stock analysis (try "RELIANCE" or "TCS"), market indices ("Nifty", "Sensex"), portfolio insights, gainers/losers. What would you like to know?';
      return {'response': response};
    }
    return <dynamic>{};
  }

  static final _portfolioSummary = {
    'total_invested': 1245000.0,
    'current_value': 1582340.0,
    'total_returns': 337340.0,
    'returns_percent': 27.1,
    'today_pl': 3240.0,
    'today_pl_percent': 0.21,
  };

  static final _holdings = [
    {
      'symbol': 'RELIANCE',
      'name': 'Reliance Industries',
      'quantity': 50,
      'avg_price': 2450.0,
      'ltp': 2845.3,
      'invested': 122500.0,
      'value': 142265.0,
      'pl': 19765.0,
      'pl_percent': 16.13,
      'allocation': 8.99
    },
    {
      'symbol': 'HDFCBANK',
      'name': 'HDFC Bank',
      'quantity': 100,
      'avg_price': 1420.0,
      'ltp': 1635.75,
      'invested': 142000.0,
      'value': 163575.0,
      'pl': 21575.0,
      'pl_percent': 15.19,
      'allocation': 10.34
    },
    {
      'symbol': 'TCS',
      'name': 'Tata Consultancy Services',
      'quantity': 20,
      'avg_price': 3850.0,
      'ltp': 3920.0,
      'invested': 77000.0,
      'value': 78400.0,
      'pl': 1400.0,
      'pl_percent': 1.82,
      'allocation': 4.95
    },
    {
      'symbol': 'ICICIBANK',
      'name': 'ICICI Bank',
      'quantity': 150,
      'avg_price': 980.0,
      'ltp': 1124.9,
      'invested': 147000.0,
      'value': 168735.0,
      'pl': 21735.0,
      'pl_percent': 14.79,
      'allocation': 10.66
    },
    {
      'symbol': 'INFY',
      'name': 'Infosys',
      'quantity': 60,
      'avg_price': 1450.0,
      'ltp': 1482.55,
      'invested': 87000.0,
      'value': 88953.0,
      'pl': 1953.0,
      'pl_percent': 2.24,
      'allocation': 5.62
    },
    {
      'symbol': 'SBIN',
      'name': 'SBI',
      'quantity': 200,
      'avg_price': 650.0,
      'ltp': 782.3,
      'invested': 130000.0,
      'value': 156460.0,
      'pl': 26460.0,
      'pl_percent': 20.35,
      'allocation': 9.89
    },
    {
      'symbol': 'ITC',
      'name': 'ITC Ltd',
      'quantity': 300,
      'avg_price': 380.0,
      'ltp': 432.15,
      'invested': 114000.0,
      'value': 129645.0,
      'pl': 15645.0,
      'pl_percent': 13.72,
      'allocation': 8.19
    },
  ];

  static final _indices = [
    {
      'symbol': 'NIFTY',
      'name': 'Nifty 50',
      'last_value': 23456.80,
      'change': 128.45,
      'change_percent': 0.55
    },
    {
      'symbol': 'SENSEX',
      'name': 'S&P BSE Sensex',
      'last_value': 77123.45,
      'change': 342.10,
      'change_percent': 0.44
    },
    {
      'symbol': 'BANKNIFTY',
      'name': 'Bank Nifty',
      'last_value': 49234.55,
      'change': -87.30,
      'change_percent': -0.18
    },
  ];

  static final _stocks = [
    {
      'symbol': 'RELIANCE',
      'name': 'Reliance Industries Ltd',
      'sector': 'Oil & Gas',
      'last_price': 2845.30,
      'change': 32.50,
      'change_percent': 1.16,
      'volume': 12400000,
      'pe_ratio': 24.5,
      'open': 2812.8,
      'high': 2902.21,
      'low': 2788.39,
      'description':
          'Reliance Industries Limited is an Indian multinational conglomerate with businesses in energy, petrochemicals, retail, and telecommunications.'
    },
    {
      'symbol': 'TCS',
      'name': 'Tata Consultancy Services',
      'sector': 'IT',
      'last_price': 3920.00,
      'change': -18.40,
      'change_percent': -0.47,
      'volume': 3800000,
      'pe_ratio': 28.6,
      'open': 3938.0,
      'high': 3950.0,
      'low': 3905.0,
      'description':
          'Tata Consultancy Services is an Indian multinational information technology services and consulting company.'
    },
    {
      'symbol': 'HDFCBANK',
      'name': 'HDFC Bank Ltd',
      'sector': 'Banking',
      'last_price': 1635.75,
      'change': 8.90,
      'change_percent': 0.55,
      'volume': 18200000,
      'pe_ratio': 18.5,
      'open': 1627.0,
      'high': 1645.0,
      'low': 1625.0,
      'description':
          'HDFC Bank is an Indian banking and financial services company.'
    },
    {
      'symbol': 'INFY',
      'name': 'Infosys Ltd',
      'sector': 'IT',
      'last_price': 1482.55,
      'change': -12.20,
      'change_percent': -0.82,
      'volume': 8600000,
      'pe_ratio': 26.2,
      'open': 1495.0,
      'high': 1500.0,
      'low': 1478.0,
      'description':
          'Infosys is an Indian multinational information technology company.'
    },
    {
      'symbol': 'ICICIBANK',
      'name': 'ICICI Bank Ltd',
      'sector': 'Banking',
      'last_price': 1124.90,
      'change': 6.75,
      'change_percent': 0.60,
      'volume': 14100000,
      'pe_ratio': 16.8,
      'open': 1118.0,
      'high': 1132.0,
      'low': 1115.0,
      'description':
          'ICICI Bank is an Indian multinational banking and financial services company.'
    },
    {
      'symbol': 'SBIN',
      'name': 'State Bank of India',
      'sector': 'Banking',
      'last_price': 782.30,
      'change': 4.50,
      'change_percent': 0.58,
      'volume': 22500000,
      'pe_ratio': 12.3,
      'open': 778.0,
      'high': 788.0,
      'low': 775.0,
      'description':
          'State Bank of India is an Indian multinational public sector bank.'
    },
    {
      'symbol': 'BHARTIARTL',
      'name': 'Bharti Airtel Ltd',
      'sector': 'Telecom',
      'last_price': 1345.60,
      'change': 15.80,
      'change_percent': 1.19,
      'volume': 7300000,
      'pe_ratio': 32.1,
      'open': 1330.0,
      'high': 1352.0,
      'low': 1328.0,
      'description':
          'Bharti Airtel is an Indian multinational telecommunications services company.'
    },
    {
      'symbol': 'ITC',
      'name': 'ITC Ltd',
      'sector': 'FMCG',
      'last_price': 432.15,
      'change': -2.30,
      'change_percent': -0.53,
      'volume': 25100000,
      'pe_ratio': 22.4,
      'open': 434.0,
      'high': 437.0,
      'low': 430.0,
      'description': 'ITC Limited is an Indian multinational conglomerate.'
    },
  ];

  static List<Map<String, dynamic>> get _gainers {
    final sorted = List<Map<String, dynamic>>.from(_stocks);
    sorted.sort((a, b) =>
        (b['change_percent'] as num).compareTo(a['change_percent'] as num));
    return sorted.take(5).toList();
  }

  static List<Map<String, dynamic>> get _losers {
    final sorted = List<Map<String, dynamic>>.from(_stocks);
    sorted.sort((a, b) =>
        (a['change_percent'] as num).compareTo(b['change_percent'] as num));
    return sorted.take(5).toList();
  }

  static final _news = [
    {
      'id': '1',
      'title': 'RBI keeps repo rate unchanged at 6.50%',
      'summary':
          'The MPC voted 5-1 to maintain status quo, maintaining its withdrawal of accommodation stance.',
      'category': 'Economy',
      'sentiment': 'neutral',
      'source': 'Economic Times',
      'published_at': '2h ago'
    },
    {
      'id': '2',
      'title': 'Reliance Industries Q1 net profit rises 12%',
      'summary':
          'Revenue from operations increased 8% YoY driven by strong performance in retail and telecom segments.',
      'category': 'Markets',
      'sentiment': 'positive',
      'source': 'Moneycontrol',
      'published_at': '4h ago'
    },
    {
      'id': '3',
      'title': 'HDFC Bank reports 15% growth in net profit',
      'summary':
          'Net interest margin improved to 4.1% with strong growth in advances and deposits.',
      'category': 'Markets',
      'sentiment': 'positive',
      'source': 'Bloomberg',
      'published_at': '6h ago'
    },
    {
      'id': '4',
      'title': 'SEBI introduces new framework for SME IPOs',
      'summary':
          'The regulator mandates higher disclosure norms and track record requirements for SME listings.',
      'category': 'IPO',
      'sentiment': 'positive',
      'source': 'Business Standard',
      'published_at': '8h ago'
    },
    {
      'id': '5',
      'title': 'Rupee weakens to 83.75 against US dollar',
      'summary':
          'Foreign institutional investors have pulled out ₹15,000 crore from Indian equities this month.',
      'category': 'Economy',
      'sentiment': 'negative',
      'source': 'Reuters',
      'published_at': '10h ago'
    },
    {
      'id': '6',
      'title': 'TCS wins 2.5 billion dollar deal from UK bank',
      'summary':
          "The 5-year deal involves digital transformation of the bank's legacy systems.",
      'category': 'Markets',
      'sentiment': 'positive',
      'source': 'Financial Express',
      'published_at': '12h ago'
    },
    {
      'id': '7',
      'title': 'Gold prices hit all-time high of ₹76,500',
      'summary':
          'Geopolitical tensions and US interest rate cut expectations drive safe-haven demand.',
      'category': 'Markets',
      'sentiment': 'neutral',
      'source': 'CNBC TV18',
      'published_at': '14h ago'
    },
    {
      'id': '8',
      'title': 'Zomato turns profitable for second consecutive quarter',
      'summary':
          'Food delivery giant reports net profit of ₹450 crore driven by quick commerce growth.',
      'category': 'Markets',
      'sentiment': 'positive',
      'source': 'Livemint',
      'published_at': '16h ago'
    },
  ];
}
