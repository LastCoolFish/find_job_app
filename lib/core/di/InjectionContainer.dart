import 'package:get_it/get_it.dart';
import 'package:find_job_app/core/network/ApiClient.dart';
import 'package:find_job_app/features/analytics/data/datasources/AnalyticsRemoteDataSource.dart';
import 'package:find_job_app/features/analytics/data/repositories/AnalyticsRepositoryImpl.dart';
import 'package:find_job_app/features/analytics/domain/repositories/AnalyticsRepository.dart';
import 'package:find_job_app/features/orders/data/datasources/OrdersRemoteDataSource.dart';
import 'package:find_job_app/features/orders/data/repositories/OrdersRepositoryImpl.dart';
import 'package:find_job_app/features/orders/domain/repositories/OrdersRepository.dart';
import 'package:find_job_app/features/profile/data/datasources/ProfileRemoteDataSource.dart';
import 'package:find_job_app/features/profile/data/repositories/ProfileRepositoryImpl.dart';
import 'package:find_job_app/features/profile/domain/repositories/ProfileRepository.dart';
import 'package:find_job_app/features/vacancies/data/datasources/VacanciesRemoteDataSource.dart';
import 'package:find_job_app/features/vacancies/data/repositories/VacanciesRepositoryImpl.dart';
import 'package:find_job_app/features/vacancies/domain/repositories/VacanciesRepository.dart';

final sl = GetIt.instance;

/// Registers every dependency for the app. Call once from main() before runApp.
void setupDependencies() {
  // Core
  sl.registerLazySingleton<ApiClient>(() => ApiClient.create());

  // Vacancies feature
  sl.registerLazySingleton<VacanciesRemoteDataSource>(
    () => VacanciesRemoteDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<VacanciesRepository>(
    () => VacanciesRepositoryImpl(sl()),
  );

  // Orders feature
  sl.registerLazySingleton<OrdersRemoteDataSource>(
    () => OrdersRemoteDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<OrdersRepository>(
    () => OrdersRepositoryImpl(sl()),
  );

  // Profile feature
  sl.registerLazySingleton<ProfileRemoteDataSource>(
    () => ProfileRemoteDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<ProfileRepository>(
    () => ProfileRepositoryImpl(sl()),
  );

  // Analytics feature
  sl.registerLazySingleton<AnalyticsRemoteDataSource>(
    () => AnalyticsRemoteDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<AnalyticsRepository>(
    () => AnalyticsRepositoryImpl(sl()),
  );
}
