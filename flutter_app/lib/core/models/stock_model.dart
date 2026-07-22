class StockModel {
  final String name;
  final String symbol;
  final String price;
  final String change;
  final String changePercent;
  final bool isPositive;
  final String marketCap;
  final String pe;
  final String volume;
  final String sector;

  const StockModel({
    required this.name,
    required this.symbol,
    required this.price,
    required this.change,
    required this.changePercent,
    required this.isPositive,
    this.marketCap = 'N/A',
    this.pe = 'N/A',
    this.volume = 'N/A',
    this.sector = 'General',
  });

  factory StockModel.fromJson(Map<String, dynamic> json) {
    return StockModel(
      name: json['name']?.toString() ?? json['symbol']?.toString() ?? 'Unknown Stock',
      symbol: json['symbol']?.toString() ?? '',
      price: json['price']?.toString() ?? json['ltp']?.toString() ?? '0.00',
      change: json['change']?.toString() ?? '0.00',
      changePercent: json['changePercent']?.toString() ?? json['change_pct']?.toString() ?? '0.00%',
      isPositive: json['isPositive'] == true || (json['change']?.toString().startsWith('+') ?? false),
      marketCap: json['marketCap']?.toString() ?? json['market_cap']?.toString() ?? 'N/A',
      pe: json['pe']?.toString() ?? json['pe_ratio']?.toString() ?? 'N/A',
      volume: json['volume']?.toString() ?? 'N/A',
      sector: json['sector']?.toString() ?? 'General',
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'symbol': symbol,
        'price': price,
        'change': change,
        'changePercent': changePercent,
        'isPositive': isPositive,
        'marketCap': marketCap,
        'pe': pe,
        'volume': volume,
        'sector': sector,
      };
}
