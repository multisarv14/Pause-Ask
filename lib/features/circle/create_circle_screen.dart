import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/widgets/error_text.dart';
import '../../l10n/app_localizations.dart';
import 'circle_error.dart';
import 'circle_repository.dart';

class CreateCircleScreen extends ConsumerStatefulWidget {
  const CreateCircleScreen({super.key});

  @override
  ConsumerState<CreateCircleScreen> createState() => _CreateCircleScreenState();
}

class _CreateCircleScreenState extends ConsumerState<CreateCircleScreen> {
  static const _maxNameLength = 40;
  final _name = TextEditingController();
  bool _busy = false;
  CircleError? _error;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _create() async {
    final name = _name.text.trim();
    if (name.isEmpty) {
      setState(() => _error = CircleError.invalidName);
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref.read(circleRepositoryProvider).createCircle(name);
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
      appBar: AppBar(title: Text(l10n.createCircle)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            TextField(
              controller: _name,
              autofocus: true,
              maxLength: _maxNameLength,
              textCapitalization: TextCapitalization.words,
              style: textTheme.titleLarge,
              decoration: InputDecoration(
                labelText: l10n.circleNameLabel,
                hintText: l10n.circleNameHint,
                border: const OutlineInputBorder(),
              ),
              onSubmitted: (_) => _create(),
            ),
            if (_error != null) ...[
              const SizedBox(height: 8),
              ErrorText(_error!.message(l10n)),
            ],
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _busy ? null : _create,
              child: _busy
                  ? const SizedBox.square(
                      dimension: 24,
                      child: CircularProgressIndicator(strokeWidth: 3),
                    )
                  : Text(l10n.createCircleButton),
            ),
          ],
        ),
      ),
    );
  }
}
