class PortfolioHoldingModel {
  final String symbol;
  final String name;
  final int shares;
  final double avgPrice;
  final double currentPrice;
  final double pnl;
  final double pnlPercent;

  const PortfolioHoldingModel({
    required this.symbol,
    required this.name,
    required this.shares,
    required this.avgPrice,
    required this.currentPrice,
    required this.pnl,
    required this.pnlPercent,
  });

  factory PortfolioHoldingModel.fromJson(Map<String, dynamic> json) {
    final shares = (json['shares'] as num?)?.toInt() ?? 0;
    final avg = (json['avgPrice'] ?? json['avg_price'] as num?)?.toDouble() ?? 0.0;
    final curr = (json['currentPrice'] ?? json['price'] as num?)?.toDouble() ?? 0.0;
    final pnlVal = (json['pnl'] as num?)?.toDouble() ?? ((curr - avg) * shares);
    final pnlPct = (json['pnlPercent'] as num?)?.toDouble() ?? (avg > 0 ? (curr - avg) / avg * 100 : 0.0);

    return PortfolioHoldingModel(
      symbol: json['symbol']?.toString() ?? '',
      name: json['name']?.toString() ?? json['symbol']?.toString() ?? 'Holding',
      shares: shares,
      avgPrice: avg,
      currentPrice: curr,
      pnl: pnlVal,
      pnlPercent: pnlPct,
    );
  }

  Map<String, dynamic> toJson() => {
        'symbol': symbol,
        'name': name,
        'shares': shares,
        'avgPrice': avgPrice,
        'currentPrice': currentPrice,
        'pnl': pnl,
        'pnlPercent': pnlPercent,
      };
}
