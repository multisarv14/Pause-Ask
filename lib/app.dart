import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/l10n/language_provider.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/text_scale_provider.dart';
import 'core/widgets/app_keys.dart';
import 'l10n/app_localizations.dart';
import 'services/notifications/notification_service.dart';
import 'services/share/share_intent_listener.dart';

class PauseAskApp extends ConsumerWidget {
  const PauseAskApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final textScale = ref.watch(textScaleProvider);

    return MaterialApp.router(
      onGenerateTitle: (context) => AppLocalizations.of(context).appName,
      debugShowCheckedModeBanner: false,
      scaffoldMessengerKey: rootMessengerKey,
      theme: AppTheme.light(),
      locale: ref.watch(localeProvider),
      routerConfig: router,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      // Our "large text" setting multiplies the user's system text scale.
      builder: (context, child) {
        final mq = MediaQuery.of(context);
        final systemScale = mq.textScaler.scale(1);
        return ShareIntentListener(
          child: NotificationsBootstrap(
            child: MediaQuery(
              data: mq.copyWith(
                textScaler: TextScaler.linear(systemScale * textScale),
              ),
              child: child!,
            ),
          ),
        );
      },
    );
  }
}
