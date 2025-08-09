import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../currency_converter/models/rate_cache.dart';

class BestRateResult {
  final double rate;
  final DateTime fetchedAt;
  final bool fromCache;

  const BestRateResult({required this.rate, required this.fetchedAt, required this.fromCache});

  bool get isOlderThan5Min => DateTime.now().difference(fetchedAt) > const Duration(minutes: 5);
}

class CurrencyApiService {
  static const String _baseUrl = 'http://api.currencylayer.com/convert';
  // Provided access key in the requirement. Replace with env/secret for production
  static const String _accessKey = 'eeab945f4428e23372f1e6b6baf7baa0';

  static const Duration _freshDuration = Duration(minutes: 5);
  static const Duration _fallbackDuration = Duration(minutes: 30);
  static const String _prefsKey = 'rate_cache_v1';

  Future<BestRateResult> getBestRate(String from, String to) async {
    final cache = await _getCacheMap();
    final cacheKey = _pairKey(from, to);
    final RateCacheEntry? cached = cache[cacheKey];

    // Use cache if fresh (<= 5 minutes)
    if (cached != null && DateTime.now().difference(cached.fetchedAt) <= _freshDuration) {
      return BestRateResult(rate: cached.rate, fetchedAt: cached.fetchedAt, fromCache: true);
    }

    // Try network
    try {
      final fetched = await _fetchRateFromApi(from, to);
      await _saveToCache(fetched);
      return BestRateResult(rate: fetched.rate, fetchedAt: fetched.fetchedAt, fromCache: false);
    } catch (_) {
      // Fallback to cache if <= 30 minutes old
      if (cached != null && DateTime.now().difference(cached.fetchedAt) <= _fallbackDuration) {
        return BestRateResult(rate: cached.rate, fetchedAt: cached.fetchedAt, fromCache: true);
      }
      rethrow;
    }
  }

  Future<RateCacheEntry> _fetchRateFromApi(String from, String to) async {
    final uri = Uri.parse('$_baseUrl?access_key=$_accessKey&from=$from&to=$to&amount=1&format=1');
    final response = await http.get(uri, headers: {'Content-Type': 'application/x-www-form-urlencoded'});
    if (response.statusCode != 200) {
      throw Exception('Failed to fetch rate');
    }
    final jsonBody = json.decode(response.body) as Map<String, dynamic>;
    final success = jsonBody['success'] == true;
    if (!success) {
      throw Exception('API error');
    }
    final info = jsonBody['info'] as Map<String, dynamic>;
    final timestampSec = info['timestamp'] as int; // seconds since epoch
    final quote = (info['quote'] as num).toDouble();
    return RateCacheEntry(
      from: from,
      to: to,
      rate: quote,
      fetchedAt: DateTime.fromMillisecondsSinceEpoch(timestampSec * 1000),
    );
  }

  String _pairKey(String from, String to) => '${from.toUpperCase()}_${to.toUpperCase()}';

  Future<Map<String, RateCacheEntry>> _getCacheMap() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefsKey);
    if (raw == null) return {};
    final Map<String, dynamic> decoded = json.decode(raw) as Map<String, dynamic>;
    return decoded.map((key, value) => MapEntry(key, RateCacheEntry.fromJson(value as Map<String, dynamic>)));
  }

  Future<void> _saveToCache(RateCacheEntry entry) async {
    final prefs = await SharedPreferences.getInstance();
    final cache = await _getCacheMap();
    cache[_pairKey(entry.from, entry.to)] = entry;
    final encoded = json.encode(cache.map((k, v) => MapEntry(k, v.toJson())));
    await prefs.setString(_prefsKey, encoded);
  }
}


