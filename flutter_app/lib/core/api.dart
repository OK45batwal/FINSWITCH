import 'dart:convert';
import 'dart:io' show Platform;
import 'package:http/http.dart' as http;

class Api {
  static String _host = '';

  static String get host {
    if (_host.isEmpty) {
      _host = Platform.isAndroid ? 'http://10.0.2.2:8000/api/v1' : 'http://localhost:8000/api/v1';
    }
    return _host;
  }

  static set host(String h) => _host = h;

  static Future<dynamic> get(String path) async {
    final res = await http.get(Uri.parse('$host$path'));
    final body = jsonDecode(res.body);
    if (body is Map && body['data'] != null) return body['data'];
    return body;
  }

  static Future<dynamic> post(String path, Map<String, dynamic> body) async {
    final res = await http.post(Uri.parse('$host$path'), headers: {'Content-Type': 'application/json'}, body: jsonEncode(body));
    final decoded = jsonDecode(res.body);
    if (decoded is Map && decoded['data'] != null) return decoded['data'];
    return decoded;
  }
}
