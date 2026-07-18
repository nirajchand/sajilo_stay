import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sajilo_stay/core/constants/colors.dart';
import 'package:sajilo_stay/features/auth/presentation/pages/login_screen.dart';
import 'package:sajilo_stay/features/auth/presentation/state/auth_state.dart';
import 'package:sajilo_stay/features/dashboard/presentation/pages/bookings_tab.dart';
import 'package:sajilo_stay/features/dashboard/presentation/pages/favorites_tab.dart';
import 'package:sajilo_stay/features/dashboard/presentation/pages/home_tab.dart';
import 'package:sajilo_stay/features/dashboard/presentation/pages/profile_tab.dart';
import 'package:sajilo_stay/features/dashboard/presentation/state/dashboard_state.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  static const _tabs = <Widget>[
    HomeTab(),
    BookingsTab(),
    FavoritesTab(),
    ProfileTab(),
  ];

  static const _navItems = <_NavItem>[
    _NavItem(icon: Icons.home_outlined, activeIcon: Icons.home_rounded, label: 'Home'),
    _NavItem(icon: Icons.calendar_today_outlined, activeIcon: Icons.calendar_today_rounded, label: 'Bookings'),
    _NavItem(icon: Icons.favorite_outline, activeIcon: Icons.favorite_rounded, label: 'Favorites'),
    _NavItem(icon: Icons.person_outline_rounded, activeIcon: Icons.person_rounded, label: 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    // Navigate to login when the user logs out
    ref.listen<AuthState>(authStateProvider, (previous, next) {
      if (next.status == AuthStatus.unauthenticated) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (_) => false,
        );
      }
    });

    final currentIndex = ref.watch(dashboardTabIndexProvider);

    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: IndexedStack(
        index: currentIndex,
        children: _tabs,
      ),
      bottomNavigationBar: _DashboardNavBar(
        currentIndex: currentIndex,
        items: _navItems,
        onTap: (i) => ref.read(dashboardTabIndexProvider.notifier).setTab(i),
      ),
    );
  }
}

class _DashboardNavBar extends StatelessWidget {
  final int currentIndex;
  final List<_NavItem> items;
  final ValueChanged<int> onTap;

  const _DashboardNavBar({
    required this.currentIndex,
    required this.items,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: kSurfaceLevel1,
        border: Border(
          top: BorderSide(color: kNeutralColor.withValues(alpha: 0.12), width: 1),
        ),
      ),
      child: SafeArea(
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(items.length, (index) {
              final item = items[index];
              final isActive = index == currentIndex;
              return GestureDetector(
                onTap: () => onTap(index),
                behavior: HitTestBehavior.opaque,
                child: SizedBox(
                  width: 70,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        isActive ? item.activeIcon : item.icon,
                        color: isActive ? kAccentColor : kNeutralColor,
                        size: 22,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.label,
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 10,
                          fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
                          color: isActive ? kAccentColor : kNeutralColor,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}
