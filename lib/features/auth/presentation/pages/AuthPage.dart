import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:find_job_app/app/AuthNavigation.dart';
import 'package:find_job_app/features/auth/domain/repositories/AuthRepository.dart';
import 'package:find_job_app/core/config/EnvConfig.dart';
import 'package:find_job_app/core/di/InjectionContainer.dart';
import 'package:find_job_app/core/network/ApiClient.dart';
import 'package:find_job_app/features/auth/data/datasources/AuthRemoteDataSource.dart';
import 'package:find_job_app/core/theme/AppColors.dart';
import 'package:find_job_app/core/widgets/FindJobArches.dart';
import 'package:find_job_app/core/widgets/FindJobBrand.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key, this.onComplete});

  final ValueChanged<String>? onComplete;

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage>
    with SingleTickerProviderStateMixin {
  late final _drag = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 220),
  );
  bool _opening = false;
  double _dragDistance = 0;

  void _updateSwipe(DragUpdateDetails details) {
    if (_opening) return;
    final height = MediaQuery.sizeOf(context).height;
    _dragDistance = (_dragDistance - details.delta.dy).clamp(0.0, height);
    if (!MediaQuery.disableAnimationsOf(context)) {
      _drag.value = _dragDistance / height;
    }
  }

  void _cancelSwipe() {
    _dragDistance = 0;
    _drag.animateBack(0, curve: Curves.easeOutCubic);
  }

  void _finishSwipe(DragEndDetails details) {
    final velocity = details.primaryVelocity ?? 0;
    final threshold = (MediaQuery.sizeOf(context).height * .12).clamp(35, 72);
    if (velocity < -350 || (_dragDistance >= threshold && velocity <= 0)) {
      _openForm(context, register: true);
    } else {
      _cancelSwipe();
    }
  }

  @override
  void dispose() {
    _drag.dispose();
    super.dispose();
  }

  Future<void> _openForm(BuildContext context, {required bool register}) async {
    if (_opening) return;
    _opening = true;
    final start = register ? 1.0 - _drag.value : 1.0;
    _dragDistance = 0;
    _drag.value = 0;
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final email = await Navigator.of(context).push<String>(
      PageRouteBuilder<String>(
        pageBuilder: (_, _, _) =>
            _AccountForm(register: register, onComplete: widget.onComplete),
        transitionDuration: reduceMotion
            ? Duration.zero
            : const Duration(milliseconds: 340),
        reverseTransitionDuration: reduceMotion
            ? Duration.zero
            : const Duration(milliseconds: 260),
        transitionsBuilder: (context, animation, _, child) {
          if (MediaQuery.disableAnimationsOf(context)) return child;
          return SlideTransition(
            position: Tween(
              begin: register ? Offset(0, start) : const Offset(1, 0),
              end: Offset.zero,
            ).chain(CurveTween(curve: Curves.easeOutCubic)).animate(animation),
            child: child,
          );
        },
      ),
    );
    _opening = false;
    if (!context.mounted || email == null) return;
    Navigator.of(context).pop(email);
  }

  @override
  Widget build(BuildContext context) => Stack(
    fit: StackFit.expand,
    children: [
      _welcome(context),
      AnimatedBuilder(
        animation: _drag,
        builder: (context, child) {
          if (_drag.value == 0) return const SizedBox.shrink();
          return FractionalTranslation(
            translation: Offset(0, 1 - _drag.value),
            child: child,
          );
        },
        child: const IgnorePointer(
          child: ExcludeSemantics(
            child: ExcludeFocus(child: _AccountForm(register: true)),
          ),
        ),
      ),
    ],
  );

  Widget _welcome(BuildContext context) => Scaffold(
    appBar: AppBar(title: const FindJobBrand()),
    body: SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final needsScroll =
                  constraints.maxHeight < 560 ||
                  MediaQuery.textScalerOf(context).scale(1) > 1.25;
              final artwork = ClipRRect(
                borderRadius: BorderRadius.circular(28),
                child: ColoredBox(
                  color: AppColors.secondary,
                  child: SizedBox(
                    height: (constraints.maxHeight * .42)
                        .clamp(65.0, 330.0)
                        .toDouble(),
                    child: const FindJobArches(showSwipeArrow: true),
                  ),
                ),
              );
              final content = SingleChildScrollView(
                physics: needsScroll
                    ? null
                    : const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(24, 22, 24, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Создать аккаунт',
                      style: findJobHeadline(context, 40),
                    ),
                    const SizedBox(height: 14),
                    const Text('Вакансии и заказы в одном месте'),
                    const SizedBox(height: 26),
                    needsScroll ? _swipeArea(artwork) : artwork,
                    const SizedBox(height: 20),
                    Semantics(
                      button: true,
                      label: 'Открыть регистрацию',
                      child: TextButton.icon(
                        onPressed: () => _openForm(context, register: true),
                        icon: const Icon(
                          Icons.keyboard_double_arrow_up_rounded,
                        ),
                        label: const Text('Свайпни вверх для регистрации'),
                      ),
                    ),
                    const Divider(),
                    Row(
                      children: [
                        const Expanded(child: Text('Уже есть аккаунт?')),
                        TextButton(
                          onPressed: () => _openForm(context, register: false),
                          child: const Text('Войти'),
                        ),
                      ],
                    ),
                  ],
                ),
              );
              return needsScroll ? content : _swipeArea(content);
            },
          ),
        ),
      ),
    ),
  );

  Widget _swipeArea(Widget child) => GestureDetector(
    behavior: HitTestBehavior.opaque,
    onVerticalDragUpdate: _updateSwipe,
    onVerticalDragCancel: _cancelSwipe,
    onVerticalDragEnd: _finishSwipe,
    child: child,
  );
}

