import 'package:flutter/material.dart';
import 'package:find_job_app/core/theme/AppColors.dart';
import 'package:find_job_app/core/widgets/AsciiArt.dart';

/// Full-screen loading: a picture drawn with Braille characters and
/// "Загрузка" under it. For the small spinner at the bottom of a list use
/// LoadingIndicator.
class AsciiLoader extends StatelessWidget {
  const AsciiLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const AsciiArt(loadingPicture),
            const SizedBox(height: 12),
            Text('Загрузка', style: TextStyle(color: AppColors.muted)),
          ],
        ),
      ),
    );
  }
}
