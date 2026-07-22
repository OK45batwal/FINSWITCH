import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/markets/presentation/markets_screen.dart';
import '../../features/markets/presentation/stock_detail_screen.dart';
import '../../features/news/presentation/news_screen.dart';
import '../../features/ai/presentation/ai_screen.dart';
import '../../features/portfolio/presentation/portfolio_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

class AppRouter {
  static GoRouter router() {
    return GoRouter(
      navigatorKey: _rootNavigatorKey,
      initialLocation: '/home',
      routes: [
        ShellRoute(
          navigatorKey: _shellNavigatorKey,
          builder: (context, state, child) => AppShell(child: child),
          routes: [
            GoRoute(path: '/home', pageBuilder: (_, __) => _slidePage(const HomeScreen())),
            GoRoute(path: '/markets', pageBuilder: (_, __) => _slidePage(const MarketsScreen())),
            GoRoute(path: '/news', pageBuilder: (_, __) => _slidePage(const NewsScreen())),
            GoRoute(path: '/ai', pageBuilder: (_, __) => _slidePage(const AIScreen())),
            GoRoute(path: '/portfolio', pageBuilder: (_, __) => _slidePage(const PortfolioScreen())),
          ],
        ),
        GoRoute(
          path: '/stock/:symbol',
          parentNavigatorKey: _rootNavigatorKey,
          builder: (_, state) => StockDetailScreen(symbol: state.pathParameters['symbol']!),
        ),
        GoRoute(
          path: '/profile',
          parentNavigatorKey: _rootNavigatorKey,
          pageBuilder: (_, __) => _slidePage(const ProfileScreen(), fromRight: true),
        ),
      ],
    );
  }

  static Page _slidePage(Widget child, {bool fromRight = false}) {
    return CustomTransitionPage(
      key: ValueKey(child.runtimeType),
      child: child,
      transitionsBuilder: (_, animation, __, child) {
        if (fromRight) {
          return SlideTransition(
            position: Tween<Offset>(begin: const Offset(0.15, 0), end: Offset.zero).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
            child: child,
          );
        }
        return FadeTransition(opacity: Tween<double>(begin: 0.85, end: 1).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)), child: child);
      },
      transitionDuration: const Duration(milliseconds: 300),
    );
  }
}

class AppShell extends StatelessWidget {
  final Widget child;
  const AppShell({super.key, required this.child});

  int _currentIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    if (location.startsWith('/home')) return 0;
    if (location.startsWith('/markets')) return 1;
    if (location.startsWith('/news')) return 2;
    if (location.startsWith('/ai')) return 3;
    if (location.startsWith('/portfolio')) return 4;
    return 0;
  }

  void _onTap(BuildContext context, int index) {
    switch (index) {
      case 0: context.go('/home');
      case 1: context.go('/markets');
      case 2: context.go('/news');
      case 3: context.go('/ai');
      case 4: context.go('/portfolio');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex(context),
        onTap: (i) => _onTap(context, i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.trending_up_rounded), label: 'Markets'),
          BottomNavigationBarItem(icon: Icon(Icons.article_rounded), label: 'News'),
          BottomNavigationBarItem(icon: Icon(Icons.auto_awesome_rounded), label: 'AI'),
          BottomNavigationBarItem(icon: Icon(Icons.account_balance_wallet_rounded), label: 'Portfolio'),
        ],
      ),
    );
  }
}
