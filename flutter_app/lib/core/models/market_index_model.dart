class MarketIndexModel {
  final String name;
  final String symbol;
  final String value;
  final String change;
  final String changePercent;
  final bool isPositive;

  const MarketIndexModel({
    required this.name,
    required this.symbol,
    required this.value,
    required this.change,
    required this.changePercent,
    required this.isPositive,
  });

  factory MarketIndexModel.fromJson(Map<String, dynamic> json) {
    return MarketIndexModel(
      name: json['name']?.toString() ?? 'Index',
      symbol: json['symbol']?.toString() ?? '',
      value: json['value']?.toString() ?? '0.00',
      change: json['change']?.toString() ?? '0.00',
      changePercent: json['changePercent']?.toString() ?? '0.00%',
      isPositive: json['isPositive'] == true || (json['change']?.toString().startsWith('+') ?? false),
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'symbol': symbol,
        'value': value,
        'change': change,
        'changePercent': changePercent,
        'isPositive': isPositive,
      };
}
