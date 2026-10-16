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

Базовые понятия (`Vacancy`, `Skill`, `Order`, `Company`, `Customer`) называются словом-понятием + `Entity`/`Model`.

---

## `main.dart`

Точка входа Flutter. Обязана называться именно так и лежать в `lib/main.dart` — это жёсткое требование тулинга (`flutter run` ищет файл по этому пути), поэтому это единственный файл в проекте, который не переименован под CamelCase. Вызывает `setupDependencies()` (регистрирует все зависимости в `get_it`) и запускает `FindJobApp`.

## `app/FindJobApp.dart`

Корневой виджет — `MaterialApp` с темой приложения (`AppTheme.light`) и стартовым экраном `MainShell`.

## `app/MainShell.dart`

Корневой экран с нижней панелью (`NavigationBar`, скруглённая сверху, цвета шапки): вкладки «Главная» (`HomePage`), «Вакансии» (`VacanciesPage`), «Заказы» (`OrdersPage`), «Профиль» (`ProfilePage`). Страницы лежат в `IndexedStack`, поэтому при переключении вкладок списки не перезагружаются и прокрутка сохраняется. `extendBody: true` — списки уходят под скруглённую панель.

## `features/home` — главная

| Файл | Слой | Назначение |
|---|---|---|
| [`presentation/pages/HomePage.dart`](features/home/presentation/pages/HomePage.dart) | presentation | Вкладка «Главная». Пока заглушка (`PlaceholderView`). |

## `features/settings` — настройки

| Файл | Слой | Назначение |
|---|---|---|
| [`presentation/pages/SettingsPage.dart`](features/settings/presentation/pages/SettingsPage.dart) | presentation | Экран настроек, открывается шестерёнкой из профиля (`Navigator.push`). Шапка с заголовком «Настройки» и стрелкой назад. Пока заглушка. |

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
| [`theme/AppColors.dart`](theme/AppColors.dart) | Цвета **активной** палитры, которыми пользуются виджеты. Основная палитра задаётся одной строкой: `static const AppPalette palette = AppPalettes.sage;` |
| [`theme/AppTheme.dart`](theme/AppTheme.dart) | `AppTheme.light` — `ThemeData` из активной палитры, `AppTheme.fromPalette(p)` — из любой: цвета `ColorScheme`, шапки, кнопок, индикатора загрузки. Подключается в `FindJobApp`. |
| [`widgets/FindJobAppBar.dart`](widgets/FindJobAppBar.dart) | Общая шапка экранов: скруглённый низ, иконка и надпись «FindJob» по умолчанию; `title` и `icon` задают свой заголовок и иконку перед ним (`icon: null` — без иконки). Кнопки экрана передаются через `actions`. Использовать вместе с `Scaffold(extendBodyBehindAppBar: true)`. |
| [`widgets/InitialsAvatar.dart`](widgets/InitialsAvatar.dart) | Квадратик с инициалами вместо логотипа/фото (компании, заказчика, профиля). Размер задаётся `size` (по умолчанию 48). |
| [`utils/Formatters.dart`](utils/Formatters.dart) | `formatMoney(300000)` → «300 000 ₽», `formatDateTime(date)` → «27 сентября, 13:37». |
| [`widgets/FilterSheetParts.dart`](widgets/FilterSheetParts.dart) | Общие части окон фильтров: `FilterSheetFrame` (заголовок, «Сбросить», «Показать»), `FilterSection`, `filterInputDecoration`, `FilterChoices<T>` (чипы с одним выбором), `PlatformChoices` (чипы площадок с сервера). |
| [`widgets/PlaceholderView.dart`](widgets/PlaceholderView.dart) | Заглушка для недоделанных экранов: иконка, заголовок, подпись по центру. |
| [`widgets/LoadingIndicator.dart`](widgets/LoadingIndicator.dart) | Общий виджет спиннера загрузки, переиспользуется во всех фичах. |
| [`widgets/ErrorView.dart`](widgets/ErrorView.dart) | Полноэкранная ошибка: картинка `errorPicture`, под ней текст «404 — ничего не найдено» и кнопка «Повторить» (`onRetry`, текст кнопки — `retryLabel`). С `showArt: false` (низ списка) вместо картинки и «404» показывается `message`. |
| [`widgets/AsciiArt.dart`](widgets/AsciiArt.dart) | `AsciiArt` — многострочный текст моноширинным шрифтом (картинка занимает не больше `maxWidthFactor` ширины экрана, по умолчанию половину). `errorPicture` и `loadingPicture` — картинки символами Брайля для ошибки и загрузки. |
| [`widgets/AsciiLoader.dart`](widgets/AsciiLoader.dart) | Полноэкранная загрузка: картинка `loadingPicture` и под ней «Загрузка». Для маленькой крутилки внизу списка — `LoadingIndicator`. |
| [`widgets/Tag.dart`](widgets/Tag.dart) | Небольшая скруглённая плашка с текстом и необязательной иконкой (грейд, формат работы, навык). Цвета можно переопределить через `background` / `foreground`. |

