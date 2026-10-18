import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/storage/preferences.dart';
import '../../core/theme/app_colors.dart';
import '../../l10n/app_localizations.dart';
import '../profile/profile_repository.dart';
import 'checkin_models.dart';
import 'checkin_repository.dart';

/// Protected Home: "Your family knows you're OK today (9:12)" or an
/// "I'm OK 👍" button. Hidden when daily check-in is off.
class MyCheckinCard extends ConsumerStatefulWidget {
  const MyCheckinCard({super.key});

  @override
  ConsumerState<MyCheckinCard> createState() => _MyCheckinCardState();
}

class _MyCheckinCardState extends ConsumerState<MyCheckinCard> {
  bool _busy = false;

  Future<void> _checkIn() async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _busy = true);
    try {
      await ref.read(checkinRepositoryProvider).checkIn();
      await ref
          .read(sharedPreferencesProvider)
          .setInt(
            PrefKeys.lastAppCheckinMs,
            DateTime.now().millisecondsSinceEpoch,
          );
      messenger.showSnackBar(SnackBar(content: Text(l10n.checkinThanks)));
    } catch (_) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.errorGeneric)));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final settings = ref.watch(userProfileProvider).value?.checkin;
    if (settings == null || !settings.enabled) return const SizedBox.shrink();
    final (:status, :okAt) = checkinStatus(settings);
    final done = status == CheckinStatus.ok;
    final color = done ? AppColors.guardianOk : AppColors.primary;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(
                done ? Icons.check_circle : Icons.wb_sunny_outlined,
                color: color,
                size: 32,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Semantics(
                  liveRegion: true,
                  child: Text(
                    done
                        ? l10n.checkinDoneToday(
                            DateFormat.jm(
                              Localizations.localeOf(context).toString(),
                            ).format(okAt!),
                          )
                        : l10n.checkinNotYetToday,
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (!done) ...[
            const SizedBox(height: 10),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.guardianOk,
              ),
              onPressed: _busy ? null : _checkIn,
              child: Text(l10n.imOkButton),
            ),
          ],
        ],
      ),
    );
  }
}
