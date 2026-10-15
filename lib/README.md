# `lib/` — структура проекта

Приложение построено по **Clean Architecture** (feature-first): каждая фича в `features/` независимо делится на три слоя — `domain` (бизнес-правила, ничего не знает про сеть/UI), `data` (реализация — HTTP, JSON) и `presentation` (UI, состояние экрана). Общий код лежит в `core/`.

Бэкенд — FastAPI-сервис (`find_job_API`, `http://localhost:8000`), см. `openapi.json` для полного контракта.

## Соглашение об именовании файлов и классов

Правило единое для всего проекта: **имя файла = имя класса, который в нём объявлен**, в CamelCase (не `snake_case`). Поэтому `file_names` лint отключён в [`analysis_options.yaml`](../analysis_options.yaml) — это осознанное решение, а не забытая настройка.

| Суффикс класса | Слой | Что означает |
|---|---|---|
| `...Entity` | `domain/entities` | Чистое описание данных (только поля + `Equatable`), не знает про JSON/HTTP |
| `...Model` | `data/models` | Наследует `...Entity`, добавляет `fromJson(...)` — умеет собрать себя из ответа API |
| `...Repository` (интерфейс) | `domain/repositories` | Абстракция, которую видит `presentation` — не знает про Dio |
| `...RepositoryImpl` | `data/repositories` | Реализация интерфейса: вызывает datasource, превращает исключения в `Result` |
| `...RemoteDataSource` (+ `Impl`) | `data/datasources` | Единственное место, где реально происходит `dio.get(...)` |
| `...Page` | `presentation/pages` | Экран целиком (`Scaffold`), сам хранит своё состояние через `StatefulWidget` + `setState` |
| `...Card` и т.п. | `presentation/widgets` | Переиспользуемые куски UI |

Базовые понятия (`Vacancy`, `Skill`, `Order`, `Company`, `Customer`, `Profile`, `User`, `Event`) называются словом-понятием + `Entity`/`Model`. Уникальные, не табличные ответы аналитики (top-skills, top-companies, engagement) намеренно получили короткие имена — `TopSkill`, `TopCompany`, `Engagement` — вместо буквального повторения длинных названий OpenAPI-схем.

---

## `main.dart`

Точка входа Flutter. Обязана называться именно так и лежать в `lib/main.dart` — это жёсткое требование тулинга (`flutter run` ищет файл по этому пути), поэтому это единственный файл в проекте, который не переименован под CamelCase. Вызывает `setupDependencies()` (регистрирует все зависимости в `get_it`) и запускает `FindJobApp`.

## `app/FindJobApp.dart`

Корневой виджет — `MaterialApp` с темой приложения (`Material 3`, `colorSchemeSeed`) и стартовым экраном (`VacanciesPage`). Сюда же в будущем добавится роутинг, если он появится.

---

## `core/` — общий код, не привязанный к конкретной фиче

| Файл | Назначение |
|---|---|
| [`config/EnvConfig.dart`](config/EnvConfig.dart) | Базовый URL API. Для Android-эмулятора автоматически подставляет `10.0.2.2` вместо `localhost` (эмулятор не видит хост-машину напрямую), для web/desktop — обычный `localhost:8000`. Также хранит таймауты сети. |
| [`network/ApiClient.dart`](network/ApiClient.dart) | Тонкая обёртка над `Dio`: создаёт единственный на всё приложение HTTP-клиент с настроенным `baseUrl` и таймаутами из `EnvConfig`. |
| [`error/Exceptions.dart`](error/Exceptions.dart) | `ServerException`, `NetworkException` — исключения, которые бросает **data-слой** (datasources), когда запрос падает. |
| [`error/Failures.dart`](error/Failures.dart) | `Failure`, `ServerFailure`, `NetworkFailure` — то же самое, но для **domain/presentation**: `Failure` — Equatable-обёртка ошибки, которую видит UI, без деталей Dio. |
| [`utils/Result.dart`](utils/Result.dart) | `Result<T>` (sealed class) + `Success<T>`/`Failed<T>` — Either-подобная обёртка. Репозитории возвращают её вместо `throw`, чтобы presentation-слой обрабатывал ошибки через `result.when(success:, failure:)`, а не `try/catch`. |
| [`di/InjectionContainer.dart`](di/InjectionContainer.dart) | Настройка `get_it` (service locator). Единая точка, где собирается граф зависимостей: `ApiClient → RemoteDataSource → Repository`. Вызывается один раз в `main()`. |
| [`theme/AppPalette.dart`](theme/AppPalette.dart) | `AppPalette` — один набор цветов (имена по роли: `primary`, `secondary`, `tertiary`, `background`, `onPrimary`, `accent`, `ink`, `muted`, `salary`, `card`). `AppPalettes` — все палитры приложения: `sage`, `sunset`, `sky`, `coffee`, `blush`. Новые палитры добавляются сюда, старые не удаляются. |
| [`theme/AppColors.dart`](theme/AppColors.dart) | Цвета **активной** палитры, которыми пользуются виджеты. Основная палитра задаётся одной строкой: `static const AppPalette palette = AppPalettes.blush;` |
| [`theme/AppTheme.dart`](theme/AppTheme.dart) | `AppTheme.light` — `ThemeData` из активной палитры, `AppTheme.fromPalette(p)` — из любой: цвета `ColorScheme`, шапки, кнопок, индикатора загрузки. Подключается в `FindJobApp`. |
| [`widgets/LoadingIndicator.dart`](widgets/LoadingIndicator.dart) | Общий виджет спиннера загрузки, переиспользуется во всех фичах. |
| [`widgets/ErrorView.dart`](widgets/ErrorView.dart) | Общий виджет отображения ошибки с кнопкой «Повторить» (`onRetry`). |
| [`widgets/Tag.dart`](widgets/Tag.dart) | Небольшая скруглённая плашка с текстом и необязательной иконкой (грейд, формат работы, навык). Цвета можно переопределить через `background` / `foreground`. |

