// Navigation skeleton
//
// Architecture Decision:
//   - 2 top-level sections (Home, Watchlist) → Bottom Navigation Bar (Android Material 3)
//   - Each tab has its own navigator stack (IndexedStack pattern)
//   - Stack drill-down: Home → Movie Detail → Reviews
//
// Tab State Preservation:
//   GoRouter's StatefulShellRoute + IndexedStack maintains each tab's widget tree.
//   When switching tabs, IndexedStack keeps the previous tab's widget alive (offstage=false).
//   This ensures scroll positions, loaded data, and sub-routes survive tab switches.
//   Rule: "Never reset tab stack on switch."
//
// Deep Links:
//   /                     → Home tab (trending movies)
//   /movie/:id            → Movie detail (stack push from Home tab)
//   /movie/:id/reviews    → Reviews (stack push from Movie detail)
//   /watchlist            → Watchlist tab
//
// Back Navigation:
//   - System back pops the current stack within the active tab
//   - On Home root / Watchlist root: system back exits app (Android convention)
//   - Predictive back (Android 14+): supported via GoRouter + PopScope

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/movie_detail/presentation/screens/movie_detail_screen.dart';
import '../../features/reviews/presentation/screens/reviews_screen.dart';
import '../../features/watchlist/presentation/screens/watchlist_screen.dart';
import '../../shared/widgets/scaffold_with_bottom_nav.dart';

// Route path constants — URL structure mirrors navigation hierarchy
class AppRoutes {
  AppRoutes._();

  static const String home = '/';
  static const String movieDetail = '/movie/:id';
  static const String movieDetailReviews = '/movie/:id/reviews';
  static const String watchlist = '/watchlist';
}

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRoutes.home,
    debugLogDiagnostics: false,
    routes: [
      // StatefulShellRoute: preserves tab state via IndexedStack
      // Each branch maintains its own Navigator stack independently.
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return ScaffoldWithBottomNav(navigationShell: navigationShell);
        },
        branches: [
          // Branch 0: Home tab
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.home,
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: HomeScreen(),
                ),
                routes: [
                  // Stack navigation: Home → Movie Detail
                  GoRoute(
                    path: 'movie/:id',
                    pageBuilder: (context, state) {
                      final movieId = int.parse(state.pathParameters['id']!);
                      return MaterialPage(
                        key: state.pageKey,
                        child: MovieDetailScreen(movieId: movieId),
                      );
                    },
                    routes: [
                      // Stack: Movie Detail → Reviews
                      GoRoute(
                        path: 'reviews',
                        pageBuilder: (context, state) {
                          final movieId =
                              int.parse(state.pathParameters['id']!);
                          return MaterialPage(
                            key: state.pageKey,
                            child: ReviewsScreen(movieId: movieId),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),

          // Branch 1: Watchlist tab
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.watchlist,
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: WatchlistScreen(),
                ),
              ),
            ],
          ),
        ],
      ),
    ],

    // Fallback for invalid deep links — never crash
    errorBuilder: (context, state) => Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.broken_image_outlined,
                color: Colors.white54, size: 64),
            const SizedBox(height: 16),
            const Text(
              'Page not found',
              style: TextStyle(color: Colors.white70, fontSize: 18),
            ),
            const SizedBox(height: 24),
            TextButton(
              onPressed: () => context.go(AppRoutes.home),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    ),
  );
});
