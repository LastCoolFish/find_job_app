import 'dart:async';
import 'package:flutter/material.dart';
import 'package:find_job_app/core/theme/AppColors.dart';
import 'package:find_job_app/core/widgets/FindJobArches.dart';

class LoadingIndicator extends StatelessWidget {
  const LoadingIndicator({super.key});

  @override
  Widget build(BuildContext context) =>
      const Center(child: CircularProgressIndicator());
}

class FindJobLoading extends StatefulWidget {
  const FindJobLoading({super.key, required this.message});

  final String message;

  @override
  State<FindJobLoading> createState() => _FindJobLoadingState();
}

class _FindJobLoadingState extends State<FindJobLoading>
    with SingleTickerProviderStateMixin {
  late final AnimationController _motion = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2400),
  );
  Timer? _timer;
  bool _waiting = false;

  @override
  void initState() {
    super.initState();
    _timer = Timer(
      const Duration(seconds: 3),
      () => setState(() => _waiting = true),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _motion.stop();
    } else if (!_motion.isAnimating) {
      _motion.repeat();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _motion.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => SafeArea(
    child: Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 326),
              child: AspectRatio(
                aspectRatio: 326 / 352,
                child: FindJobArches(progress: _motion),
              ),
            ),
            const SizedBox(height: 22),
            Semantics(
              liveRegion: true,
              child: AnimatedSwitcher(
                duration: MediaQuery.disableAnimationsOf(context)
                    ? Duration.zero
                    : const Duration(milliseconds: 200),
                child: Text(
                  _waiting ? 'Ждём ответ сервера' : widget.message,
                  key: ValueKey(_waiting),
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.primary, fontSize: 20),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
