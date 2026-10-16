import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_routes.dart';
import '../../core/widgets/error_text.dart';
import '../../l10n/app_localizations.dart';
import 'auth_error.dart';
import 'phone_auth_controller.dart';

/// Builds an E.164 number from the two fields, or null if it looks invalid.
String? toE164(String countryCode, String number) {
  final cc = countryCode.trim().replaceAll(' ', '');
  final digits = number.replaceAll(RegExp(r'[\s\-()]'), '');
  if (!RegExp(r'^\+[1-9]\d{0,3}$').hasMatch(cc)) return null;
  if (!RegExp(r'^\d{6,14}$').hasMatch(digits)) return null;
  return '$cc$digits';
}

class PhoneLoginScreen extends ConsumerStatefulWidget {
  const PhoneLoginScreen({super.key});

  @override
  ConsumerState<PhoneLoginScreen> createState() => _PhoneLoginScreenState();
}

class _PhoneLoginScreenState extends ConsumerState<PhoneLoginScreen> {
  final _countryCode = TextEditingController(text: '+91');
  final _number = TextEditingController();
  bool _invalidNumber = false;

  @override
  void dispose() {
    _countryCode.dispose();
    _number.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final phone = toE164(_countryCode.text, _number.text);
    setState(() => _invalidNumber = phone == null);
    if (phone == null) return;

    final sent = await ref
        .read(phoneAuthControllerProvider.notifier)
        .sendCode(phone);
    if (sent && mounted) context.push(AppRoutes.otp);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final auth = ref.watch(phoneAuthControllerProvider);
    final error = _invalidNumber ? AuthError.invalidPhone : auth.error;

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            const SizedBox(height: 24),
            const Icon(Icons.phone_android, size: 64),
            const SizedBox(height: 16),
            Text(
              l10n.loginTitle,
              textAlign: TextAlign.center,
              style: textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(l10n.loginSubtitle, textAlign: TextAlign.center),
            const SizedBox(height: 32),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 110,
                  child: TextField(
                    controller: _countryCode,
                    keyboardType: TextInputType.phone,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[+\d]')),
                      LengthLimitingTextInputFormatter(5),
                    ],
                    style: textTheme.titleLarge,
                    decoration: InputDecoration(
                      labelText: l10n.countryCodeLabel,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _number,
                    autofocus: true,
                    keyboardType: TextInputType.phone,
                    autofillHints: const [
                      AutofillHints.telephoneNumberNational,
                    ],
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[\d\s\-]')),
                      LengthLimitingTextInputFormatter(18),
                    ],
                    style: textTheme.titleLarge,
                    decoration: InputDecoration(
                      labelText: l10n.phoneLabel,
                      border: const OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _send(),
                  ),
                ),
              ],
            ),
            if (error != null) ...[
              const SizedBox(height: 16),
              ErrorText(error.message(l10n)),
            ],
            const SizedBox(height: 24),
            FilledButton(
              onPressed: auth.busy ? null : _send,
              child: auth.busy
                  ? const SizedBox.square(
                      dimension: 24,
                      child: CircularProgressIndicator(strokeWidth: 3),
                    )
                  : Text(l10n.sendCode),
            ),
          ],
        ),
      ),
    );
  }
}
