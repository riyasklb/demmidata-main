import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/env.dart';
import '../currency_converter/models/rate_cache.dart';

class BestRateResult {
  final double rate;
  final DateTime fetchedAt;
  final bool fromCache;

  const BestRateResult({
    required this.rate,
    required this.fetchedAt,
    required this.fromCache,
  });

  bool get isOlderThan5Min =>
      DateTime.now().difference(fetchedAt) > Env.freshDuration;
}

class CurrencyApiService {
  static const String _prefsKey = 'rate_cache_v1';

  Future<BestRateResult> getBestRate(String from, String to) async {
    final cache = await _getCacheMap();
    final cacheKey = _pairKey(from, to);
    final RateCacheEntry? cached = cache[cacheKey];

    if (cached != null &&
        DateTime.now().difference(cached.fetchedAt) <= Env.freshDuration) {
      return BestRateResult(
        rate: cached.rate,
        fetchedAt: cached.fetchedAt,
        fromCache: true,
      );
    }

    try {
      final fetched = await _fetchRateFromApi(from, to);
      await _saveToCache(fetched);
      return BestRateResult(
        rate: fetched.rate,
        fetchedAt: fetched.fetchedAt,
        fromCache: false,
      );
    } catch (_) {
      if (cached != null &&
          DateTime.now().difference(cached.fetchedAt) <= Env.fallbackDuration) {
        return BestRateResult(
          rate: cached.rate,
          fetchedAt: cached.fetchedAt,
          fromCache: true,
        );
      }
      rethrow;
    }
  }

  Future<RateCacheEntry> _fetchRateFromApi(String from, String to) async {


final uri = Uri.parse(
  '${Env.currencyApiBaseUrl}?access_key=${Env.currencyApiKey}&from=$from&to=$to&amount=1&format=1',
);


    final response = await http.get(
      uri,
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to fetch rate');
    }

    final jsonBody = json.decode(response.body) as Map<String, dynamic>;
    if (jsonBody['success'] != true) {
      throw Exception('API error');
    }

    final info = jsonBody['info'] as Map<String, dynamic>;
    final timestampSec = info['timestamp'] as int;
    final quote = (info['quote'] as num).toDouble();

    return RateCacheEntry(
      from: from,
      to: to,
      rate: quote,
      fetchedAt: DateTime.fromMillisecondsSinceEpoch(timestampSec * 1000),
    );
  }

  String _pairKey(String from, String to) =>
      '${from.toUpperCase()}_${to.toUpperCase()}';

  Future<Map<String, RateCacheEntry>> _getCacheMap() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefsKey);
    if (raw == null) return {};
    final Map<String, dynamic> decoded = json.decode(raw) as Map<String, dynamic>;
    return decoded.map(
      (key, value) => MapEntry(
        key,
        RateCacheEntry.fromJson(value as Map<String, dynamic>),
      ),
    );
  }

  Future<void> _saveToCache(RateCacheEntry entry) async {
    final prefs = await SharedPreferences.getInstance();
    final cache = await _getCacheMap();
    cache[_pairKey(entry.from, entry.to)] = entry;
    final encoded = json.encode(
      cache.map((k, v) => MapEntry(k, v.toJson())),
    );
    await prefs.setString(_prefsKey, encoded);
  }
}
