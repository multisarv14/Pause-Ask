import 'dart:io';

import 'package:android_intent_plus/android_intent.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_constants.dart';
import '../../core/router/app_routes.dart';
import '../../l10n/app_localizations.dart';

/// Brands known to kill background apps (see dontkillmyapp.com).
const aggressiveBatteryBrands = {
  'xiaomi',
  'redmi',
  'poco',
  'oppo',
  'vivo',
  'iqoo',
  'realme',
  'oneplus',
  'samsung',
  'huawei',
  'honor',
  'tecno',
  'infinix',
  'itel',
};

bool isAggressiveBrand(String manufacturer, String brand) =>
    aggressiveBatteryBrands.contains(manufacturer.toLowerCase().trim()) ||
    aggressiveBatteryBrands.contains(brand.toLowerCase().trim());

/// True on Android phones from the brands above.
Future<bool> needsBatteryGuide() async {
  if (kIsWeb || !Platform.isAndroid) return false;
  try {
    final info = await DeviceInfoPlugin().androidInfo;
    return isAggressiveBrand(info.manufacturer, info.brand);
  } catch (_) {
    return false;
  }
}

Future<void> _launch(AndroidIntent intent) async {
  try {
    await intent.launch();
  } catch (_) {
    // Fallback that exists on every phone: this app's settings page.
    await const AndroidIntent(
      action: 'android.settings.APPLICATION_DETAILS_SETTINGS',
      data: 'package:${AppConstants.packageName}',
    ).launch();
  }
}

/// One-time guide (also reachable from Settings) to allow notifications and
/// turn off battery optimization for PauseAsk.
class BatteryGuideScreen extends StatelessWidget {
  const BatteryGuideScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;

    Widget step(String text, String button, VoidCallback onPressed) => Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            text,
            style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 10),
          OutlinedButton(onPressed: onPressed, child: Text(button)),
        ],
      ),
    );

    return Scaffold(
      appBar: AppBar(title: Text(l10n.notificationHelp)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Icon(Icons.battery_alert, size: 72),
            const SizedBox(height: 12),
            Text(
              l10n.batteryGuideTitle,
              textAlign: TextAlign.center,
              style: textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 12),
            Text(l10n.batteryGuideIntro, style: textTheme.bodyLarge),
            const SizedBox(height: 24),
            step(
              l10n.batteryStepNotifications,
              l10n.openNotificationSettings,
              () => _launch(
                const AndroidIntent(
                  action: 'android.settings.APP_NOTIFICATION_SETTINGS',
                  arguments: {
                    'android.provider.extra.APP_PACKAGE':
                        AppConstants.packageName,
                  },
                ),
              ),
            ),
            step(
              l10n.batteryStepBattery,
              l10n.openBatterySettings,
              () => _launch(
                const AndroidIntent(
                  action:
                      'android.settings.IGNORE_BATTERY_OPTIMIZATION_SETTINGS',
                ),
              ),
            ),
            Text(l10n.batteryStepAutostart, style: textTheme.bodyLarge),
            const SizedBox(height: 10),
            OutlinedButton(
              onPressed: () => _launch(
                const AndroidIntent(
                  action: 'android.settings.APPLICATION_DETAILS_SETTINGS',
                  data: 'package:${AppConstants.packageName}',
                ),
              ),
              child: Text(l10n.openAppSettings),
            ),
            const SizedBox(height: 28),
            FilledButton(
              onPressed: () =>
                  context.canPop() ? context.pop() : context.go(AppRoutes.home),
              child: Text(l10n.done),
            ),
          ],
        ),
      ),
    );
  }
}
