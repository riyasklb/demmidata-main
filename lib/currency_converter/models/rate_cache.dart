class RateCacheEntry {
  final String from;
  final String to;
  final double rate;
  final DateTime fetchedAt;

  const RateCacheEntry({required this.from, required this.to, required this.rate, required this.fetchedAt});

  Map<String, dynamic> toJson() => {
        'from': from,
        'to': to,
        'rate': rate,
        'fetchedAt': fetchedAt.millisecondsSinceEpoch,
      };

  factory RateCacheEntry.fromJson(Map<String, dynamic> json) => RateCacheEntry(
        from: json['from'] as String,
        to: json['to'] as String,
        rate: (json['rate'] as num).toDouble(),
        fetchedAt: DateTime.fromMillisecondsSinceEpoch(json['fetchedAt'] as int),
      );
}


