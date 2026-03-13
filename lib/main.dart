// PHASE 1 PRE-WORK: Decision Tree Justification
//
// STACK: Flutter + Riverpod + Hive + GoRouter
//
// Decision Tree Justification (decision-trees.md):
//   ✅ Flutter chosen because:
//      - Need pixel-perfect custom UI (dark OLED cards, hero transitions)
//      - Identical UI on Android (single platform target)
//      - High-performance rendering engine critical for image-heavy movie feeds
//      - NOT chosen React Native because: no OTA requirement, not a web team
//   ✅ Riverpod 2.0 chosen because:
//      - Compile-time safety (server-heavy app with async states)
//      - Code generation reduces boilerplate
//      - Better than BLoC (less boilerplate), better than Provider (compile safety)
//   ✅ Hive chosen because:
//      - Offline watchlist = structured local data (not just key-value)
//      - Fast NoSQL, Flutter-native, no native code dependency
//   ✅ GoRouter chosen because:
//      - Declarative navigation = deep links from day one (per mobile-navigation.md)
//      - Tab state via ShellRoute + IndexedStack
//
// MFRI Assessment (SKILL.md) — API Pagination + Offline Watchlist:
//   Platform Clarity (+2): Android explicitly defined
//   Accessibility Readiness (+2): 48dp targets, semantic labels planned
//   Interaction Complexity (-1): Pagination + hero transitions — moderate
//   Performance Risk (-2): Movie image feeds + infinite scroll — high risk
//   Offline Dependence (-1): Watchlist must work offline — moderate
//   MFRI = (2+2) - (1+2+1) = 4/10 → MODERATE → Add performance + UX validation
//
// Deep Mobile Thinking — Context Scan & Anti-Default Analysis:
//   CONTEXT: Media/Streaming-type app. Content-heavy, image-dominated, dark UI.
//   AI DEFAULTS I AM ACTIVELY AVOIDING:
//   1. ❌ SingleChildScrollView + Column for movie feeds → ✅ SliverList / ListView.builder
//   2. ❌ Tab stack reset on switch → ✅ IndexedStack preserves scroll state
//   3. ❌ Same saturation colors in dark mode → ✅ True Black #000000 + desaturated palette
//   4. ❌ print() for debugging → ✅ Flutter DevTools + network profiler
//   5. ❌ No deep links → ✅ GoRouter with /movie/:id paths from day one
//   6. ❌ Ignore predictive back (Android 14+) → ✅ PopScope widget
//   7. ❌ Image.network without caching → ✅ CachedNetworkImage with memCacheWidth limits

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'app.dart';
import 'services/storage/hive_storage.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Android: enforce portrait + edge-to-edge (Android 15+ ready)
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // OLED battery: true black status/nav bars on Android
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.black,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  // Initialize Hive for offline watchlist
  await HiveStorage.init();

  runApp(
    // ProviderScope at root — Riverpod requirement
    const ProviderScope(
      child: MovieDbApp(),
    ),
  );
}
