import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/widgets/error_text.dart';
import '../../l10n/app_localizations.dart';
import '../profile/profile_repository.dart';
import 'checkin_models.dart';
import 'checkin_repository.dart';
import 'reminder_service.dart';

/// Protected user: daily "I'm OK" on/off, reminder time, alert-after hours.
class CheckinSettingsScreen extends ConsumerStatefulWidget {
  const CheckinSettingsScreen({super.key});

  @override
  ConsumerState<CheckinSettingsScreen> createState() =>
      _CheckinSettingsScreenState();
}

class _CheckinSettingsScreenState extends ConsumerState<CheckinSettingsScreen> {
  CheckinSettings? _draft;
  bool _saving = false;
  bool _failed = false;

  Future<void> _pickTime(CheckinSettings s) async {
    final picked = await showTimePicker(context: context, initialTime: s.time);
    if (picked != null) setState(() => _draft = s.copyWith(time: picked));
  }

  Future<void> _save(CheckinSettings s) async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    setState(() {
      _saving = true;
      _failed = false;
    });
    try {
      final zone = await initDeviceTimeZone();
      final toSave = s.copyWith(timezone: zone);
      await ref.read(checkinRepositoryProvider).save(toSave);
      await syncCheckinReminder(toSave, l10n).catchError((_) {});
      messenger.showSnackBar(SnackBar(content: Text(l10n.saved)));
    } catch (_) {
      if (mounted) setState(() => _failed = true);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final saved = ref.watch(userProfileProvider).value?.checkin;
    final s = _draft ?? saved ?? CheckinSettings.defaults;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.checkinTitle)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(l10n.checkinExplain, style: textTheme.bodyLarge),
            const SizedBox(height: 16),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(l10n.checkinEnabled, style: textTheme.titleMedium),
              value: s.enabled,
              onChanged: (v) => setState(() => _draft = s.copyWith(enabled: v)),
            ),
            const Divider(),
            ListTile(
              contentPadding: EdgeInsets.zero,
              enabled: s.enabled,
              title: Text(l10n.checkinTime, style: textTheme.titleMedium),
              trailing: Text(
                s.time.format(context),
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              onTap: s.enabled ? () => _pickTime(s) : null,
            ),
            const Divider(),
            Text(l10n.checkinAlertAfter, style: textTheme.titleMedium),
            const SizedBox(height: 8),
            DropdownButtonFormField<int>(
              initialValue: s.alertAfterHours,
              isExpanded: true,
              decoration: const InputDecoration(border: OutlineInputBorder()),
              items: [
                for (final h in {
                  ...CheckinSettings.alertAfterChoices,
                  s.alertAfterHours,
                }.toList()..sort())
                  DropdownMenuItem(value: h, child: Text(l10n.hoursCount(h))),
              ],
              onChanged: s.enabled
                  ? (v) =>
                        setState(() => _draft = s.copyWith(alertAfterHours: v))
                  : null,
            ),
            const SizedBox(height: 12),
            Text(l10n.checkinChangeNote, style: textTheme.bodyMedium),
            if (_failed) ...[
              const SizedBox(height: 12),
              ErrorText(l10n.errorGeneric),
            ],
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _saving ? null : () => _save(s),
              child: _saving
                  ? const SizedBox.square(
                      dimension: 24,
                      child: CircularProgressIndicator(strokeWidth: 3),
                    )
                  : Text(l10n.saveButton),
            ),
          ],
        ),
      ),
    );
  }
}
