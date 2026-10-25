import 'package:flutter/material.dart';
import 'package:find_job_app/core/theme/AppColors.dart';

/// One block of the home screen: a bold title with an optional action on the
/// right ("Все") and the content under it. The content goes edge to edge,
/// so horizontal lists can scroll to the screen border.
class HomeSection extends StatelessWidget {
  final String title;
  final Widget? action;
  final Widget child;

  const HomeSection({
    super.key,
    required this.title,
    this.action,
    required this.child,
  });

  /// Small spinner while the block loads.
  const HomeSection.loading({super.key, required this.title})
      : action = null,
        child = const Padding(
          padding: EdgeInsets.symmetric(vertical: 16),
          child: Center(
            child: SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        );

  /// Gray one-line note instead of the content.
  HomeSection.message({super.key, required this.title, required String message})
      : action = null,
        child = _Note(message);

  const HomeSection.error({super.key, required this.title})
      : action = null,
        child = const _Note('Не удалось загрузить. Потяните вниз, чтобы обновить');

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 8, 8),
            child: SizedBox(
              // Same height with and without the button, so titles line up.
              height: 40,
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: AppColors.ink,
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                  ),
                  ?action,
                ],
              ),
            ),
          ),
          child,
        ],
      ),
    );
  }
}

class _Note extends StatelessWidget {
  final String text;

  const _Note(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Text(text, style: TextStyle(color: AppColors.muted)),
    );
  }
}
