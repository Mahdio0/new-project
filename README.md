# Movie Database App — Flutter

A production-quality Android Movie Database app built with Flutter, following Clean Architecture and strict mobile engineering rules.

---

## 📋 PHASE 1: Pre-Work (Deep Thinking Protocol)

### Decision Tree Justification

**Stack: Flutter + Riverpod 2.0 + Hive + GoRouter**

| Decision | Justification |
|----------|---------------|
| **Flutter** | Pixel-perfect custom dark UI (OLED true black, hero transitions), single Android target, high-performance rendering engine for image-heavy feeds. NOT React Native: no OTA requirement, not a web team |
| **Riverpod 2.0** | Compile-time provider safety + `AsyncNotifier` = clean loading/error/data state machine. Better than BLoC (less boilerplate), better than Provider (compile safety, no `BuildContext` required) |
| **Hive** | Offline watchlist = structured local data (not just key-value). Dart-native NoSQL, no FFI, O(1) integer key lookup. Ideal for user-owned data (single user, last-write-wins sync) |
| **GoRouter** | Declarative navigation with StatefulShellRoute = tab state preservation via IndexedStack. Deep link support from day one. Android predictive back via `PopScope` integration |

### MFRI Assessment (Feasibility & Risk Index)

| Factor | Score | Reasoning |
|--------|-------|-----------|
| Platform Clarity | +2 | Android explicitly defined, single target |
| Accessibility Readiness | +2 | 48dp touch targets, semantic labels, TalkBack planned |
| Interaction Complexity | -1 | Infinite scroll + hero transitions = moderate risk |
| Performance Risk | -2 | Image-heavy feed + pagination = high risk |
| Offline Dependence | -1 | Watchlist must work offline = moderate risk |
| **MFRI** | **4/10** | **MODERATE → Add performance + UX validation** |

**Mitigations applied:**
- `ListView.builder` / `SliverList` (never `SingleChildScrollView + Column`)
- `CachedNetworkImage` with `memCacheWidth` limits (2× display size)
- `itemExtent` on fixed-height lists for O(1) layout
- `const` constructors everywhere

### Deep Mobile Thinking — Context Scan & Anti-Default Analysis

**Context:** Media/Streaming-type app. Content-heavy, image-dominated, dark UI.

| ❌ AI Default I'm Avoiding | ✅ What I'm Doing Instead |
|----------------------------|--------------------------|
| `SingleChildScrollView + Column` for feeds | `CustomScrollView` + `SliverList` / `ListView.builder` |
| Tab stack reset on switch | `IndexedStack` (StatefulShellRoute) preserves scroll position |
| Same saturation colors in dark mode | True Black `#000000` backgrounds, desaturated text `#E0E0E0` |
| `print()` for debugging | Flutter DevTools, network profiler, Android Logcat |
| No deep links | GoRouter with `/movie/:id` paths from day 1 |
| Ignore predictive back (Android 14+) | `PopScope` widget on detail screens |
| `Image.network` without caching | `CachedNetworkImage` + memory limits |
| Large API responses | TMDB field selection, paginated (20 items/page) |

---

## 🏗️ PHASE 2: Architecture & Navigation

### Directory Structure (Clean Architecture)

