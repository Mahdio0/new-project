import 'package:hive_flutter/hive_flutter.dart';

import '../../core/constants/app_constants.dart';
import '../../features/watchlist/domain/entities/watchlist_movie.dart';

/// Hive initialisation and box accessor.
/// Offline-first watchlist storage using structured local data.
class HiveStorage {
  HiveStorage._();

  static Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(WatchlistMovieAdapter());
    await Hive.openBox<WatchlistMovie>(AppConstants.watchlistBox);
    await Hive.openBox<dynamic>(AppConstants.settingsBox);
  }

  static Box<WatchlistMovie> get watchlistBox =>
      Hive.box<WatchlistMovie>(AppConstants.watchlistBox);

  static Box<dynamic> get settingsBox =>
      Hive.box<dynamic>(AppConstants.settingsBox);
}
