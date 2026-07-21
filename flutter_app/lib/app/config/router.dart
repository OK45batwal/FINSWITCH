import 'package:go_router/go_router.dart';

class AppRouter {
  static final router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(path: '/', builder: (_, __) => const HomeScreen()),
      GoRoute(path: '/markets', builder: (_, __) => const MarketsScreen()),
      GoRoute(path: '/markets/:symbol', builder: (_, state) => StockDetailScreen(symbol: state.pathParameters['symbol']!)),
      GoRoute(path: '/news', builder: (_, __) => const NewsScreen()),
      GoRoute(path: '/ai', builder: (_, __) => const AIScreen()),
      GoRoute(path: '/portfolio', builder: (_, __) => const PortfolioScreen()),
      GoRoute(path: '/profile', builder: (_, __) => const ProfileScreen()),
      GoRoute(path: '/learning', builder: (_, __) => const LearningScreen()),
      GoRoute(path: '/calculators', builder: (_, __) => const CalculatorsScreen()),
      GoRoute(path: '/sip', builder: (_, __) => const SIPPlannerScreen()),
      GoRoute(path: '/watchlist', builder: (_, __) => const WatchlistScreen()),
    ],
  );
}

// Placeholder screens - actual implementations in features/
class HomeScreen extends StatelessWidget { const HomeScreen({super.key}); Widget build(BuildContext c) => const Center(child: Text('Home')); }
class MarketsScreen extends StatelessWidget { const MarketsScreen({super.key}); Widget build(BuildContext c) => const Center(child: Text('Markets')); }
class StockDetailScreen extends StatelessWidget { final String symbol; const StockDetailScreen({super.key, required this.symbol}); Widget build(BuildContext c) => Center(child: Text('Stock: $symbol')); }
class NewsScreen extends StatelessWidget { const NewsScreen({super.key}); Widget build(BuildContext c) => const Center(child: Text('News')); }
class AIScreen extends StatelessWidget { const AIScreen({super.key}); Widget build(BuildContext c) => const Center(child: Text('AI')); }
class PortfolioScreen extends StatelessWidget { const PortfolioScreen({super.key}); Widget build(BuildContext c) => const Center(child: Text('Portfolio')); }
class ProfileScreen extends StatelessWidget { const ProfileScreen({super.key}); Widget build(BuildContext c) => const Center(child: Text('Profile')); }
class LearningScreen extends StatelessWidget { const LearningScreen({super.key}); Widget build(BuildContext c) => const Center(child: Text('Learning')); }
class CalculatorsScreen extends StatelessWidget { const CalculatorsScreen({super.key}); Widget build(BuildContext c) => const Center(child: Text('Calculators')); }
class SIPPlannerScreen extends StatelessWidget { const SIPPlannerScreen({super.key}); Widget build(BuildContext c) => const Center(child: Text('SIP Planner')); }
class WatchlistScreen extends StatelessWidget { const WatchlistScreen({super.key}); Widget build(BuildContext c) => const Center(child: Text('Watchlist')); }
