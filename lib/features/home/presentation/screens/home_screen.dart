import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../shared/widgets/error_widget.dart';
import '../../../../shared/widgets/loading_widget.dart';
import '../providers/movies_provider.dart';
import '../widgets/movie_card.dart';

/// Home Screen — Trending + Top Rated + Now Playing feeds.
///
/// Performance rules applied (mobile-performance.md):
/// - NEVER SingleChildScrollView + Column → using CustomScrollView + SliverList
/// - Each horizontal carousel uses ListView.builder (lazy, not eager)
/// - const constructors on all static widgets
/// - Infinite scroll: loadMore() called when user reaches bottom
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  /// Infinite scroll: load next page when 80% scrolled (not at the very end).
  void _onScroll() {
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    if (currentScroll >= maxScroll * 0.8) {
      ref.read(trendingMoviesProvider.notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final trendingAsync = ref.watch(trendingMoviesProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: CustomScrollView(
          controller: _scrollController,
          physics: const BouncingScrollPhysics(),
          slivers: [
            // App bar — inline, no separate SliverAppBar to stay full-OLED
            const _HomeAppBar(),

            // ─── Trending horizontal carousel ─────────────────────────────
            const _SectionHeader(title: 'Trending This Week'),
            trendingAsync.when(
              data: (state) => _TrendingCarousel(movies: state.movies),
              loading: () => const SliverToBoxAdapter(
                child: SizedBox(
                  height: 260,
                  child: TrendingSkeletonList(),
                ),
              ),
              error: (err, _) => SliverToBoxAdapter(
                child: AppErrorWidget(
                  message: err.toString(),
                  onRetry: () => ref.invalidate(trendingMoviesProvider),
                ),
              ),
            ),

            // ─── Top Rated section ────────────────────────────────────────
            const _SectionHeader(title: 'Top Rated'),
            _TopRatedSection(),

            // ─── Trending vertical infinite list ─────────────────────────
            const _SectionHeader(title: 'Popular Now'),
            trendingAsync.when(
              data: (state) => _TrendingVerticalList(state: state),
              loading: () => const SliverToBoxAdapter(child: AppLoadingWidget()),
              error: (err, _) => SliverToBoxAdapter(
                child: InlineErrorWidget(
                  onRetry: () => ref.invalidate(trendingMoviesProvider),
                ),
              ),
            ),

            // Bottom padding above nav bar
            const SliverPadding(
              padding: EdgeInsets.only(bottom: AppConstants.bottomNavHeight),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Sub-widgets ────────────────────────────────────────────────────────────

class _HomeAppBar extends StatelessWidget {
  const _HomeAppBar();

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(
        AppConstants.spacing16,
        AppConstants.spacing16,
        AppConstants.spacing8,
        AppConstants.spacing8,
      ),
      sliver: SliverToBoxAdapter(
        child: Row(
          children: [
            Text(
              'Movie DB',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFFE50914),
                  ),
            ),
            const Spacer(),
            // Search icon — 48dp touch target (touch-psychology.md)
            IconButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Search coming soon!'),
                    behavior: SnackBarBehavior.floating,
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              icon: const Icon(Icons.search_rounded),
              tooltip: 'Search movies',
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(
        AppConstants.spacing16,
        AppConstants.spacing24,
        AppConstants.spacing16,
        AppConstants.spacing12,
      ),
      sliver: SliverToBoxAdapter(
        child: Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
      ),
    );
  }
}

class _TrendingCarousel extends StatelessWidget {
  const _TrendingCarousel({required this.movies});
  final List movies;

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: SizedBox(
        height: 260,
        // ListView.builder — lazy rendering, NOT map().toList() (mobile-performance.md)
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: AppConstants.spacing16),
          itemCount: movies.length,
          // itemExtent omitted: cards have variable text height
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.only(right: AppConstants.spacing12),
              child: MovieCard(movie: movies[index]),
            );
          },
        ),
      ),
    );
  }
}

class _TopRatedSection extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final topRatedAsync = ref.watch(topRatedMoviesProvider);

    return topRatedAsync.when(
      data: (movies) => SliverToBoxAdapter(
        child: SizedBox(
          height: 260,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppConstants.spacing16),
            itemCount: movies.length,
            itemBuilder: (context, index) => Padding(
              padding: const EdgeInsets.only(right: AppConstants.spacing12),
              child: MovieCard(movie: movies[index]),
            ),
          ),
        ),
      ),
      loading: () => const SliverToBoxAdapter(
        child: SizedBox(height: 260, child: TrendingSkeletonList()),
      ),
      error: (err, _) => SliverToBoxAdapter(
        child: InlineErrorWidget(
          onRetry: () => ref.invalidate(topRatedMoviesProvider),
        ),
      ),
    );
  }
}

/// Vertical list of trending movies with infinite scroll indicator.
/// SliverList — virtualized, not eager (mobile-performance.md §3).
class _TrendingVerticalList extends StatelessWidget {
  const _TrendingVerticalList({required this.state});
  final MovieListState state;

  @override
  Widget build(BuildContext context) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          // Last item: loading indicator for infinite scroll
          if (index == state.movies.length) {
            if (state.isLoadingMore) {
              return const Padding(
                padding: EdgeInsets.all(AppConstants.spacing16),
                child: AppLoadingWidget(),
              );
            }
            if (state.hasReachedMax) {
              return const Padding(
                padding: EdgeInsets.all(AppConstants.spacing16),
                child: Center(
                  child: Text(
                    'All caught up!',
                    style: TextStyle(color: Color(0xFF606060)),
                  ),
                ),
              );
            }
            return const SizedBox.shrink();
          }

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppConstants.spacing16),
            child: MovieListItem(
              movie: state.movies[index],
              rank: index + 1,
            ),
          );
        },
        childCount: state.movies.length + 1, // +1 for loading/end indicator
      ),
    );
  }
}
