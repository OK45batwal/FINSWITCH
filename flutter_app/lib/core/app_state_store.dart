import 'package:flutter/foundation.dart';
import 'models/stock_model.dart';
import 'models/portfolio_holding_model.dart';

class WatchlistStateStore extends ValueNotifier<List<StockModel>> {
  WatchlistStateStore() : super([]);

  void setWatchlist(List<StockModel> list) {
    value = List.unmodifiable(list);
  }

  void addStock(StockModel stock) {
    if (!value.any((s) => s.symbol == stock.symbol)) {
      value = List.unmodifiable([...value, stock]);
    }
  }

  void removeStock(String symbol) {
    value = List.unmodifiable(value.where((s) => s.symbol != symbol).toList());
  }

  bool isWatched(String symbol) {
    return value.any((s) => s.symbol == symbol);
  }
}

class PortfolioStateStore extends ValueNotifier<List<PortfolioHoldingModel>> {
  PortfolioStateStore() : super([]);

  void setHoldings(List<PortfolioHoldingModel> list) {
    value = List.unmodifiable(list);
  }

  void addHolding(PortfolioHoldingModel holding) {
    final existingIndex = value.indexWhere((h) => h.symbol == holding.symbol);
    if (existingIndex >= 0) {
      final existing = value[existingIndex];
      final newShares = existing.shares + holding.shares;
      final newAvg = ((existing.avgPrice * existing.shares) + (holding.avgPrice * holding.shares)) / newShares;
      final updated = PortfolioHoldingModel(
        symbol: existing.symbol,
        name: existing.name,
        shares: newShares,
        avgPrice: newAvg,
        currentPrice: holding.currentPrice,
        pnl: (holding.currentPrice - newAvg) * newShares,
        pnlPercent: newAvg > 0 ? (holding.currentPrice - newAvg) / newAvg * 100 : 0.0,
      );
      final newList = List<PortfolioHoldingModel>.from(value);
      newList[existingIndex] = updated;
      value = List.unmodifiable(newList);
    } else {
      value = List.unmodifiable([...value, holding]);
    }
  }

  double get totalValue => value.fold(0.0, (sum, h) => sum + (h.currentPrice * h.shares));
  double get totalInvested => value.fold(0.0, (sum, h) => sum + (h.avgPrice * h.shares));
  double get totalPnl => totalValue - totalInvested;
  double get totalPnlPercent => totalInvested > 0 ? (totalPnl / totalInvested) * 100 : 0.0;
}

class AppStateStore {
  static final watchlist = WatchlistStateStore();
  static final portfolio = PortfolioStateStore();
}
