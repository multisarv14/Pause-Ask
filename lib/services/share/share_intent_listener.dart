import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';

import '../../core/constants/app_constants.dart';
import '../../core/router/app_router.dart';
import '../../core/router/startup_guard.dart';
import '../../features/check/check_models.dart';

/// Something shared into PauseAsk from another app.
sealed class SharedPayload {
  const SharedPayload();
}

class SharedText extends SharedPayload {
  const SharedText(this.text);
  final String text;
}

class SharedImage extends SharedPayload {
  const SharedImage(this.path);
  final String path;
}

/// Picks the first usable item from a share.
SharedPayload? payloadFrom(List<SharedMediaFile> files) {
  for (final f in files) {
    if (f.type == SharedMediaType.image) return SharedImage(f.path);
  }
  final text = files
      .where(
        (f) => f.type == SharedMediaType.text || f.type == SharedMediaType.url,
      )
      .map((f) => f.path.trim())
      .where((t) => t.isNotEmpty)
      .join('\n');
  return text.isEmpty ? null : SharedText(text);
}

/// Holds a share until the user is signed in with a profile.
final pendingShareProvider = NotifierProvider<PendingShare, SharedPayload?>(
  PendingShare.new,
);

class PendingShare extends Notifier<SharedPayload?> {
  @override
  SharedPayload? build() => null;

  void set(SharedPayload? payload) => state = payload;
}

/// Listens for Android share intents and opens the check flow:
/// text → straight to checking, image → OCR + confirm.
class ShareIntentListener extends ConsumerStatefulWidget {
  const ShareIntentListener({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<ShareIntentListener> createState() =>
      _ShareIntentListenerState();
}

class _ShareIntentListenerState extends ConsumerState<ShareIntentListener> {
  StreamSubscription<List<SharedMediaFile>>? _sub;

  @override
  void initState() {
    super.initState();
    if (kIsWeb || !(Platform.isAndroid || Platform.isIOS)) return;
    final sharing = ReceiveSharingIntent.instance;
    // App already running: shares arrive on the stream.
    _sub = sharing.getMediaStream().listen(_onShared, onError: (_) {});
    // App cold-started from the share sheet.
    sharing.getInitialMedia().then((files) {
      _onShared(files);
      sharing.reset();
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  void _onShared(List<SharedMediaFile> files) {
    final payload = payloadFrom(files);
    if (payload == null) return;
    ref.read(pendingShareProvider.notifier).set(payload);
    _deliverIfReady();
  }

  void _deliverIfReady() {
    final payload = ref.read(pendingShareProvider);
    if (payload == null) return;
    if (ref.read(startupStepProvider) != StartupStep.ready) return;
    ref.read(pendingShareProvider.notifier).set(null);

    final router = ref.read(appRouterProvider);
    switch (payload) {
      case SharedImage(:final path):
        router.push(AppRoutes.checkOcr, extra: path);
      case SharedText(:final text)
          when text.length <= AppConstants.maxCheckTextLength:
        router.push(
          AppRoutes.checkRun,
          extra: CheckDraft(text: text, source: CheckSource.share),
        );
      case SharedText(:final text):
        // Too long: let the user trim it first.
        router.push(
          AppRoutes.check,
          extra: CheckDraft(text: text, source: CheckSource.share),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Deliver a waiting share as soon as login/profile setup finishes.
    ref.listen(startupStepProvider, (_, _) => _deliverIfReady());
    return widget.child;
  }
}
