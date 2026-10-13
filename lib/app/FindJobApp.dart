import 'package:flutter/material.dart';
import 'package:find_job_app/core/theme/AppTheme.dart';
import 'package:find_job_app/features/vacancies/presentation/pages/VacanciesPage.dart';

class FindJobApp extends StatelessWidget {
  const FindJobApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Find Job',
      theme: AppTheme.light,
      home: const VacanciesPage(),
    );
  }
}