---

## `features/vacancies` — список вакансий (`GET /vacancies`)

Единственная фича с полностью реализованным UI (данные → экран).

| Файл | Слой | Назначение |
|---|---|---|
| [`domain/entities/VacancyEntity.dart`](features/vacancies/domain/entities/VacancyEntity.dart) | domain | Вакансия: `id`, `jobTitle`, `salary`, `description`, `place`, `grade`, `format`, `platform`, вложенные `CompanyEntity` и `List<SkillEntity>`. Соответствует `VacancyOutSchema`. |
| [`domain/entities/SkillEntity.dart`](features/vacancies/domain/entities/SkillEntity.dart) | domain | Навык вакансии: `id`, `name`. |
| [`data/models/SkillModel.dart`](features/vacancies/data/models/SkillModel.dart) | data | `SkillEntity` + `fromJson`. |
| [`domain/entities/CompanyEntity.dart`](features/vacancies/domain/entities/CompanyEntity.dart) | domain | Краткая карточка компании (`id`, `name`, `rating`, `accreditation`), встроенная в ответ о вакансии — отдельного `/companies` эндпоинта на бэкенде нет. |
| [`domain/repositories/VacanciesRepository.dart`](features/vacancies/domain/repositories/VacanciesRepository.dart) | domain | Интерфейс `getVacancies()` — то, с чем работает экран, не зная про Dio. |
| [`data/models/VacancyModel.dart`](features/vacancies/data/models/VacancyModel.dart) | data | `VacancyEntity` + `fromJson`: парсит JSON вакансии, включая вложенные `company` и `skills`. |
| [`data/models/CompanyModel.dart`](features/vacancies/data/models/CompanyModel.dart) | data | `CompanyEntity` + `fromJson`. |
| [`data/datasources/VacanciesRemoteDataSource.dart`](features/vacancies/data/datasources/VacanciesRemoteDataSource.dart) | data | Делает `GET /vacancies` через `ApiClient`, конвертирует ошибки Dio в `NetworkException`/`ServerException`. |
| [`data/repositories/VacanciesRepositoryImpl.dart`](features/vacancies/data/repositories/VacanciesRepositoryImpl.dart) | data | Реализация интерфейса: вызывает datasource, ловит исключения, возвращает `Result<List<VacancyEntity>>`. |
| [`presentation/pages/VacanciesPage.dart`](features/vacancies/presentation/pages/VacanciesPage.dart) | presentation | Экран целиком с подгрузкой при прокрутке: грузит вакансии страницами по 20 (`offset`/`limit`), следующую страницу запрашивает, когда до конца списка остаётся меньше 600 px (`ScrollController`). Внизу списка — крутилка или кнопка «Повторить». В шапке — иконка `Symbols.person_search`, надпись «FindJob» и кнопка фильтров (пока пустое окно снизу). |
| [`domain/entities/VacancyFilters.dart`](features/vacancies/domain/entities/VacancyFilters.dart) | domain | Фильтры поиска: должность, зарплата от, грейд, источник, сортировка. `toQueryParameters()` собирает параметры для `GET /vacancies/search`. Обходит особенности API: по умолчанию сортирует по `id` (иначе страницы повторяются), при сортировке по зарплате прячет вакансии без неё. Фильтра по городу нет: сервер не находит текст на кириллице. |
| [`presentation/widgets/VacancyFiltersSheet.dart`](features/vacancies/presentation/widgets/VacancyFiltersSheet.dart) | presentation | Окно фильтров снизу. «Показать» закрывает окно и возвращает новые `VacancyFilters`, «Сбросить» очищает форму. Список источников берётся с сервера (`GET /vacancies/platforms`), страница загружает его один раз при первом открытии фильтров. |
| [`presentation/widgets/VacancyCard.dart`](features/vacancies/presentation/widgets/VacancyCard.dart) | presentation | Карточка одной вакансии: компания, должность, зарплата, грейд/формат/город, навыки, кнопки «Подробнее» (открывает вакансию на hh.ru / Хабр Карьере) и «В избранное». |

## `features/orders` — заказы (`GET /orders`)