class _AccountForm extends StatefulWidget {
  const _AccountForm({required this.register, this.onComplete});

  final bool register;
  final ValueChanged<String>? onComplete;

  @override
  State<_AccountForm> createState() => _AccountFormState();
}

class _AccountFormState extends State<_AccountForm> {
  final _form = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _hidePassword = true;
  bool _submitting = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_submitting ||
        ModalRoute.of(context)?.isCurrent != true ||
        !_form.currentState!.validate()) {
      return;
    }
    final email = _email.text.trim();
    setState(() => _submitting = true);
    var registered = false;
    try {
      if (widget.register) {
        await AuthRemoteDataSource(
          sl<ApiClient>(),
        ).register(email: email, password: _password.text);
        registered = true;
      }
      await sl<AuthRepository>().login(email, _password.text);
      final response = await sl<ApiClient>().dio.get<Map<String, dynamic>>(
        '/auth/me',
        options: Options(extra: {'requiresAuth': true}),
      );
      EnvConfig.currentUserId = response.data!['id'] as int;
      resetLoginRedirect();
      if (!mounted) return;
      final complete = widget.onComplete;
      if (complete == null) {
        Navigator.of(context).pop(email);
      } else {
        complete(email);
      }
    } on DioException catch (error) {
      if (!mounted) return;
      final message = registered
          ? 'Аккаунт создан, но войти не удалось. Попробуйте войти вручную.'
          : widget.register && error.response?.statusCode == 409
          ? 'Пользователь с такой почтой уже существует.'
          : !widget.register && error.response?.statusCode == 401
          ? 'Неверная почта или пароль.'
          : error.response?.statusCode == 403
          ? 'Аккаунт заблокирован.'
          : 'Не удалось выполнить запрос. Проверьте данные и соединение.';
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
      if (registered) Navigator.of(context).pop();
    } catch (_) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Не удалось сохранить сессию. Попробуйте ещё раз.'),
          ),
        );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final register = widget.register;
    return Scaffold(
      backgroundColor: AppColors.secondary,
      appBar: AppBar(
        backgroundColor: AppColors.secondary,
        actions: const [
          Padding(padding: EdgeInsets.only(right: 24), child: FindJobBrand()),
        ],
      ),
      body: SafeArea(
        top: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: ListView(
              padding: const EdgeInsets.only(top: 12),
              children: [
                if (!register)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 20, 24, 18),
                    child: Text.rich(
                      const TextSpan(
                        text: 'С возвращением',
                        children: [
                          TextSpan(
                            text: '!',
                            style: TextStyle(
                              color: Color(0xFF58547B),
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                      style: findJobHeadline(context, 38),
                    ),
                  ),
                Align(
                  alignment: Alignment.centerRight,
                  child: SizedBox(
                    width: 90,
                    height: 44,
                    child: const FindJobArches(showDots: false),
                  ),
                ),
                Material(
                  color: AppColors.card,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(28),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 25, 24, 34),
                    child: Form(
                      key: _form,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            register ? 'Регистрация' : 'Вход в аккаунт',
                            style: register
                                ? findJobHeadline(context, 40)
                                : Theme.of(
                                    context,
                                  ).textTheme.titleLarge?.copyWith(
                                    fontSize: 27,
                                    fontWeight: FontWeight.w600,
                                  ),
                          ),
                          if (register) ...[
                            const SizedBox(height: 12),
                            const Text('Введи почту и придумай пароль'),
                          ],
                          const SizedBox(height: 28),
                          TextFormField(
                            controller: _email,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            decoration: const InputDecoration(
                              labelText: 'Электронная почта',
                              floatingLabelBehavior:
                                  FloatingLabelBehavior.always,
                              hintText: 'name@example.com',
                            ),
                            validator: (value) {
                              final email = value?.trim() ?? '';
                              if (email.isEmpty) {
                                return 'Введи электронную почту';
                              }
                              if (!RegExp(
                                r'^[^\s@]+@[^\s@]+\.[^\s@]+$',
                              ).hasMatch(email)) {
                                return 'Проверь адрес электронной почты';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 18),
                          TextFormField(
                            controller: _password,
                            obscureText: _hidePassword,
                            textInputAction: TextInputAction.done,
                            onFieldSubmitted: (_) => _submit(),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Введи пароль';
                              }
                              if (register && value.length < 8) {
                                return 'Минимум 8 символов';
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                              labelText: 'Пароль',
                              floatingLabelBehavior:
                                  FloatingLabelBehavior.always,
                              hintText: register
                                  ? 'Придумай пароль'
                                  : 'Введи пароль',
                              suffixIcon: IconButton(
                                tooltip: _hidePassword
                                    ? 'Показать пароль'
                                    : 'Скрыть пароль',
                                onPressed: () => setState(
                                  () => _hidePassword = !_hidePassword,
                                ),
                                icon: Icon(
                                  _hidePassword
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          FilledButton.icon(
                            onPressed: _submitting ? null : _submit,
                            iconAlignment: IconAlignment.end,
                            icon: const Icon(Icons.arrow_forward_rounded),
                            label: Text(
                              _submitting
                                  ? (register
                                        ? 'Создаём аккаунт...'
                                        : 'Входим...')
                                  : register
                                  ? 'Создать аккаунт'
                                  : 'Войти',
                            ),
                          ),
                          const SizedBox(height: 12),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
