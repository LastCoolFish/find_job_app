import 'package:flutter/material.dart';
import 'package:find_job_app/app/FindJobApp.dart';
import 'package:find_job_app/core/di/InjectionContainer.dart';

void main() {
  setupDependencies();
  runApp(const FindJobApp());
}
