import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/theme/app_colors.dart';
import '../../l10n/app_localizations.dart';
import '../circle/circle_models.dart';
import 'checkin_models.dart';

/// Opens the dialer; false if there is no number or no dialer.
Future<bool> dialNumber(String phone) async {
  if (phone.isEmpty) return false;
  try {
    return await launchUrl(Uri(scheme: 'tel', path: phone));
  } catch (_) {
    return false;
  }
}

/// Guardian Home: 🟢 OK today at 9:12 / ⚪ Not yet / 🔴 Missed, with Call.
class MemberStatusCard extends StatelessWidget {
  const MemberStatusCard({super.key, required this.member, this.now});

  final CircleMember member;
  final DateTime? now;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final (:status, :okAt) = checkinStatus(member.checkin, now: now);
    final locale = Localizations.localeOf(context).toString();
    final (Color color, String emoji, String text) = switch (status) {
      CheckinStatus.ok => (
        AppColors.guardianOk,
        '🟢',
        l10n.statusOkAt(DateFormat.jm(locale).format(okAt!)),
      ),
      CheckinStatus.missed => (AppColors.riskHigh, '🔴', l10n.statusMissed),
      CheckinStatus.notYet => (Colors.black45, '⚪', l10n.statusNotYet),
      CheckinStatus.off => (Colors.black45, '⚪', l10n.statusOff),
    };

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: color, width: 2),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
        child: Row(
          children: [
            ExcludeSemantics(
              child: Text(emoji, style: const TextStyle(fontSize: 28)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    member.name,
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(text, style: textTheme.bodyLarge),
                ],
              ),
            ),
            IconButton.filled(
              tooltip: '${l10n.callButton} ${member.name}',
              constraints: const BoxConstraints(minWidth: 56, minHeight: 56),
              style: IconButton.styleFrom(backgroundColor: AppColors.primary),
              onPressed: member.phone.isEmpty
                  ? null
                  : () async {
                      final messenger = ScaffoldMessenger.of(context);
                      if (!await dialNumber(member.phone)) {
                        messenger.showSnackBar(
                          SnackBar(content: Text(l10n.noPhone)),
                        );
                      }
                    },
              icon: const Icon(Icons.phone, color: AppColors.onPrimary),
            ),
          ],
        ),
      ),
    );
  }
}
