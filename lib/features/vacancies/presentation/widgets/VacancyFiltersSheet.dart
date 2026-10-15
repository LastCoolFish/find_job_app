import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:find_job_app/core/theme/AppColors.dart';
import 'package:find_job_app/core/utils/Enums.dart';
import 'package:find_job_app/features/vacancies/domain/entities/VacancyFilters.dart';
import 'package:find_job_app/features/vacancies/presentation/widgets/VacancyCard.dart';

/// Content of the filters bottom sheet. Closes with `Navigator.pop(filters)`
/// on "Показать"; swiping it away returns null (nothing changes).
class VacancyFiltersSheet extends StatefulWidget {
  final VacancyFilters initial;

  const VacancyFiltersSheet({super.key, required this.initial});

  @override
  State<VacancyFiltersSheet> createState() => _VacancyFiltersSheetState();
}

class _SortOption {
  final String label;
  final VacanciesSortBy? sortBy;
  final Order order;

  const _SortOption(this.label, this.sortBy, this.order);
}

class _VacancyFiltersSheetState extends State<VacancyFiltersSheet> {
  static const _platforms = {'hh': 'hh.ru', 'habr': 'Хабр Карьера'};

  static const _sortOptions = [
    _SortOption('По умолчанию', null, Order.asc),
    _SortOption('Сначала высокая зарплата', VacanciesSortBy.salary, Order.desc),
    _SortOption('Сначала низкая зарплата', VacanciesSortBy.salary, Order.asc),
    _SortOption('Популярные', VacanciesSortBy.views, Order.desc),
    _SortOption('По названию', VacanciesSortBy.job_title, Order.asc),
  ];

  late final TextEditingController _jobTitleController;
  late final TextEditingController _salaryController;
  int? _grade;
  String? _platform;
  late _SortOption _sort;

  @override
  void initState() {
    super.initState();
    final f = widget.initial;
    _jobTitleController = TextEditingController(text: f.jobTitle ?? '');
    _salaryController = TextEditingController(text: f.salaryMin?.toString() ?? '');
    _grade = f.grade;
    _platform = f.platform;
    _sort = _sortOptions.firstWhere(
      (o) => o.sortBy == f.sortBy && (o.sortBy == null || o.order == f.order),
      orElse: () => _sortOptions.first,
    );
  }

  @override
  void dispose() {
    _jobTitleController.dispose();
    _salaryController.dispose();
    super.dispose();
  }

  void _reset() {
    setState(() {
      _jobTitleController.clear();
      _salaryController.clear();
      _grade = null;
      _platform = null;
      _sort = _sortOptions.first;
    });
  }

  void _apply() {
    final jobTitle = _jobTitleController.text.trim();
    Navigator.of(context).pop(
      VacancyFilters(
        jobTitle: jobTitle.isEmpty ? null : jobTitle,
        salaryMin: int.tryParse(_salaryController.text),
        grade: _grade,
        platform: _platform,
        sortBy: _sort.sortBy,
        order: _sort.order,
      ),
    );
  }

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
                TextButton(onPressed: _reset, child: const Text('Сбросить')),
              ],
            ),
            const SizedBox(height: 12),

            _sectionTitle('Должность'),
            TextField(
              controller: _jobTitleController,
              textInputAction: TextInputAction.next,
              decoration: _inputDecoration('Например, Python или Java'),
            ),
            const SizedBox(height: 16),

            _sectionTitle('Зарплата от, ₽'),
            TextField(
              controller: _salaryController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: _inputDecoration('Например, 150000'),
            ),
            const SizedBox(height: 16),

            _sectionTitle('Грейд'),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (var i = 0; i < VacancyCard.grades.length; i++)
                  _choice(
                    label: VacancyCard.grades[i],
                    selected: _grade == i,
                    // Tapping the selected chip again clears it.
                    onTap: () => setState(() => _grade = _grade == i ? null : i),
                  ),
              ],
            ),
            const SizedBox(height: 16),

            _sectionTitle('Источник'),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final entry in _platforms.entries)
                  _choice(
                    label: entry.value,
                    selected: _platform == entry.key,
                    onTap: () => setState(
                      () => _platform = _platform == entry.key ? null : entry.key,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),

            _sectionTitle('Сортировка'),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final option in _sortOptions)
                  _choice(
                    label: option.label,
                    selected: _sort == option,
                    onTap: () => setState(() => _sort = option),
                  ),
              ],
            ),
            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              height: 48,
              child: FilledButton(
                onPressed: _apply,
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

  Widget _sectionTitle(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(
          text,
          style: TextStyle(color: AppColors.ink, fontWeight: FontWeight.w700),
        ),
      );

  InputDecoration _inputDecoration(String hint) => InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: AppColors.background,
        isDense: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      );

  Widget _choice({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) =>
      ChoiceChip(
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
