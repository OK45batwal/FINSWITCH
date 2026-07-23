import { describe, test, expect } from 'vitest';
import { mapDetail, calculatePnl } from './api';

describe('Website API Client Helper Tests', () => {
  test('mapDetail correctly converts DbRecord to StockDetail schema', () => {
    const rawRecord = {
      symbol: 'RELIANCE',
      name: 'Reliance Industries Ltd.',
      sector: 'Energy',
      price: 2450.5,
      change: 12.5,
      change_percent: 0.51,
      volume: 5000000,
      pe_ratio: 24.2,
      dividend_yield: 0.35,
      high_52w: 2850.0,
      low_52w: 2100.0,
      market_cap: 165000000,
    };

    const detail = mapDetail(rawRecord);

    expect(detail.symbol).toBe('RELIANCE');
    expect(detail.name).toBe('Reliance Industries Ltd.');
    expect(detail.price).toBe(2450.5);
    expect(detail.pe_ratio).toBe(24.2);
    expect(detail.high_52w).toBe(2850.0);
  });

  test('calculatePnl correctly computes total value and returns', () => {
    const pnl = calculatePnl(10, 200.0, 250.0);

    expect(pnl.total_value).toBe(2500.0);
    expect(pnl.total_returns).toBe(500.0);
    expect(pnl.returns_percent).toBe(25.0);
  });
});
