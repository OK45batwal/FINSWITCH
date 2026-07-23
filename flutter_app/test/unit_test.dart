import 'package:flutter_test/flutter_test.dart';

bool isVersionHigher(String latest, String current) {
  try {
    final lParts = latest.split('.').map(int.parse).toList();
    final cParts = current.split('.').map(int.parse).toList();
    for (var i = 0; i < lParts.length && i < cParts.length; i++) {
      if (lParts[i] > cParts[i]) return true;
      if (lParts[i] < cParts[i]) return false;
    }
    return lParts.length > cParts.length;
  } catch (_) {
    return latest != current;
  }
}

Map<String, dynamic> calculateHoldingReturns({
  required String symbol,
  required String name,
  required double quantity,
  required double avgPrice,
  required double currentPrice,
}) {
  final totalValue = quantity * currentPrice;
  final totalInvested = quantity * avgPrice;
  final totalReturns = totalValue - totalInvested;
  final returnsPercent = totalInvested == 0 ? 0.0 : (totalReturns / totalInvested) * 100;

  return {
    'symbol': symbol,
    'name': name,
    'quantity': quantity,
    'avg_price': avgPrice,
    'current_price': currentPrice,
    'total_value': totalValue,
    'total_returns': totalReturns,
    'returns_percent': returnsPercent,
  };
}

void main() {
  group('AppUpdateService Version Comparison Unit Tests', () {
    test('Correctly identifies higher semver major version', () {
      expect(isVersionHigher('2.0.0', '1.9.9'), isTrue);
    });

    test('Correctly identifies higher semver minor version', () {
      expect(isVersionHigher('1.2.0', '1.1.9'), isTrue);
    });

    test('Correctly identifies higher semver patch version', () {
      expect(isVersionHigher('1.1.2', '1.1.1'), isTrue);
    });

    test('Returns false when latest version equals current version', () {
      expect(isVersionHigher('1.1.0', '1.1.0'), isFalse);
    });

    test('Returns false when current version is higher than latest', () {
      expect(isVersionHigher('1.0.5', '1.1.0'), isFalse);
    });
  });

  group('Portfolio Holdings Calculation Unit Tests', () {
    test('Calculates positive returns correctly for profitable stock holding', () {
      final res = calculateHoldingReturns(
        symbol: 'RELIANCE',
        name: 'Reliance Industries',
        quantity: 10,
        avgPrice: 2000.0,
        currentPrice: 2500.0,
      );

      expect(res['total_value'], equals(25000.0));
      expect(res['total_returns'], equals(5000.0));
      expect(res['returns_percent'], equals(25.0));
    });

    test('Calculates negative returns correctly for loss-making stock holding', () {
      final res = calculateHoldingReturns(
        symbol: 'TCS',
        name: 'Tata Consultancy Services',
        quantity: 5,
        avgPrice: 4000.0,
        currentPrice: 3500.0,
      );

      expect(res['total_value'], equals(17500.0));
      expect(res['total_returns'], equals(-2500.0));
      expect(res['returns_percent'], equals(-12.5));
    });
  });
}
