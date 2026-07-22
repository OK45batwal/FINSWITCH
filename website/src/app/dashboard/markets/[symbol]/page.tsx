import StockDetailClient from './StockDetailClient';

export function generateStaticParams() {
  return [
    { symbol: 'RELIANCE' },
    { symbol: 'TCS' },
    { symbol: 'INFY' },
    { symbol: 'HDFCBANK' },
    { symbol: 'ICICIBANK' },
    { symbol: 'TATAMOTORS' },
    { symbol: 'BHARTIARTL' },
    { symbol: 'ITC' },
    { symbol: 'SBIN' },
    { symbol: 'LT' },
  ];
}

export default async function StockDetailPage({ params }: { params: Promise<{ symbol: string }> }) {
  const { symbol } = await params;
  return <StockDetailClient symbol={symbol} />;
}
