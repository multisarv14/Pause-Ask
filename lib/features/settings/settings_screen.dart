import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/constants/app_constants.dart';
import '../../core/l10n/language_provider.dart';
import '../../core/router/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/text_scale_provider.dart';
import '../../l10n/app_localizations.dart';
import '../auth/phone_auth_controller.dart';
import '../legal/legal_content.dart';
import '../profile/profile_repository.dart';
import '../profile/user_profile.dart';
import 'account_repository.dart';

final appVersionProvider = FutureProvider<String>((ref) async {
  final info = await PackageInfo.fromPlatform();
  return '${info.version} (${info.buildNumber})';
});

RoleChoice? roleChoiceOf(UserProfile? p) => p == null
    ? null
    : p.isProtected && p.isGuardian
    ? RoleChoice.both
    : p.isGuardian
    ? RoleChoice.guardian
    : RoleChoice.protected;

/// Everything adjustable in one place, grouped for older users.
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  RoleChoice? _savingRole;
  bool _sendingTest = false;

  void _snack(String text) => ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(text)));

  Future<void> _changeRole(RoleChoice choice) async {
    final l10n = AppLocalizations.of(context);
    setState(() => _savingRole = choice);
    try {
      await ref.read(accountRepositoryProvider).updateRoles(choice);
      _snack(l10n.rolesSaved);
    } catch (_) {
      _snack(l10n.errorGeneric);
    } finally {
      if (mounted) setState(() => _savingRole = null);
    }
  }

  Future<void> _testAlert() async {
    final l10n = AppLocalizations.of(context);
    setState(() => _sendingTest = true);
    try {
      final sent = await ref.read(accountRepositoryProvider).sendTestAlert();
      _snack(sent ? l10n.testAlertSent : l10n.testAlertNoDevice);
    } catch (_) {
      _snack(l10n.errorGeneric);
    } finally {
      if (mounted) setState(() => _sendingTest = false);
    }
  }

  Future<void> _contactSupport() async {
    final l10n = AppLocalizations.of(context);
    const email = AppConstants.supportEmail;
    final version = ref.read(appVersionProvider).value ?? '';
    final uri = Uri(
      scheme: 'mailto',
      path: email,
      query:
          'subject=${Uri.encodeComponent('PauseAsk help')}'
          '&body=${Uri.encodeComponent('\n\n—\nPauseAsk $version')}',
    );
    var opened = false;
    try {
      opened = await launchUrl(uri);
    } catch (_) {}
    if (!opened) _snack(l10n.noEmailApp(email));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final profile = ref.watch(userProfileProvider).value;
    final role = _savingRole ?? roleChoiceOf(profile);
    final languageCode = ref.watch(languageProvider) ?? 'en';
    final version = ref.watch(appVersionProvider).value;

    Widget header(String text) => Padding(
      padding: const EdgeInsets.fromLTRB(4, 24, 4, 8),
      child: Semantics(
        header: true,
        child: Text(
          text,
          style: textTheme.titleMedium?.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
    Widget tile(
      IconData icon,
      String title,
      VoidCallback? onTap, {
      String? subtitle,
    }) => ListTile(
      leading: Icon(icon, size: 28),
      title: Text(title),
      subtitle: subtitle == null ? null : Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsTitle)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 32),
          children: [
            header(l10n.settingsGeneral),
            tile(
              Icons.translate,
              l10n.changeLanguage,
              () => context.push(AppRoutes.language),
              subtitle: supportedLanguages[languageCode],
            ),
            SwitchListTile(
              secondary: const Icon(Icons.text_increase, size: 28),
              value: ref.watch(largeTextProvider),
              onChanged: (v) {
                ref.read(largeTextProvider.notifier).set(v);
                if (profile != null) {
                  ref
                      .read(profileRepositoryProvider)
                      .updatePreferences(profile.uid, largeText: v)
                      .ignore();
                }
              },
              title: Text(l10n.largeText),
              subtitle: Text(l10n.largeTextHint),
            ),
            header(l10n.rolesTitle),
            RadioGroup<RoleChoice>(
              groupValue: role,
              onChanged: (c) {
                if (c != null &&
                    c != roleChoiceOf(profile) &&
                    _savingRole == null) {
                  _changeRole(c);
                }
              },
              child: Column(
                children: [
                  for (final (c, label) in [
                    (RoleChoice.protected, l10n.roleProtected),
                    (RoleChoice.guardian, l10n.roleGuardian),
                    (RoleChoice.both, l10n.roleBoth),
                  ])
                    RadioListTile<RoleChoice>(value: c, title: Text(label)),
                ],
              ),
            ),
            header(l10n.settingsFamily),
            tile(
              Icons.family_restroom,
              l10n.myCircle,
              () => context.push(AppRoutes.circle),
            ),
            if (profile?.isProtected ?? false)
              tile(
                Icons.wb_sunny_outlined,
                l10n.checkinTitle,
                () => context.push(AppRoutes.checkinSettings),
              ),
            tile(
              Icons.notifications_active_outlined,
              l10n.testAlert,
              _sendingTest ? null : _testAlert,
            ),
            tile(
              Icons.battery_alert,
              l10n.notificationHelp,
              () => context.push(AppRoutes.batteryGuide),
            ),
            header(l10n.settingsHelp),
            tile(
              Icons.help_outline,
              l10n.helpFaq,
              () => context.push(AppRoutes.legal(LegalDoc.faq)),
            ),
            tile(
              Icons.privacy_tip_outlined,
              l10n.privacyPolicy,
              () => context.push(AppRoutes.legal(LegalDoc.privacy)),
            ),
            tile(
              Icons.description_outlined,
              l10n.termsTitle,
              () => context.push(AppRoutes.legal(LegalDoc.terms)),
            ),
            // Hidden until the owner sets AppConstants.supportEmail.
            if (AppConstants.supportEmail.isNotEmpty)
              tile(
                Icons.mail_outline,
                l10n.contactSupport,
                _contactSupport,
                subtitle: AppConstants.supportEmail,
              ),
            header(l10n.settingsAccount),
            tile(
              Icons.logout,
              l10n.logout,
              () => ref.read(phoneAuthControllerProvider.notifier).signOut(),
            ),
            ListTile(
              leading: const Icon(
                Icons.delete_forever,
                size: 28,
                color: AppColors.riskHigh,
              ),
              title: Text(
                l10n.deleteAccount,
                style: const TextStyle(
                  color: AppColors.riskHigh,
                  fontWeight: FontWeight.w700,
                ),
              ),
              onTap: () => context.push(AppRoutes.deleteAccount),
            ),
            // Debug builds only: force an error to see the friendly screen.
            if (kDebugMode)
              tile(
                Icons.bug_report_outlined,
                'Crash test (debug)',
                () => context.push(AppRoutes.crashTest),
              ),
            if (version != null)
              Padding(
                padding: const EdgeInsets.only(top: 24),
                child: Text(
                  l10n.appVersion(version),
                  textAlign: TextAlign.center,
                  style: textTheme.bodyMedium,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
