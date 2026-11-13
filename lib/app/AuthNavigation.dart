import 'package:flutter/material.dart';
import 'package:find_job_app/app/StartupPage.dart';

final navigatorKey = GlobalKey<NavigatorState>();
bool _redirecting = false;
void requireLogin() {
  if (_redirecting) return;
  _redirecting = true;
  WidgetsBinding.instance.addPostFrameCallback((_) {
    navigatorKey.currentState?.pushAndRemoveUntil(
      MaterialPageRoute<void>(builder: (_) => const StartupPage()),
      (_) => false,
    );
  });
}

void resetLoginRedirect() => _redirecting = false;