| Файл | Слой | Назначение |
|---|---|---|
| [`domain/entities/OrderEntity.dart`](features/orders/domain/entities/OrderEntity.dart) | domain | Заказ: `id`, `name`, `description`, `price`, `publicationTimestamp`, вложенный `CustomerEntity`. |
| [`domain/entities/OrderFilters.dart`](features/orders/domain/entities/OrderFilters.dart) | domain | Фильтры заказов: название, цена от/до, площадка, сортировка (`OrderSort`: новые / старые / дорогие / дешёвые). При сортировке по цене прячет заказы без цены. Поиск по названию на кириллице сервер пока не находит. |
| [`domain/entities/CustomerEntity.dart`](features/orders/domain/entities/CustomerEntity.dart) | domain | Краткая карточка заказчика (`id`, `name`, `href`, `platform`) — встроена в ответ заказа, отдельного `/customers` эндпоинта нет. |
| [`domain/repositories/OrdersRepository.dart`](features/orders/domain/repositories/OrdersRepository.dart) | domain | Интерфейс `getOrders(filters, offset, limit)` и `getPlatforms()`. |
| [`data/models/OrderModel.dart`](features/orders/data/models/OrderModel.dart) | data | `OrderEntity` + `fromJson`. |
| [`data/models/CustomerModel.dart`](features/orders/data/models/CustomerModel.dart) | data | `CustomerEntity` + `fromJson`. |
| [`data/datasources/OrdersRemoteDataSource.dart`](features/orders/data/datasources/OrdersRemoteDataSource.dart) | data | `GET /orders/search` с параметрами из `OrderFilters` постранично и `GET /orders/platforms`. |
| [`data/repositories/OrdersRepositoryImpl.dart`](features/orders/data/repositories/OrdersRepositoryImpl.dart) | data | Реализация репозитория. |
| [`presentation/pages/OrdersPage.dart`](features/orders/presentation/pages/OrdersPage.dart) | presentation | Список заказов с подгрузкой при прокрутке (по 20) и фильтрами. Логика та же, что в `VacanciesPage`: смена фильтров перезагружает список, опоздавшие ответы со старыми фильтрами отбрасываются. |
| [`presentation/widgets/OrderFiltersSheet.dart`](features/orders/presentation/widgets/OrderFiltersSheet.dart) | presentation | Окно фильтров заказов: название, цена от/до, площадка (с сервера), сортировка. |
| [`presentation/widgets/OrderCard.dart`](features/orders/presentation/widgets/OrderCard.dart) | presentation | Карточка заказа: заказчик, площадка, название, цена, описание (до 3 строк, дальше многоточие), дата публикации, кнопка «Подробнее». |

## `features/profile` — профиль (`GET /profiles/by-user/{id}`, `GET /users/{id}`)

Входа пока нет, поэтому показывается пользователь `EnvConfig.currentUserId` (= 1).

| Файл | Слой | Назначение |
|---|---|---|
| [`domain/entities/ProfileEntity.dart`](features/profile/domain/entities/ProfileEntity.dart) | domain | Профиль соискателя: `username` (ник), `name`, `desiredSalary`, `desiredFormat`, `desiredGrade`, `skills`. Соответствует `ProfileOutSchema`. |
| [`domain/entities/UserEntity.dart`](features/profile/domain/entities/UserEntity.dart) | domain | Аккаунт: `email`, `phone`, `role`, `createdAt`, `lastLoginAt`. Соответствует `UserOutSchema`. |
| [`domain/repositories/ProfileRepository.dart`](features/profile/domain/repositories/ProfileRepository.dart) | domain | `getProfileByUser(userId)`, `getUser(userId)`. |
| [`data/models/ProfileModel.dart`](features/profile/data/models/ProfileModel.dart), [`UserModel.dart`](features/profile/data/models/UserModel.dart) | data | Сущности + `fromJson`. Навыки парсятся через `SkillModel` из `vacancies`. |
| [`data/datasources/ProfileRemoteDataSource.dart`](features/profile/data/datasources/ProfileRemoteDataSource.dart) | data | `GET /profiles/by-user/{id}` и `GET /users/{id}`. |
| [`data/repositories/ProfileRepositoryImpl.dart`](features/profile/data/repositories/ProfileRepositoryImpl.dart) | data | Реализация репозитория. |
| [`presentation/pages/ProfilePage.dart`](features/profile/presentation/pages/ProfilePage.dart) | presentation | Вкладка «Профиль»: аватар с инициалами, ник крупно и имя под ним; блоки «Что ищу» (зарплата, формат, грейд), «Аккаунт» (email, телефон, дата регистрации) и «Навыки» (`Tag`). Пустые поля — «Не указано». Профиль и аккаунт грузятся параллельно через `FutureBuilder`. Шестерёнка открывает `SettingsPage`. |

## Как добавить presentation-слой для новой фичи

До экрана доведены `vacancies` и `orders`, `profile` показывает данные с сервера, у `home`/`settings` — заглушки. Новые фичи создаём по мере надобности. Чтобы показать новую фичу пользователю, нужно по образцу `features/vacancies/presentation/*` создать:
1. `<Feature>Page.dart` — `StatefulWidget`: в `initState` вызвать метод репозитория (`sl<<Feature>Repository>()`), хранить данные / `_isLoading` / `_error` в полях и обновлять через `setState` (пример с пагинацией — `VacanciesPage`).
2. Показывать `LoadingIndicator` / `ErrorView` из `core/widgets`, пока данные грузятся или если пришла ошибка.