---

## `features/vacancies` — список вакансий (`GET /vacancies`)

Единственная фича с полностью реализованным UI (данные → экран).

| Файл | Слой | Назначение |
|---|---|---|
| [`domain/entities/VacancyEntity.dart`](features/vacancies/domain/entities/VacancyEntity.dart) | domain | Вакансия: `id`, `jobTitle`, `salary`, `description`, `place`, `grade`, `format`, `platform`, вложенные `CompanyEntity` и `List<SkillEntity>`. Соответствует `VacancyOutSchema`. |
| [`domain/entities/CompanyEntity.dart`](features/vacancies/domain/entities/CompanyEntity.dart) | domain | Краткая карточка компании (`id`, `name`, `rating`, `accreditation`), встроенная в ответ о вакансии — отдельного `/companies` эндпоинта на бэкенде нет. |
| [`domain/repositories/VacanciesRepository.dart`](features/vacancies/domain/repositories/VacanciesRepository.dart) | domain | Интерфейс `getVacancies()` — то, с чем работает экран, не зная про Dio. |
| [`data/models/VacancyModel.dart`](features/vacancies/data/models/VacancyModel.dart) | data | `VacancyEntity` + `fromJson`: парсит JSON вакансии, включая вложенные `company` и `skills`. |
| [`data/models/CompanyModel.dart`](features/vacancies/data/models/CompanyModel.dart) | data | `CompanyEntity` + `fromJson`. |
| [`data/datasources/VacanciesRemoteDataSource.dart`](features/vacancies/data/datasources/VacanciesRemoteDataSource.dart) | data | Делает `GET /vacancies` через `ApiClient`, конвертирует ошибки Dio в `NetworkException`/`ServerException`. |
| [`data/repositories/VacanciesRepositoryImpl.dart`](features/vacancies/data/repositories/VacanciesRepositoryImpl.dart) | data | Реализация интерфейса: вызывает datasource, ловит исключения, возвращает `Result<List<VacancyEntity>>`. |
| [`presentation/pages/VacanciesPage.dart`](features/vacancies/presentation/pages/VacanciesPage.dart) | presentation | Экран целиком с подгрузкой при прокрутке: грузит вакансии страницами по 20 (`offset`/`limit`), следующую страницу запрашивает, когда до конца списка остаётся меньше 600 px (`ScrollController`). Внизу списка — крутилка или кнопка «Повторить». В шапке — иконка `Symbols.person_search`, надпись «FindJob» и кнопка фильтров (пока пустое окно снизу). |
| [`domain/entities/VacancyFilters.dart`](features/vacancies/domain/entities/VacancyFilters.dart) | domain | Фильтры поиска: должность, зарплата от, грейд, источник, сортировка. `toQueryParameters()` собирает параметры для `GET /vacancies/search`. Обходит особенности API: по умолчанию сортирует по `id` (иначе страницы повторяются), при сортировке по зарплате прячет вакансии без неё. Фильтра по городу нет: сервер не находит текст на кириллице. |
| [`presentation/widgets/VacancyFiltersSheet.dart`](features/vacancies/presentation/widgets/VacancyFiltersSheet.dart) | presentation | Окно фильтров снизу. «Показать» закрывает окно и возвращает новые `VacancyFilters`, «Сбросить» очищает форму. |
| [`presentation/widgets/VacancyCard.dart`](features/vacancies/presentation/widgets/VacancyCard.dart) | presentation | Карточка одной вакансии: компания, должность, зарплата, грейд/формат/город, навыки, кнопки «Подробнее» (открывает вакансию на hh.ru / Хабр Карьере) и «В избранное». |

