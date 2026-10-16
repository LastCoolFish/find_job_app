import 'package:flutter/material.dart';
import 'package:find_job_app/core/theme/AppColors.dart';
import 'package:find_job_app/core/utils/Result.dart';

/// Building blocks shared by the filter bottom sheets (vacancies, orders).

/// Sheet frame: title with "Сбросить", the given sections, "Показать" button.
/// Scrolls and lifts itself above the keyboard.
class FilterSheetFrame extends StatelessWidget {
  final List<Widget> children;
  final VoidCallback onReset;
  final VoidCallback onApply;

  const FilterSheetFrame({
    super.key,
    required this.children,
    required this.onReset,
    required this.onApply,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      // Lift the sheet above the keyboard while typing.
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Фильтры',
                    style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                  ),
                ),
                TextButton(onPressed: onReset, child: const Text('Сбросить')),
              ],
            ),
            const SizedBox(height: 12),
            ...children,
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: FilledButton(
                onPressed: onApply,
                style: FilledButton.styleFrom(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
                child: const Text('Показать'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// One block of the sheet: bold title and its control, with spacing below.
class FilterSection extends StatelessWidget {
  final String title;
  final Widget child;

  const FilterSection({super.key, required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              title,
              style: TextStyle(color: AppColors.ink, fontWeight: FontWeight.w700),
            ),
          ),
          child,
        ],
      ),
    );
  }
}

/// Filled rounded text field style used in the filter sheets.
InputDecoration filterInputDecoration(String hint) => InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: AppColors.background,
      isDense: true,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );

/// Row of chips where at most one is selected.
/// [allowNone]: tapping the selected chip again clears the choice.
class FilterChoices<T> extends StatelessWidget {
  final List<T> values;
  final T? selected;
  final String Function(T value) labelOf;
  final ValueChanged<T?> onChanged;
  final bool allowNone;

  const FilterChoices({
    super.key,
    required this.values,
    required this.selected,
    required this.labelOf,
    required this.onChanged,
    this.allowNone = true,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final value in values)
          _FilterChip(
            label: labelOf(value),
            selected: value == selected,
            onTap: () => onChanged(
              allowNone && value == selected ? null : value,
            ),
          ),
      ],
    );
  }
}

/// Platform chips loaded from the server (`/vacancies/platforms`,
/// `/orders/platforms`). Shows a small spinner while loading.
class PlatformChoices extends StatelessWidget {
  final Future<Result<List<String>>> platforms;
  final String? selected;
  final ValueChanged<String?> onChanged;

  const PlatformChoices({
    super.key,
    required this.platforms,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Result<List<String>>>(
      future: platforms,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        }

        final error = Text(
          'Не удалось загрузить источники',
          style: TextStyle(color: AppColors.muted),
        );
        final result = snapshot.data;
        if (result == null) return error;

        return result.when(
          success: (codes) => FilterChoices<String>(
            values: codes,
            selected: selected,
            labelOf: (code) => code,
            onChanged: onChanged,
          ),
          failure: (_) => error,
        );
      },
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
      showCheckmark: false,
      selectedColor: AppColors.primary,
      backgroundColor: AppColors.background,
      labelStyle: TextStyle(
        color: selected ? AppColors.onPrimary : AppColors.ink,
        fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
      ),
      side: BorderSide.none,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    );
  }
}
