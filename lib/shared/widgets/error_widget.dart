import 'package:flutter/material.dart';

/// Generic error display with retry action.
/// Mobile rule: Never show a dead end — always provide retry path (SKILL.md §4).
class AppErrorWidget extends StatelessWidget {
  const AppErrorWidget({
    super.key,
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.wifi_off_rounded,
              color: Color(0xFF606060),
              size: 64,
            ),
            const SizedBox(height: 16),
            Text(
              'Something went wrong',
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 24),
            // 48dp touch target — Mobile rule (touch-psychology.md)
            SizedBox(
              height: 48,
              child: ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text('Try Again'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Compact error for inline use (e.g., inside a list section).
class InlineErrorWidget extends StatelessWidget {
  const InlineErrorWidget({
    super.key,
    required this.onRetry,
  });

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded, color: Color(0xFFCF6679), size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Failed to load',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          // 48dp touch target
          SizedBox(
            width: 48,
            height: 48,
            child: IconButton(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded, size: 20, color: Color(0xFFE50914)),
            ),
          ),
        ],
      ),
    );
  }
}
