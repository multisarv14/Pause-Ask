import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../l10n/app_localizations.dart';
import '../checkin/member_status_card.dart';
import '../circle/circle_repository.dart';
import '../profile/profile_repository.dart';
import 'sos_repository.dart';

/// Indian numbers get the national cyber-crime helpline button.
bool isIndianNumber(String phone) =>
    phone.replaceAll(' ', '').startsWith('+91');

/// After SOS: "Your family has been alerted", call first guardian, 1930.
class SosSentScreen extends ConsumerWidget {
  const SosSentScreen({super.key, required this.result});

  final SosResult result;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final phone = ref.watch(userProfileProvider).value?.phone ?? '';
    final guardian = result.firstGuardian;
    final alerted = result.guardianCount > 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('SOS'),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Icon(
              alerted ? Icons.check_circle : Icons.warning_amber_rounded,
              size: 96,
              color: alerted ? AppColors.guardianOk : AppColors.riskHigh,
            ),
            const SizedBox(height: 16),
            Semantics(
              liveRegion: true,
              header: true,
              child: Text(
                alerted ? l10n.sosAlerted : l10n.sosNoGuardian,
                textAlign: TextAlign.center,
                style: textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(height: 28),
            if (guardian != null && guardian.phone.isNotEmpty) ...[
              _CallButton(
                label: l10n.sosCallGuardian(guardian.name),
                phone: guardian.phone,
                color: AppColors.primary,
              ),
              const SizedBox(height: 16),
            ],
            if (isIndianNumber(phone)) ...[
              _CallButton(
                label: l10n.sosCall1930,
                phone: '1930',
                color: AppColors.riskHigh,
              ),
              const SizedBox(height: 8),
              Text(l10n.sos1930Explain, style: textTheme.bodyLarge),
              const SizedBox(height: 16),
            ],
            OutlinedButton(
              onPressed: () => context.go(AppRoutes.home),
              child: Text(l10n.done),
            ),
          ],
        ),
      ),
    );
  }
}

class _CallButton extends StatelessWidget {
  const _CallButton({
    required this.label,
    required this.phone,
    required this.color,
  });

  final String label;
  final String phone;
  final Color color;

  @override
  Widget build(BuildContext context) => ConstrainedBox(
    constraints: const BoxConstraints(minHeight: 72),
    child: FilledButton.icon(
      style: FilledButton.styleFrom(backgroundColor: color),
      onPressed: () async {
        final messenger = ScaffoldMessenger.of(context);
        final noPhone = AppLocalizations.of(context).noPhone;
        if (!await dialNumber(phone)) {
          messenger.showSnackBar(SnackBar(content: Text(noPhone)));
        }
      },
      icon: const Icon(Icons.phone, size: 32),
      label: Text(label, textAlign: TextAlign.center),
    ),
  );
}

/// Guardian side, opened from the SOS push: big "Call" for that member.
class SosAlertScreen extends ConsumerWidget {
  const SosAlertScreen({super.key, required this.memberUid});

  final String memberUid;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final circle = ref.watch(myCircleProvider).value;
    final members = circle == null
        ? const []
        : ref.watch(circleMembersProvider(circle.id)).value ?? const [];
    final member = members.where((m) => m.uid == memberUid).firstOrNull;
    final name = member?.name ?? '…';

    return Scaffold(
      backgroundColor: AppColors.riskHigh,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(28),
          children: [
            const SizedBox(height: 24),
            const Icon(Icons.sos, size: 120, color: AppColors.onRiskHigh),
            const SizedBox(height: 16),
            Semantics(
              header: true,
              liveRegion: true,
              child: Text(
                l10n.sosAlertTitle(name),
                textAlign: TextAlign.center,
                style: textTheme.headlineMedium?.copyWith(
                  color: AppColors.onRiskHigh,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.sosAlertBody(name),
              textAlign: TextAlign.center,
              style: textTheme.titleLarge?.copyWith(
                color: AppColors.onRiskHigh,
              ),
            ),
            const SizedBox(height: 40),
            if (member != null && member.phone.isNotEmpty)
              _CallButton(
                label: '${l10n.callButton} $name',
                phone: member.phone,
                color: AppColors.primary,
              ),
            const SizedBox(height: 16),
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.onRiskHigh,
                side: const BorderSide(color: AppColors.onRiskHigh, width: 2),
              ),
              onPressed: () => context.go(AppRoutes.home),
              child: Text(l10n.closeButton),
            ),
          ],
        ),
      ),
    );
  }
}
