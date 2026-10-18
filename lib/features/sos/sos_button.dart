import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../l10n/app_localizations.dart';
import 'sos_repository.dart';

/// Red "I need help now". Must be held for [holdFor]; a quick tap only
/// shows the hint. The fill shows progress while holding.
class SosButton extends ConsumerStatefulWidget {
  const SosButton({super.key, this.holdFor = const Duration(seconds: 2)});

  final Duration holdFor;

  @override
  ConsumerState<SosButton> createState() => _SosButtonState();
}

class _SosButtonState extends ConsumerState<SosButton>
    with SingleTickerProviderStateMixin {
  late final _hold = AnimationController(vsync: this, duration: widget.holdFor)
    ..addStatusListener((s) {
      if (s == AnimationStatus.completed) _send();
    });
  bool _sending = false;

  @override
  void dispose() {
    _hold.dispose();
    super.dispose();
  }

  void _start() {
    if (_sending) return;
    HapticFeedback.mediumImpact();
    _hold.forward(from: 0);
  }

  void _cancel() {
    if (_hold.isCompleted || _sending) return;
    if (_hold.value < 1) {
      _hold.reverse();
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context).sosHoldHint)),
        );
    }
  }

  Future<void> _send() async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final router = GoRouter.of(context);
    HapticFeedback.heavyImpact();
    setState(() => _sending = true);
    try {
      final result = await ref.read(sosRepositoryProvider).send();
      router.push(AppRoutes.sosSent, extra: result);
    } on SosError catch (e) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(e == SosError.limit ? l10n.sosLimit : l10n.sosFailed),
          duration: const Duration(seconds: 8),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _sending = false);
        _hold.value = 0;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;

    return Semantics(
      button: true,
      label: l10n.sosButton,
      hint: l10n.sosHoldHint,
      excludeSemantics: true,
      // Screen-reader users double-tap-and-hold, which is a long press.
      onLongPress: _send,
      child: GestureDetector(
        onTapDown: (_) => _start(),
        onTapUp: (_) => _cancel(),
        onTapCancel: _cancel,
        child: AnimatedBuilder(
          animation: _hold,
          builder: (context, _) => Container(
            constraints: const BoxConstraints(minHeight: 88),
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: AppColors.riskHigh,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Stack(
              children: [
                Positioned.fill(
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: _hold.value,
                    child: const ColoredBox(color: Color(0xFF7F0000)),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _sending
                          ? const SizedBox.square(
                              dimension: 32,
                              child: CircularProgressIndicator(
                                color: AppColors.onRiskHigh,
                                strokeWidth: 3,
                              ),
                            )
                          : const Icon(
                              Icons.sos,
                              size: 40,
                              color: AppColors.onRiskHigh,
                            ),
                      const SizedBox(width: 12),
                      Flexible(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _sending ? l10n.sosSending : l10n.sosButton,
                              style: textTheme.titleLarge?.copyWith(
                                color: AppColors.onRiskHigh,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            Text(
                              l10n.sosHoldHint,
                              style: textTheme.bodyMedium?.copyWith(
                                color: AppColors.onRiskHigh,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
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