## `features/skills` — справочник навыков (`GET /skills`)

| Файл | Слой | Назначение |
|---|---|---|
| [`domain/entities/SkillEntity.dart`](features/skills/domain/entities/SkillEntity.dart) | domain | Навык: `id`, `name`. Переиспользуется в `vacancies` (список навыков вакансии) и `analytics` (топ навыков). |
| [`domain/repositories/SkillsRepository.dart`](features/skills/domain/repositories/SkillsRepository.dart) | domain | Интерфейс `getSkills()`. |
| [`data/models/SkillModel.dart`](features/skills/data/models/SkillModel.dart) | data | `SkillEntity` + `fromJson`. |
| [`data/datasources/SkillsRemoteDataSource.dart`](features/skills/data/datasources/SkillsRemoteDataSource.dart) | data | `GET /skills`. |
| [`data/repositories/SkillsRepositoryImpl.dart`](features/skills/data/repositories/SkillsRepositoryImpl.dart) | data | Реализация репозитория. |

*(Presentation-слой для этой фичи не создавался — данные используются как зависимость `vacancies`/`analytics`; при необходимости добавляется по тому же паттерну, что и `vacancies`.)*

## `features/orders` — заказы (`GET /orders`)

| Файл | Слой | Назначение |
|---|---|---|
| [`domain/entities/OrderEntity.dart`](features/orders/domain/entities/OrderEntity.dart) | domain | Заказ: `id`, `name`, `description`, `price`, `publicationTimestamp`, вложенный `CustomerEntity`. |
| [`domain/entities/CustomerEntity.dart`](features/orders/domain/entities/CustomerEntity.dart) | domain | Краткая карточка заказчика (`id`, `name`, `href`, `platform`) — встроена в ответ заказа, отдельного `/customers` эндпоинта нет. |
| [`domain/repositories/OrdersRepository.dart`](features/orders/domain/repositories/OrdersRepository.dart) | domain | Интерфейс `getOrders()`. |
| [`data/models/OrderModel.dart`](features/orders/data/models/OrderModel.dart) | data | `OrderEntity` + `fromJson`. |
| [`data/models/CustomerModel.dart`](features/orders/data/models/CustomerModel.dart) | data | `CustomerEntity` + `fromJson`. |
| [`data/datasources/OrdersRemoteDataSource.dart`](features/orders/data/datasources/OrdersRemoteDataSource.dart) | data | `GET /orders`. |
| [`data/repositories/OrdersRepositoryImpl.dart`](features/orders/data/repositories/OrdersRepositoryImpl.dart) | data | Реализация репозитория. |

## `features/profile` — профиль соискателя и аккаунт (`GET /profiles`, `GET /users`)

| Файл | Слой | Назначение |
|---|---|---|
| [`domain/entities/ProfileEntity.dart`](features/profile/domain/entities/ProfileEntity.dart) | domain | Анкета соискателя: `desiredSalary`, `desiredFormat`, `desiredGrade`, `username`, ссылка на `userId`. |
| [`domain/entities/UserEntity.dart`](features/profile/domain/entities/UserEntity.dart) | domain | Аккаунт: `email`, `phone`, `role` (`UserRole`: user/admin/blocked), даты создания/входа. Лежит в `profile`, а не в отдельной фиче `users`, так как у бэкенда нет самостоятельного экрана для пользователей — профиль всегда идёт в связке с аккаунтом. |
| [`domain/repositories/ProfileRepository.dart`](features/profile/domain/repositories/ProfileRepository.dart) | domain | Интерфейс `getProfiles()` + `getUsers()`. |
| [`data/models/ProfileModel.dart`](features/profile/data/models/ProfileModel.dart) | data | `ProfileEntity` + `fromJson`. |
| [`data/models/UserModel.dart`](features/profile/data/models/UserModel.dart) | data | `UserEntity` + `fromJson`. |
| [`data/datasources/ProfileRemoteDataSource.dart`](features/profile/data/datasources/ProfileRemoteDataSource.dart) | data | `GET /profiles` и `GET /users`. |
| [`data/repositories/ProfileRepositoryImpl.dart`](features/profile/data/repositories/ProfileRepositoryImpl.dart) | data | Реализация репозитория. |

