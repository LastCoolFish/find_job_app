import 'dart:async';

import 'package:flutter/material.dart';
import 'package:find_job_app/app/MainShell.dart';
import 'package:find_job_app/core/theme/AppColors.dart';
import 'package:find_job_app/core/widgets/FindJobArches.dart';
import 'package:find_job_app/core/widgets/FindJobBrand.dart';
import 'package:find_job_app/features/auth/presentation/pages/AuthPage.dart';

class StartupPage extends StatefulWidget {
  const StartupPage({super.key});

  @override
  State<StartupPage> createState() => _StartupPageState();
}

class _StartupPageState extends State<StartupPage>
    with SingleTickerProviderStateMixin {
  static const _introDuration = Duration(milliseconds: 700);
  late final AnimationController _motion = AnimationController(
    vsync: this,
    duration: _introDuration,
  );
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (MediaQuery.disableAnimationsOf(context)) {
        _openWelcome();
      } else {
        _motion.forward();
        _timer = Timer(_introDuration, _openWelcome);
      }
    });
  }

  void _openWelcome() {
    final navigator = Navigator.of(context);
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    navigator.pushReplacement<void, void>(
      PageRouteBuilder<void>(
        pageBuilder: (_, _, _) => AuthPage(
          onComplete: (email) => navigator.pushAndRemoveUntil<void>(
            PageRouteBuilder<void>(
              transitionDuration: reduceMotion
                  ? Duration.zero
                  : const Duration(milliseconds: 480),
              pageBuilder: (_, _, _) => MainShell(initialPreviewEmail: email),
              transitionsBuilder: (_, animation, _, child) {
                final entrance = animation.drive(
                  CurveTween(curve: Curves.easeOutCubic),
                );
                return FadeTransition(
                  opacity: entrance,
                  child: SlideTransition(
                    position: entrance.drive(
                      Tween(begin: const Offset(0, .08), end: Offset.zero),
                    ),
                    child: child,
                  ),
                );
              },
            ),
            (_) => false,
          ),
        ),
        transitionDuration: reduceMotion
            ? Duration.zero
            : const Duration(milliseconds: 220),
        transitionsBuilder: (_, animation, _, child) =>
            FadeTransition(opacity: animation, child: child),
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _motion.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Colors.white,
    body: SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Semantics(
            label: 'FindJob загружается',
            excludeSemantics: true,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const FindJobBrand(),
                const SizedBox(height: 28),
                SizedBox(
                  width: 186,
                  height: 150,
                  child: FindJobArches(progress: _motion),
                ),
                const SizedBox(height: 20),
                Text(
                  'Открываем FindJob',
                  style: TextStyle(color: AppColors.muted, fontSize: 14),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
