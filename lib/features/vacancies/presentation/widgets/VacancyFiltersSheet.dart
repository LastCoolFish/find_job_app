import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:find_job_app/core/utils/Enums.dart';
import 'package:find_job_app/core/utils/Result.dart';
import 'package:find_job_app/core/widgets/FilterSheetParts.dart';
import 'package:find_job_app/features/vacancies/domain/entities/VacancyFilters.dart';
import 'package:find_job_app/features/vacancies/presentation/widgets/VacancyCard.dart';

/// Content of the filters bottom sheet. Closes with `Navigator.pop(filters)`
/// on "Показать"; swiping it away returns null (nothing changes).
class VacancyFiltersSheet extends StatefulWidget {
  final VacancyFilters initial;

  /// Platform codes from `GET /vacancies/platforms`. Passed in from the page
  /// so the request is made once, not every time the sheet opens.
  final Future<Result<List<String>>> platforms;

  const VacancyFiltersSheet({
    super.key,
    required this.initial,
    required this.platforms,
  });

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
    return FilterSheetFrame(
      onReset: _reset,
      onApply: _apply,
      children: [
        FilterSection(
          title: 'Должность',
          child: TextField(
            controller: _jobTitleController,
            textInputAction: TextInputAction.next,
            decoration: filterInputDecoration('Например, Python или Java'),
          ),
        ),
        FilterSection(
          title: 'Зарплата от, ₽',
          child: TextField(
            controller: _salaryController,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: filterInputDecoration('Например, 150000'),
          ),
        ),
        FilterSection(
          title: 'Грейд',
          child: FilterChoices<int>(
            values: List.generate(VacancyCard.grades.length, (i) => i),
            selected: _grade,
            labelOf: (i) => VacancyCard.grades[i],
            onChanged: (value) => setState(() => _grade = value),
          ),
        ),
        FilterSection(
          title: 'Источник',
          child: PlatformChoices(
            platforms: widget.platforms,
            selected: _platform,
            onChanged: (value) => setState(() => _platform = value),
          ),
        ),
        FilterSection(
          title: 'Сортировка',
          child: FilterChoices<_SortOption>(
            values: _sortOptions,
            selected: _sort,
            labelOf: (option) => option.label,
            // One sort option is always selected.
            allowNone: false,
            onChanged: (value) => setState(() => _sort = value!),
          ),
        ),
      ],
    );
  }
}
