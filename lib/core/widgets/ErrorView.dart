import 'package:flutter/material.dart';
import 'package:find_job_app/core/widgets/AsciiArt.dart';

/// Full-screen error: picture, "404 — ничего не найдено" and a retry button.
/// With `showArt: false` (bottom of a list) it shows [message] instead,
/// without the picture.
class ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  final String retryLabel;
  final bool showArt;

  const ErrorView({
    super.key,
    required this.message,
    this.onRetry,
    this.retryLabel = 'Повторить',
    this.showArt = true,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showArt) ...[
              const AsciiArt(errorPicture),
              const SizedBox(height: 16),
              const Text('404 — ничего не найдено', textAlign: TextAlign.center),
            ] else
              Text(message, textAlign: TextAlign.center),
            if (onRetry != null) ...[
              const SizedBox(height: 12),
              ElevatedButton(onPressed: onRetry, child: Text(retryLabel)),
            ],
          ],
        ),
      ),
    );
  }
}
