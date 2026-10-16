import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/app_localizations.dart';
import 'phone_auth_controller.dart';

/// 6-digit SMS code entry. On Android the code is auto-filled when the
/// SMS is retrieved; the keyboard also offers it via the one-time-code hint.
class OtpScreen extends ConsumerStatefulWidget {
  const OtpScreen({super.key});

  @override
  ConsumerState<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends ConsumerState<OtpScreen> {
  static const _resendAfter = Duration(seconds: 30);
  final _code = TextEditingController();
  Timer? _ticker;
  int _secondsLeft = 0;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _code.dispose();
    super.dispose();
  }

  void _startCountdown() {
    _ticker?.cancel();
    setState(() => _secondsLeft = _resendAfter.inSeconds);
    _ticker = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_secondsLeft <= 1) t.cancel();
      setState(() => _secondsLeft--);
    });
  }

  // On success the router leaves this screen by itself.
  Future<void> _verify() async {
    if (_code.text.length != 6) return;
    await ref.read(phoneAuthControllerProvider.notifier).verifyCode(_code.text);
  }

  Future<void> _resend() async {
    final controller = ref.read(phoneAuthControllerProvider.notifier);
    final phone = ref.read(phoneAuthControllerProvider).phone;
    if (phone == null) return;
    _code.clear();
    if (await controller.sendCode(phone, resend: true) && mounted) {
      _startCountdown();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final auth = ref.watch(phoneAuthControllerProvider);

    ref.listen(phoneAuthControllerProvider.select((s) => s.autoFilledCode), (
      _,
      code,
    ) {
      if (code != null) _code.text = code;
    });

    return Scaffold(
      appBar: AppBar(title: Text(l10n.otpTitle)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Text(
              l10n.otpSentTo(auth.phone ?? ''),
              textAlign: TextAlign.center,
              style: textTheme.titleMedium,
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _code,
              autofocus: true,
              keyboardType: TextInputType.number,
              autofillHints: const [AutofillHints.oneTimeCode],
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(6),
              ],
              textAlign: TextAlign.center,
              style: textTheme.headlineMedium?.copyWith(letterSpacing: 12),
              decoration: InputDecoration(
                labelText: l10n.otpLabel,
                border: const OutlineInputBorder(),
                errorText: auth.error?.message(l10n),
                errorMaxLines: 3,
              ),
              onChanged: (v) {
                if (v.length == 6) _verify();
              },
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: auth.busy ? null : _verify,
              child: auth.busy
                  ? const SizedBox.square(
                      dimension: 24,
                      child: CircularProgressIndicator(strokeWidth: 3),
                    )
                  : Text(l10n.verify),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: _secondsLeft > 0 || auth.busy ? null : _resend,
              child: Text(
                _secondsLeft > 0
                    ? l10n.resendIn(_secondsLeft)
                    : l10n.resendCode,
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: auth.busy ? null : () => context.pop(),
              child: Text(l10n.changeNumber),
            ),
          ],
        ),
      ),
    );
  }
}
