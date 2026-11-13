import 'package:flutter/material.dart';
import 'package:find_job_app/core/theme/AppColors.dart';

class FindJobBrand extends StatelessWidget {
  const FindJobBrand({super.key});

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      CircleAvatar(
        radius: 17,
        backgroundColor: AppColors.secondary,
        child: Icon(
          Icons.arrow_upward_rounded,
          size: 19,
          color: AppColors.primary,
        ),
      ),
      const SizedBox(width: 9),
      Text(
        'FindJob',
        style: TextStyle(
          color: AppColors.primary,
          fontSize: 22,
          fontWeight: FontWeight.w700,
        ),
      ),
    ],
  );
}

TextStyle findJobHeadline(BuildContext context, double size) =>
    Theme.of(context).textTheme.headlineMedium!.copyWith(
      fontFamily: 'Lora',
      fontFamilyFallback: const ['serif'],
      fontSize: size,
      fontWeight: FontWeight.w400,
      letterSpacing: -0.55,
      height: 1.15,
      color: AppColors.ink,
    );
