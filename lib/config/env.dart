
class Env {
  static const String currencyApiBaseUrl = 'http://api.currencylayer.com/convert';
  static const String currencyApiKey = 'eeab945f4428e23372f1e6b6baf7baa0'; 

  static const Duration freshDuration = Duration(minutes: 5);
  static const Duration fallbackDuration = Duration(minutes: 30);
}
