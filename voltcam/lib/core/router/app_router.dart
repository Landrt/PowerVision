import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_colors.dart';
import '../theme/glassmorphism.dart';
import '../../features/map/map_screen.dart';
import '../../features/social/social_screen.dart';
import '../../features/assistant/assistant_screen.dart';
import '../../features/community/community_screen.dart';
import '../../features/device/device_dashboard_screen.dart';

/// Navigation Shell housing the Glassmorphism Bottom Navigation Bar.
class MainNavigationShell extends StatelessWidget {
  final Widget child;

  const MainNavigationShell({
    super.key,
    required this.child,
  });

  int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).matchedLocation;
    if (location.startsWith('/social')) return 1;
    if (location.startsWith('/assistant')) return 2;
    if (location.startsWith('/community')) return 3;
    if (location.startsWith('/device')) return 4;
    return 0; // Default to /map
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go('/map');
        break;
      case 1:
        context.go('/social');
        break;
      case 2:
        context.go('/assistant');
        break;
      case 3:
        context.go('/community');
        break;
      case 4:
        context.go('/device');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedIndex = _calculateSelectedIndex(context);

    return Scaffold(
      body: child,
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: GlassContainer(
            borderRadius: BorderRadius.circular(24.0),
            blur: 16.0,
            opacity: 0.8,
            fillColor: AppColors.surfaceLight,
            borderColor: AppColors.glassBorder,
            child: BottomNavigationBar(
              currentIndex: selectedIndex,
              onTap: (index) => _onItemTapped(index, context),
              backgroundColor: Colors.transparent,
              elevation: 0,
              type: BottomNavigationBarType.fixed,
              selectedItemColor: AppColors.electricCyan,
              unselectedItemColor: AppColors.textMuted,
              selectedLabelStyle: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
              unselectedLabelStyle: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.normal,
              ),
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.map_outlined),
                  activeIcon: Icon(Icons.map_rounded),
                  label: 'Carte Live',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.hub_outlined),
                  activeIcon: Icon(Icons.hub_rounded),
                  label: 'Réseau Social',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.smart_toy_outlined),
                  activeIcon: Icon(Icons.smart_toy_rounded),
                  label: 'Assistant IA',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.people_outline_rounded),
                  activeIcon: Icon(Icons.people_alt_rounded),
                  label: 'Communauté',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.developer_board_outlined),
                  activeIcon: Icon(Icons.developer_board_rounded),
                  label: 'Mon Boîtier',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Central GoRouter configuration for VoltCam.
final GoRouter appRouter = GoRouter(
  initialLocation: '/map',
  routes: [
    ShellRoute(
      builder: (context, state, child) {
        return MainNavigationShell(child: child);
      },
      routes: [
        GoRoute(
          path: '/map',
          name: 'map',
          builder: (context, state) => const MapScreen(),
        ),
        GoRoute(
          path: '/social',
          name: 'social',
          builder: (context, state) => const SocialScreen(),
        ),
        GoRoute(
          path: '/assistant',
          name: 'assistant',
          builder: (context, state) => const AssistantScreen(),
        ),
        GoRoute(
          path: '/community',
          name: 'community',
          builder: (context, state) => const CommunityScreen(),
        ),
        GoRoute(
          path: '/device',
          name: 'device',
          builder: (context, state) => const DeviceDashboardScreen(),
        ),
      ],
    ),
  ],
);
