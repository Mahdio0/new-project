import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Bottom navigation scaffold.
/// Uses StatefulNavigationShell (GoRouter) + NavigationBar (Material 3).
///
/// State preservation: StatefulShellRoute maintains each branch's sub-tree in an
/// IndexedStack under the hood. Switching tabs does NOT rebuild or reset the
/// widget tree of inactive tabs — scroll position and loaded data are preserved.
class ScaffoldWithBottomNav extends StatelessWidget {
  const ScaffoldWithBottomNav({
    super.key,
    required this.navigationShell,
  });

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // OLED: true black background
      backgroundColor: Colors.black,

      // The body is the StatefulNavigationShell — internally an IndexedStack.
      // Each branch keeps its Navigator alive when off-screen.
      body: navigationShell,

      // Material 3 NavigationBar — 80dp height, ripple on tap
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (index) {
          // Tap on already-selected tab scrolls to top
          if (navigationShell.currentIndex == index) {
            // Tab already selected — pop stack to root of this branch
            navigationShell.goBranch(index, initialLocation: true);
          } else {
            navigationShell.goBranch(index);
          }
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
            // Semantic label for TalkBack
            tooltip: 'Home — Trending movies',
          ),
          NavigationDestination(
            icon: Icon(Icons.bookmark_outline_rounded),
            selectedIcon: Icon(Icons.bookmark_rounded),
            label: 'Watchlist',
            tooltip: 'My Watchlist — saved offline',
          ),
        ],
      ),
    );
  }
}
