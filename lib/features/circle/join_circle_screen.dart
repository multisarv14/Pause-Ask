import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/widgets/error_text.dart';
import '../../l10n/app_localizations.dart';
import 'circle_error.dart';
import 'circle_repository.dart';
import 'invite_code.dart';

class JoinCircleScreen extends ConsumerStatefulWidget {
  const JoinCircleScreen({super.key});

  @override
  ConsumerState<JoinCircleScreen> createState() => _JoinCircleScreenState();
}

class _JoinCircleScreenState extends ConsumerState<JoinCircleScreen> {
  final _code = TextEditingController();
  bool _busy = false;
  CircleError? _error;

  @override
  void dispose() {
    _code.dispose();
    super.dispose();
  }

  Future<void> _join() async {
    final code = normalizeInviteCode(_code.text);
    if (code == null) {
      setState(() => _error = CircleError.invalidCode);
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref.read(circleRepositoryProvider).joinCircle(code);
      if (mounted) context.pop();
    } catch (e) {
      if (mounted) setState(() => _error = CircleError.from(e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.joinWithCode)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Text(l10n.joinCodeHelp, style: textTheme.bodyLarge),
            const SizedBox(height: 24),
            TextField(
              controller: _code,
              autofocus: true,
              textAlign: TextAlign.center,
              textCapitalization: TextCapitalization.characters,
              autocorrect: false,
              enableSuggestions: false,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9\s-]')),
                UpperCaseTextFormatter(),
                LengthLimitingTextInputFormatter(8),
              ],
              style: textTheme.headlineMedium?.copyWith(
                letterSpacing: 8,
                fontWeight: FontWeight.w700,
              ),
              decoration: InputDecoration(
                labelText: l10n.joinCodeLabel,
                border: const OutlineInputBorder(),
              ),
              onSubmitted: (_) => _join(),
            ),
            if (_error != null) ...[
              const SizedBox(height: 16),
              ErrorText(_error!.message(l10n)),
            ],
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _busy ? null : _join,
              child: _busy
                  ? const SizedBox.square(
                      dimension: 24,
                      child: CircularProgressIndicator(strokeWidth: 3),
                    )
                  : Text(l10n.joinButton),
            ),
          ],
        ),
      ),
    );
  }
}