```
lib/
├── main.dart                    ← Phase 1 pre-work notes + app bootstrap
├── app.dart                     ← MaterialApp.router + dark theme
│
├── core/
│   ├── constants/
│   │   ├── api_constants.dart   ← TMDB base URL, image sizes
│   │   └── app_constants.dart   ← spacing, touch targets, animation durations
│   ├── router/
│   │   └── app_router.dart      ← GoRouter + StatefulShellRoute (Phase 2)
│   ├── theme/
│   │   └── app_theme.dart       ← OLED dark theme (True Black #000000)
│   └── utils/
│       └── extensions.dart      ← Context, String, Double helpers
│
├── features/
│   ├── home/
│   │   ├── data/models/         ← MovieModel (JSON deserialization)
│   │   ├── domain/entities/     ← Movie (pure Dart, no deps)
│   │   └── presentation/
│   │       ├── screens/         ← HomeScreen (CustomScrollView + SliverList)
│   │       ├── widgets/         ← MovieCard (140×220dp), MovieListItem (120dp)
│   │       └── providers/       ← TrendingMoviesNotifier, topRated, nowPlaying
│   │
│   ├── movie_detail/
│   │   ├── data/models/         ← MovieDetailModel (extends MovieModel)
│   │   ├── domain/entities/     ← MovieDetail + Genre
│   │   └── presentation/
│   │       ├── screens/         ← MovieDetailScreen (SliverAppBar + Hero)
│   │       └── providers/       ← movieDetailProvider (family)
│   │
│   ├── watchlist/
│   │   ├── domain/entities/     ← WatchlistMovie (Hive TypeAdapter)
│   │   └── presentation/
│   │       ├── screens/         ← WatchlistScreen (SliverList + Dismissible)
│   │       └── providers/       ← WatchlistNotifier, isInWatchlistProvider
│   │
│   └── reviews/
│       ├── data/models/         ← ReviewModel + ReviewsResponse
│       ├── domain/entities/     ← Review
│       └── presentation/
│           ├── screens/         ← ReviewsScreen (paginated SliverList)
│           ├── widgets/         ← ReviewCard (expandable, AnimatedCrossFade)
│           └── providers/       ← ReviewsNotifier (family by movieId)
│
├── shared/
│   └── widgets/
│       ├── scaffold_with_bottom_nav.dart  ← NavigationBar + StatefulNavigationShell
│       ├── cached_movie_image.dart         ← CachedNetworkImage + memory limits
│       ├── loading_widget.dart             ← skeleton placeholders
│       └── error_widget.dart               ← retry-action error screens
│
└── services/
    ├── api/
    │   ├── api_client.dart       ← Dio + API key interceptor
    │   └── movie_api_service.dart← TMDB endpoints (trending, detail, reviews, search)
    └── storage/
        ├── hive_storage.dart     ← Hive init + box accessors
        └── watchlist_storage.dart← CRUD operations on watchlist box
```

### Navigation Strategy

```
Bottom NavigationBar (2 tabs — NavigationBar Material 3):
├── Home (/)
│   ├── Trending carousel      ← horizontal ListView.builder
│   ├── Top Rated carousel     ← horizontal ListView.builder
│   ├── Popular vertical list  ← SliverList (infinite scroll)
│   └── /movie/:id             ← stack push (MaterialPage transition)
│       └── /movie/:id/reviews ← stack push
│
└── Watchlist (/watchlist)
    └── WatchlistScreen        ← SliverList + Dismissible swipe-to-remove
```

**Tab State Preservation:** `StatefulShellRoute.indexedStack` from GoRouter maintains each branch's widget tree in an `IndexedStack`. Switching tabs does NOT rebuild inactive tabs — scroll position and loaded data survive tab switches. Tapping an already-selected tab pops back to the branch root.

---

## 🚀 Getting Started

### Prerequisites
- Flutter 3.19+
- Android Studio / VS Code
- TMDB API key — [register at themoviedb.org](https://www.themoviedb.org/settings/api)

### Setup
```bash
# 1. Install dependencies
flutter pub get

# 2. Run with your TMDB API key (never commit the real key)
flutter run --dart-define=TMDB_API_KEY=your_actual_key_here
```

### Running Tests
```bash
flutter test
```

---

## ⚙️ Phase 3 Strict Execution Laws (Acknowledged)

- ✅ **Performance:** `ListView.builder` / `SliverList` only. No `SingleChildScrollView + Column`. `const` constructors everywhere
- ✅ **Touch targets:** All tappable elements ≥ 48dp (`AppConstants.minTouchTarget`)
- ✅ **OLED/Battery:** True Black `#000000` backgrounds, `ThemeMode.dark` forced
- ✅ **Predictive back:** `PopScope` on detail screens (Android 14+)
- ✅ **Debugging:** Flutter DevTools + network profiler (no `print()`)
- ✅ **Images:** `CachedNetworkImage` with `memCacheWidth` = 1.5× display size
- ✅ **API:** Paginated requests (20 items/page), partial responses, offline watchlist

---

## 🔑 TMDB API Key Security

The API key in `lib/core/constants/api_constants.dart` is a **placeholder only**.  
For production, move the key to:
- A `.env` file (excluded from git via `.gitignore`)
- A build-time `--dart-define=TMDB_API_KEY=...` flag
- Obfuscated via `flutter_dotenv` package
