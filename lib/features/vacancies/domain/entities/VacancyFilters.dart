import 'package:equatable/equatable.dart';
import 'package:find_job_app/core/utils/Enums.dart';

/// Search filters for `GET /vacancies/search`. Null means "don't filter".
class VacancyFilters extends Equatable {
  // Substring, case-insensitive. The server currently finds nothing for
  // Cyrillic text (Latin like "Python" works), so there is no city filter yet.
  final String? jobTitle;
  final int? salaryMin;
  final int? grade; // 0..4: Intern, Junior, Middle, Senior, Lead
  final String? platform; // 'hh' or 'habr'
  final VacanciesSortBy? sortBy;
  final Order order;

  const VacancyFilters({
    this.jobTitle,
    this.salaryMin,
    this.grade,
    this.platform,
    this.sortBy,
    this.order = Order.asc,
  });

  /// How many filters are set (sorting is not counted), for the badge
  /// on the filters button.
  int get activeCount => [jobTitle, salaryMin, grade, platform]
      .where((value) => value != null)
      .length;

  Map<String, dynamic> toQueryParameters() {
    // Workarounds for the current API:
    // - without ORDER BY the server may return rows in a different order on
    //   every request, so pages repeat/skip vacancies -> sort by id by default;
    // - "salary desc" puts vacancies without salary first -> when sorting by
    //   salary, only show vacancies that have one.
    final effectiveSalaryMin =
        salaryMin ?? (sortBy == VacanciesSortBy.salary ? 1 : null);

    return {
      if (jobTitle != null) 'job_title': jobTitle,
      'salary_min': ?effectiveSalaryMin,
      if (grade != null) 'grade': grade,
      if (platform != null) 'platform': platform,
      // enum must go as "salary", not "VacanciesSortBy.salary"
      'sort_by': (sortBy ?? VacanciesSortBy.id).name,
      'order': order.name,
    };
  }

  @override
  List<Object?> get props =>
      [jobTitle, salaryMin, grade, platform, sortBy, order];
}
