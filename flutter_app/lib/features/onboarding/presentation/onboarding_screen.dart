import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../app/config/theme.dart';
import '../../../core/auth_state.dart';

const _allInterests = [
  ('Stocks', Icons.trending_up_rounded, 'Blue chips, mid-caps, large-caps'),
  ('Mutual Funds', Icons.account_balance_rounded, 'SIP, ELSS, index funds'),
  ('IPO', Icons.rocket_launch_rounded, 'Initial public offerings'),
  ('F&O', Icons.swap_horiz_rounded, 'Futures & options trading'),
  ('Commodities', Icons.inventory_2_rounded, 'Gold, silver, crude'),
  ('ETFs', Icons.category_rounded, 'Exchange traded funds'),
  ('Crypto', Icons.token_rounded, 'Bitcoin, altcoins'),
  ('Bonds', Icons.request_quote_rounded, 'Government & corporate bonds'),
];

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _selected = <String>[];

  void _toggle(String label) {
    setState(() { _selected.contains(label) ? _selected.remove(label) : _selected.add(label); });
  }

  void _done() {
    if (!AuthState.isLoggedIn.value) {
      AuthState.login('demo_token', 'demo@finswitch.app', 'Guest User');
    }
    AuthState.completeOnboarding(_selected);
    context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Your Interests'), actions: [
        TextButton(onPressed: _done, child: const Text('Skip')),
      ]),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const SizedBox(height: 12),
            Text('What interests you?', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 8),
            Text('Pick at least 2 to personalize your experience', style: TextStyle(color: AppTheme.mutedOf(context), fontSize: 15)),
            const SizedBox(height: 24),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2, mainAxisSpacing: 12, crossAxisSpacing: 12,
                childAspectRatio: 1.3,
                children: _allInterests.map((i) => _InterestCard(
                  label: i.$1, icon: i.$2, desc: i.$3,
                  selected: _selected.contains(i.$1),
                  onTap: () => _toggle(i.$1),
                )).toList(),
              ),
            ),
            SizedBox(width: double.infinity, child: ElevatedButton(onPressed: _selected.length < 2 ? null : _done, child: const Text('Continue'))),
          ]),
        ),
      ),
    );
  }
}

class _InterestCard extends StatelessWidget {
  final String label, desc;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;
  const _InterestCard({required this.label, required this.icon, required this.desc, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected ? AppTheme.emeraldGreen.withValues(alpha: 0.15) : AppTheme.cardOf(context),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: selected ? AppTheme.emeraldGreen : AppTheme.borderOf(context), width: selected ? 1.5 : 1),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(icon, color: selected ? AppTheme.emeraldGreen : AppTheme.mutedOf(context), size: 24),
          const SizedBox(height: 8),
          Text(label, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppTheme.textOf(context))),
          Text(desc, style: TextStyle(fontSize: 10, color: AppTheme.mutedOf(context)), maxLines: 1),
        ]),
      ),
    );
  }
}
