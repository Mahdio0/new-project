# Movie Database App

A production-quality Android movie browser built with **Flutter**, featuring trending/top-rated feeds, offline watchlist, and paginated reviews — all powered by the [TMDB API](https://www.themoviedb.org/).

## Tech Stack

| Layer | Technology |
|-------|------------|
| **Framework** | Flutter 3.19+ |
| **State Management** | Riverpod 2.0 (`AsyncNotifier`) |
| **Local Storage** | Hive (offline watchlist) |
| **Navigation** | GoRouter (`StatefulShellRoute`) |
| **Networking** | Dio (retry interceptor, error mapping) |
| **Image Caching** | CachedNetworkImage |

## Features

- **Home Feed** — Trending, Top Rated, and Now Playing carousels with pull-to-refresh
- **Movie Detail** — Backdrop + poster hero transitions, genres, overview, rating
- **Reviews** — Paginated review list with expandable cards
- **Watchlist** — Offline-first storage via Hive, swipe-to-dismiss with undo
- **Deep Linking** — `/movie/:id` and `/movie/:id/reviews` routes
- **OLED Dark Theme** — True black (`#000000`) backgrounds for battery efficiency

## Getting Started

### Prerequisites

- Flutter 3.19+
- Android Studio or VS Code
- TMDB API key — [register here](https://www.themoviedb.org/settings/api)

### Setup

```bash
# Install dependencies
flutter pub get

# Run with your TMDB API key (never commit the key to source control)
flutter run --dart-define=TMDB_API_KEY=your_actual_key_here
```

### Running Tests

```bash
flutter test
```

## Project Structure

```
lib/
├── main.dart                          # App entry point
├── app.dart                           # MaterialApp.router + theme
├── core/
│   ├── constants/                     # API & app constants
│   ├── router/                        # GoRouter configuration
│   ├── theme/                         # OLED dark theme
│   └── utils/                         # Extensions (Context, String, Double)
├── features/
│   ├── home/                          # Trending / Top Rated / Now Playing
│   ├── movie_detail/                  # Movie detail screen
│   ├── watchlist/                     # Offline watchlist (Hive)
│   └── reviews/                       # Paginated movie reviews
├── shared/widgets/                    # Reusable UI components
└── services/
    ├── api/                           # Dio client + TMDB endpoints
    └── storage/                       # Hive initialization + CRUD
```

Each feature follows **Clean Architecture** with `data/`, `domain/`, and `presentation/` layers.

## Architecture

- **Clean Architecture** — Separation of data models, domain entities, and presentation
- **Riverpod 2.0** — Compile-time safe providers with `AsyncNotifier` for loading/error/data states
- **GoRouter** — Declarative routing with `StatefulShellRoute.indexedStack` for tab state preservation
- **Error Handling** — `AppException` sealed hierarchy; UI never catches raw `DioException`
- **Retry Logic** — Exponential back-off (500 ms → 1 s → 2 s) on transient failures
- **Pagination** — `PaginatedResult<T>` generic wrapper for TMDB paginated endpoints

## API Key Security

The API key in `lib/core/constants/api_constants.dart` is a **placeholder**.
Always provide your key at build time:

```bash
flutter run --dart-define=TMDB_API_KEY=your_actual_key_here
flutter build apk --dart-define=TMDB_API_KEY=your_actual_key_here
```

The `.gitignore` excludes `.env`, `.env.local`, and `lib/core/constants/secrets.dart`.

## License

This project is for educational and portfolio purposes.
