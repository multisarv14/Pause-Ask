import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n/language_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/text_scale_provider.dart';
import '../../l10n/app_localizations.dart';
import '../auth/auth_providers.dart';
import '../onboarding/onboarding_providers.dart';
import 'profile_repository.dart';
import 'user_profile.dart';

/// Name + role, saved to `users/{uid}`.
class ProfileSetupScreen extends ConsumerStatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  ConsumerState<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends ConsumerState<ProfileSetupScreen> {
  static const _maxNameLength = 50;
  final _name = TextEditingController();
  RoleChoice? _role;
  bool _submitted = false;
  bool _saving = false;
  bool _saveFailed = false;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _submitted = true);
    final name = _name.text.trim();
    final role = _role;
    final user = ref.read(authStateProvider).value;
    final consent = ref.read(consentProvider);
    if (name.isEmpty || role == null || user == null || consent == null) return;

    setState(() {
      _saving = true;
      _saveFailed = false;
    });
    try {
      // The profile stream then fires and the router moves to Home.
      await ref
          .read(profileRepositoryProvider)
          .create(
            uid: user.uid,
            name: name,
            phone: user.phoneNumber ?? '',
            roles: role.roles,
            language: ref.read(languageProvider) ?? 'en',
            largeText: ref.read(largeTextProvider),
            consentVersion: consent.version,
            consentAcceptedAt: consent.acceptedAt,
          );
    } catch (_) {
      if (mounted) setState(() => _saveFailed = true);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final errorColor = Theme.of(context).colorScheme.error;
    final options = [
      (
        RoleChoice.protected,
        Icons.shield_outlined,
        l10n.roleProtected,
        l10n.roleProtectedHint,
      ),
      (
        RoleChoice.guardian,
        Icons.volunteer_activism_outlined,
        l10n.roleGuardian,
        l10n.roleGuardianHint,
      ),
      (
        RoleChoice.both,
        Icons.family_restroom,
        l10n.roleBoth,
        l10n.roleBothHint,
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.profileTitle),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            TextField(
              controller: _name,
              textCapitalization: TextCapitalization.words,
              autofillHints: const [AutofillHints.name],
              maxLength: _maxNameLength,
              style: textTheme.titleLarge,
              decoration: InputDecoration(
                labelText: l10n.nameLabel,
                border: const OutlineInputBorder(),
                errorText: _submitted && _name.text.trim().isEmpty
                    ? l10n.nameRequired
                    : null,
              ),
              onChanged: (_) {
                if (_submitted) setState(() {});
              },
            ),
            const SizedBox(height: 16),
            Text(
              l10n.roleQuestion,
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            RadioGroup<RoleChoice>(
              groupValue: _role,
              onChanged: (v) => setState(() => _role = v),
              child: Column(
                children: [
                  for (final (choice, icon, title, hint) in options)
                    _RoleCard(
                      value: choice,
                      selected: _role == choice,
                      icon: icon,
                      title: title,
                      hint: hint,
                      onTap: () => setState(() => _role = choice),
                    ),
                ],
              ),
            ),
            if (_submitted && _role == null)
              Text(
                l10n.roleRequired,
                style: TextStyle(
                  color: errorColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            if (_saveFailed)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  l10n.errorGeneric,
                  style: TextStyle(
                    color: errorColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _saving ? null : _save,
              child: _saving
                  ? const SizedBox.square(
                      dimension: 24,
                      child: CircularProgressIndicator(strokeWidth: 3),
                    )
                  : Text(l10n.continueButton),
            ),
          ],
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  const _RoleCard({
    required this.value,
    required this.selected,
    required this.icon,
    required this.title,
    required this.hint,
    required this.onTap,
  });

  final RoleChoice value;
  final bool selected;
  final IconData icon;
  final String title;
  final String hint;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: selected ? AppColors.primary : Colors.black26,
          width: selected ? 3 : 1,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(icon, size: 40, color: AppColors.primary),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(hint, style: textTheme.bodyMedium),
                  ],
                ),
              ),
              Radio<RoleChoice>(value: value),
            ],
          ),
        ),
      ),
    );
  }
}