## `features/analytics` — агрегированная аналитика (`/analytics/*`)

Единственная фича, чьи ответы — не отражение таблицы БД, а вычисляемые агрегаты. Поэтому её сущности названы коротко (`TopSkill`, `TopCompany`, `Engagement`), а не дословно как схемы бэкенда (`SkillDemandSchema` и т.д. — упоминаются только в doc-комментариях).

| Файл | Слой | Назначение |
|---|---|---|
| [`domain/entities/TopSkillEntity.dart`](features/analytics/domain/entities/TopSkillEntity.dart) | domain | Навык + число вакансий, где он требуется (`GET /analytics/top-skills`). |
| [`domain/entities/TopCompanyEntity.dart`](features/analytics/domain/entities/TopCompanyEntity.dart) | domain | Компания + число опубликованных вакансий (`GET /analytics/top-companies`). |
| [`domain/entities/EngagementEntity.dart`](features/analytics/domain/entities/EngagementEntity.dart) | domain | Метрики вовлечённости (среднее время просмотра, клики по ссылке, всего просмотров, CTR) для одной вакансии/заказа. |
| [`domain/repositories/AnalyticsRepository.dart`](features/analytics/domain/repositories/AnalyticsRepository.dart) | domain | Интерфейс: `getTopSkills`, `getTopCompanies`, `getVacancyAnalytics(id)`, `getOrderAnalytics(id)`. |
| [`data/models/TopSkillModel.dart`](features/analytics/data/models/TopSkillModel.dart) | data | `TopSkillEntity` + `fromJson` (переиспользует `SkillModel` для вложенного навыка). |
| [`data/models/TopCompanyModel.dart`](features/analytics/data/models/TopCompanyModel.dart) | data | `TopCompanyEntity` + `fromJson` (переиспользует `CompanyModel`). |
| [`data/models/EngagementModel.dart`](features/analytics/data/models/EngagementModel.dart) | data | `EngagementEntity` + `fromJson`. |
| [`data/datasources/AnalyticsRemoteDataSource.dart`](features/analytics/data/datasources/AnalyticsRemoteDataSource.dart) | data | Все 4 запроса к `/analytics/*`. |
| [`data/repositories/AnalyticsRepositoryImpl.dart`](features/analytics/data/repositories/AnalyticsRepositoryImpl.dart) | data | Реализация репозитория. |

## `features/tracking` — события пользователя (`POST /events`, `GET /events/*-views`)

Фиксирует просмотры/клики/поиск — сырые данные, на основе которых `analytics` считает `Engagement`.

| Файл | Слой | Назначение |
|---|---|---|
| [`domain/entities/EventEntity.dart`](features/tracking/domain/entities/EventEntity.dart) | domain | Событие: `userId`, `eventType` (`EventType`: viewStart/viewEnd/linkClick/search), опционально `vacancyId`/`orderId`/`durationSeconds`/`payload`, `occurredAt`. Здесь же лежат `eventTypeFromString`/`eventTypeToJson` — конвертеры enum ↔ строка API. |
| [`domain/repositories/TrackingRepository.dart`](features/tracking/domain/repositories/TrackingRepository.dart) | domain | Интерфейс: `createEvent(...)`, `getVacanciesViews(ids)`, `getOrdersViews(ids)`. |
| [`data/models/EventModel.dart`](features/tracking/data/models/EventModel.dart) | data | `EventEntity` + `fromJson`. |
| [`data/datasources/TrackingRemoteDataSource.dart`](features/tracking/data/datasources/TrackingRemoteDataSource.dart) | data | `POST /events`, `GET /events/vacancies-views`, `GET /events/orders-views`. |
| [`data/repositories/TrackingRepositoryImpl.dart`](features/tracking/data/repositories/TrackingRepositoryImpl.dart) | data | Реализация репозитория. |

---

## Как добавить presentation-слой для новой фичи

Только `vacancies` доведена до экрана. Чтобы показать `orders`/`profile`/`skills`/`analytics` пользователю, нужно по образцу `features/vacancies/presentation/*` создать:
1. `<Feature>Page.dart` — `StatefulWidget`: в `initState` вызвать метод репозитория (`sl<<Feature>Repository>()`), хранить данные / `_isLoading` / `_error` в полях и обновлять через `setState` (пример с пагинацией — `VacanciesPage`).
2. Показывать `LoadingIndicator` / `ErrorView` из `core/widgets`, пока данные грузятся или если пришла ошибка.
