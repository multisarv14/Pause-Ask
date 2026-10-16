import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../l10n/app_localizations.dart';
import 'onboarding_providers.dart';

/// Three explainer slides with big Next / Skip buttons.
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  static const _slideCount = 3;
  final _controller = PageController();
  int _page = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // The router moves on to the privacy screen once this is saved.
  void _finish() => ref.read(onboardingDoneProvider.notifier).complete();

  void _next() {
    if (_page == _slideCount - 1) {
      _finish();
    } else {
      _controller.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final slides = [
      (
        Icons.pan_tool_outlined,
        l10n.onboardingSlide1Title,
        l10n.onboardingSlide1Body,
      ),
      (
        Icons.family_restroom,
        l10n.onboardingSlide2Title,
        l10n.onboardingSlide2Body,
      ),
      (
        Icons.wb_sunny_outlined,
        l10n.onboardingSlide3Title,
        l10n.onboardingSlide3Body,
      ),
    ];
    final isLast = _page == _slideCount - 1;

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: TextButton(onPressed: _finish, child: Text(l10n.skip)),
              ),
            ),
            Expanded(
              child: PageView(
                controller: _controller,
                onPageChanged: (i) => setState(() => _page = i),
                children: [
                  for (final (icon, title, body) in slides)
                    _Slide(icon: icon, title: title, body: body),
                ],
              ),
            ),
            _Dots(count: _slideCount, active: _page),
            Padding(
              padding: const EdgeInsets.all(24),
              child: FilledButton(
                onPressed: _next,
                child: Text(isLast ? l10n.getStarted : l10n.next),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Slide extends StatelessWidget {
  const _Slide({required this.icon, required this.title, required this.body});

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
      child: Column(
        children: [
          Icon(icon, size: 120, color: AppColors.primary),
          const SizedBox(height: 32),
          Text(
            title,
            textAlign: TextAlign.center,
            style: textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          Text(body, textAlign: TextAlign.center, style: textTheme.bodyLarge),
        ],
      ),
    );
  }
}

class _Dots extends StatelessWidget {
  const _Dots({required this.count, required this.active});

  final int count;
  final int active;

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 0; i < count; i++)
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.symmetric(horizontal: 6),
            width: i == active ? 28 : 12,
            height: 12,
            decoration: BoxDecoration(
              color: i == active
                  ? AppColors.primary
                  : AppColors.primary.withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(6),
            ),
          ),
      ],
    ),
  );
}
